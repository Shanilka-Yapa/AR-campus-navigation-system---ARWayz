import 'package:flutter/material.dart';

import '../event_theme.dart';
import '../models/event.dart';
import '../models/event_comment.dart';
import '../models/student_profile.dart';
import '../widgets/event_date_text.dart';
import 'admin_data_service.dart';

/// Comment moderation: every comment across every event, newest first, with
/// delete and block-the-author actions.
class AdminCommentsTab extends StatefulWidget {
  const AdminCommentsTab({super.key});

  @override
  State<AdminCommentsTab> createState() => _AdminCommentsTabState();
}

class _AdminCommentsTabState extends State<AdminCommentsTab> {
  final AdminDataService _service = AdminDataService();
  final TextEditingController _searchController = TextEditingController();

  late final Stream<List<EventComment>> _comments = _service.watchAllComments();
  late final Stream<List<Event>> _events = _service.watchAllEvents();
  late final Stream<List<StudentProfile>> _students = _service.watchStudents();

  String _query = '';
  String _busyId = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _run(String id, Future<void> Function() action) async {
    setState(() => _busyId = id);
    try {
      await action();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not complete: $error'),
            backgroundColor: kEventPrimaryDark,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busyId = '');
    }
  }

  Future<bool> _confirm(String title, String body, String action) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(action, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kEventScaffoldBg,
      appBar: AppBar(
        backgroundColor: kEventPrimaryDark,
        foregroundColor: Colors.white,
        title: const Text('Manage Comments'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return StreamBuilder<List<Event>>(
      stream: _events,
      builder: (context, eventSnapshot) {
        final titles = <String, String>{
          for (final event in eventSnapshot.data ?? const <Event>[])
            event.id: event.title,
        };

        return StreamBuilder<List<StudentProfile>>(
          stream: _students,
          builder: (context, studentSnapshot) {
            final blocked = <String>{
              for (final student in
                  studentSnapshot.data ?? const <StudentProfile>[])
                if (student.isBlocked) student.uid,
            };

            return StreamBuilder<List<EventComment>>(
              stream: _comments,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: kEventDeepTeal),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Could not load comments.\n\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: kEventSteelBlue,
                        ),
                      ),
                    ),
                  );
                }

                final all = snapshot.data ?? const <EventComment>[];
                final needle = _query.trim().toLowerCase();
                final visible = all.where((comment) {
                  if (needle.isEmpty) return true;
                  return comment.text.toLowerCase().contains(needle) ||
                      comment.studentName.toLowerCase().contains(needle) ||
                      comment.indexNumber.toLowerCase().contains(needle);
                }).toList();

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() => _query = value),
                        decoration: InputDecoration(
                          hintText: 'Search comments, authors or index numbers',
                          filled: true,
                          fillColor: Colors.white,
                          isDense: true,
                          prefixIcon: const Icon(
                            Icons.search,
                            color: kEventMutedTeal,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: kEventLightGray,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: kEventLightGray,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: visible.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(28),
                                child: Text(
                                  all.isEmpty
                                      ? 'No comments yet.'
                                      : 'No comments match that search.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: kEventSteelBlue,
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 16),
                              itemCount: visible.length,
                              itemBuilder: (context, index) {
                                final comment = visible[index];
                                return _CommentCard(
                                  comment: comment,
                                  eventTitle: titles[comment.eventId],
                                  authorBlocked: blocked.contains(comment.uid),
                                  busy: _busyId == comment.id,
                                  onDelete: () async {
                                    final ok = await _confirm(
                                      'Delete comment?',
                                      'From ${comment.studentName}:\n\n'
                                          '"${comment.text}"',
                                      'Delete',
                                    );
                                    if (ok) {
                                      await _run(
                                        comment.id,
                                        () => _service.deleteComment(
                                          comment.id,
                                        ),
                                      );
                                    }
                                  },
                                  onBlockAuthor: () async {
                                    final ok = await _confirm(
                                      'Block author?',
                                      '${comment.studentName} '
                                          '(${comment.indexNumber}) will no '
                                          'longer be able to comment or like. '
                                          'Existing comments stay.',
                                      'Block',
                                    );
                                    if (ok) {
                                      await _run(
                                        comment.id,
                                        () => _service.setStudentStatus(
                                          comment.uid,
                                          StudentStatus.blocked,
                                        ),
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _CommentCard extends StatelessWidget {
  final EventComment comment;
  final String? eventTitle;
  final bool authorBlocked;
  final bool busy;
  final VoidCallback onDelete;
  final VoidCallback onBlockAuthor;

  const _CommentCard({
    required this.comment,
    required this.eventTitle,
    required this.authorBlocked,
    required this.busy,
    required this.onDelete,
    required this.onBlockAuthor,
  });

  @override
  Widget build(BuildContext context) {
    final created = comment.createdAt;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    comment.indexNumber.isEmpty
                        ? comment.studentName
                        : '${comment.studentName} · ${comment.indexNumber}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: kEventPrimaryDark,
                    ),
                  ),
                ),
                if (authorBlocked)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: kEventSteelBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Blocked',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              comment.text,
              style: const TextStyle(fontSize: 14, color: kEventDeepTeal),
            ),
            const SizedBox(height: 8),
            Text(
              'on ${eventTitle ?? "a deleted event"}'
              '${created != null ? " · ${formatEventDate(created)} "
                  "${formatEventTime(created)}" : " · just now"}',
              style: const TextStyle(fontSize: 11.5, color: kEventSteelBlue),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (!authorBlocked && comment.uid.isNotEmpty) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: busy ? null : onBlockAuthor,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kEventMutedTeal,
                      ),
                      child: const Text('Block author'),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: OutlinedButton(
                    onPressed: busy ? null : onDelete,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                    ),
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
