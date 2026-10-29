import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../event_theme.dart';
import '../models/event.dart';
import '../models/event_comment.dart';
import '../models/student_profile.dart';
import '../pages/student_auth_page.dart';
import '../services/comment_service.dart';
import '../services/like_service.dart';
import '../services/student_auth_service.dart';

/// Likes and comments for one event.
///
/// Anyone can read both without an account. Posting requires a student who has
/// signed in *and* been approved by an admin - a rule the Firestore rules
/// enforce independently of this UI.
class EventEngagement extends StatefulWidget {
  final Event event;

  const EventEngagement({super.key, required this.event});

  @override
  State<EventEngagement> createState() => _EventEngagementState();
}

class _EventEngagementState extends State<EventEngagement> {
  final StudentAuthService _authService = StudentAuthService();
  final CommentService _commentService = CommentService();
  final LikeService _likeService = LikeService();

  final TextEditingController _commentController = TextEditingController();

  // Built once so typing in the comment box does not re-subscribe them.
  late final Stream<User?> _authStream = _authService.authStateChanges();
  late final Stream<Set<String>> _likesStream =
      _likeService.watchLikes(widget.event.id);
  late final Stream<List<EventComment>> _commentsStream =
      _commentService.watchComments(widget.event.id);

  bool _posting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _openSignIn() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StudentAuthPage()),
    );
  }

  void _notify(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: kEventPrimaryDark),
    );
  }

  /// Returns the profile when the student may post, otherwise explains why
  /// they may not and returns null.
  StudentProfile? _requireApproved(StudentProfile? profile) {
    if (profile == null) {
      _openSignIn();
      return null;
    }
    if (profile.isPending) {
      _notify('Your account is waiting for admin approval.');
      return null;
    }
    if (profile.isBlocked) {
      _notify('Your account has been blocked by an admin.');
      return null;
    }
    return profile;
  }

  Future<void> _toggleLike(StudentProfile? profile, bool liked) async {
    final student = _requireApproved(profile);
    if (student == null) return;

    try {
      await _likeService.setLiked(
        eventId: widget.event.id,
        uid: student.uid,
        liked: !liked,
      );
    } catch (error) {
      if (mounted) _notify('Could not update your like: $error');
    }
  }

  Future<void> _postComment(StudentProfile? profile) async {
    final student = _requireApproved(profile);
    if (student == null) return;

    final text = _commentController.text.trim();
    if (text.isEmpty) {
      _notify('Write something before posting.');
      return;
    }

    setState(() => _posting = true);
    try {
      await _commentService.addComment(
        eventId: widget.event.id,
        student: student,
        text: text,
      );
      _commentController.clear();
      if (mounted) {
        FocusScope.of(context).unfocus();
      }
    } catch (error) {
      if (mounted) _notify('Could not post your comment: $error');
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  Future<void> _deleteOwnComment(EventComment comment) async {
    try {
      await _commentService.deleteComment(comment.id);
    } catch (error) {
      if (mounted) _notify('Could not delete the comment: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authStream,
      builder: (context, authSnapshot) {
        final user = authSnapshot.data;

        if (user == null) {
          return _buildSection(profile: null);
        }

        return StreamBuilder<StudentProfile?>(
          stream: _authService.watchProfile(user.uid),
          builder: (context, profileSnapshot) {
            return _buildSection(profile: profileSnapshot.data);
          },
        );
      },
    );
  }

  Widget _buildSection({required StudentProfile? profile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32, color: kEventLightGray),
        _buildLikeRow(profile),
        if (profile != null && !profile.isApproved) ...[
          const SizedBox(height: 12),
          _StatusNotice(profile: profile),
        ],
        const SizedBox(height: 20),
        const Text(
          'Comments',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: kEventPrimaryDark,
          ),
        ),
        const SizedBox(height: 10),
        _buildCommentList(profile),
        const SizedBox(height: 12),
        _buildComposer(profile),
      ],
    );
  }

  Widget _buildLikeRow(StudentProfile? profile) {
    return StreamBuilder<Set<String>>(
      stream: _likesStream,
      builder: (context, snapshot) {
        final likes = snapshot.data ?? const <String>{};
        final liked = profile != null && likes.contains(profile.uid);

        return Row(
          children: [
            IconButton(
              onPressed: () => _toggleLike(profile, liked),
              icon: Icon(
                liked ? Icons.favorite : Icons.favorite_border,
                color: liked ? Colors.redAccent : kEventMutedTeal,
              ),
              tooltip: liked ? 'Remove your like' : 'Like this event',
            ),
            Text(
              likes.isEmpty
                  ? 'No likes yet'
                  : '${likes.length} ${likes.length == 1 ? "like" : "likes"}',
              style: const TextStyle(fontSize: 14, color: kEventMutedTeal),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCommentList(StudentProfile? profile) {
    return StreamBuilder<List<EventComment>>(
      stream: _commentsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: kEventDeepTeal,
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Text(
            'Could not load comments: ${snapshot.error}',
            style: const TextStyle(fontSize: 13, color: kEventSteelBlue),
          );
        }

        final comments = snapshot.data ?? const <EventComment>[];
        if (comments.isEmpty) {
          return const Text(
            'No comments yet. Be the first.',
            style: TextStyle(fontSize: 13.5, color: kEventSteelBlue),
          );
        }

        return Column(
          children: comments
              .map(
                (comment) => _CommentTile(
                  comment: comment,
                  isMine: profile != null && comment.uid == profile.uid,
                  onDelete: () => _deleteOwnComment(comment),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildComposer(StudentProfile? profile) {
    if (profile == null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kEventLightGray),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Sign in with your student account to like and comment.',
                style: TextStyle(fontSize: 13.5, color: kEventMutedTeal),
              ),
            ),
            TextButton(
              onPressed: _openSignIn,
              child: const Text(
                'Sign in',
                style: TextStyle(
                  color: kEventDeepTeal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final canPost = profile.isApproved;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: _commentController,
            enabled: canPost && !_posting,
            minLines: 1,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: canPost
                  ? 'Write a comment'
                  : 'Commenting unlocks once you are approved',
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: kEventLightGray),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: kEventLightGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: kEventDeepTeal, width: 1.5),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: canPost && !_posting ? () => _postComment(profile) : null,
          icon: _posting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: kEventDeepTeal,
                  ),
                )
              : const Icon(Icons.send),
          color: kEventDeepTeal,
          tooltip: 'Post comment',
        ),
      ],
    );
  }
}

class _StatusNotice extends StatelessWidget {
  final StudentProfile profile;

  const _StatusNotice({required this.profile});

  @override
  Widget build(BuildContext context) {
    final blocked = profile.isBlocked;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: blocked ? Colors.red.shade50 : const Color(0xFFEEF4F4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: blocked ? Colors.red.shade200 : kEventLightGray,
        ),
      ),
      child: Row(
        children: [
          Icon(
            blocked ? Icons.block : Icons.hourglass_empty,
            size: 18,
            color: blocked ? Colors.red.shade700 : kEventDeepTeal,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              blocked
                  ? 'Your account has been blocked, so you cannot comment or '
                      'like.'
                  : 'Your registration is waiting for admin approval. You can '
                      'browse events in the meantime.',
              style: TextStyle(
                fontSize: 13,
                color: blocked ? Colors.red.shade900 : kEventDeepTeal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final EventComment comment;
  final bool isMine;
  final VoidCallback onDelete;

  const _CommentTile({
    required this.comment,
    required this.isMine,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kEventLightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  comment.studentName,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: kEventPrimaryDark,
                  ),
                ),
              ),
              if (isMine)
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: kEventSteelBlue,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            comment.text,
            style: const TextStyle(fontSize: 14, color: kEventDeepTeal),
          ),
        ],
      ),
    );
  }
}
