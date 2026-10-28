import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/event_comment.dart';
import '../models/student_profile.dart';

/// Reads and writes student comments on events.
class CommentService {
  CommentService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String commentsCollection = 'event_comments';

  /// Comments for one event, newest last.
  ///
  /// Filtering by `eventId` and ordering by `createdAt` are different fields,
  /// which would normally need a composite index, so the ordering is applied
  /// in the client instead. An event's comment list is small enough that this
  /// costs nothing.
  Stream<List<EventComment>> watchComments(String eventId) {
    return _firestore
        .collection(commentsCollection)
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) {
      final comments = <EventComment>[];
      for (final doc in snapshot.docs) {
        try {
          comments.add(EventComment.fromFirestore(doc.id, doc.data()));
        } catch (error) {
          debugPrint('Skipping comment ${doc.id}: $error');
        }
      }

      comments.sort((a, b) {
        final left = a.createdAt;
        final right = b.createdAt;
        // A comment still awaiting its server timestamp is the one just
        // written, so it belongs at the end.
        if (left == null) return 1;
        if (right == null) return -1;
        return left.compareTo(right);
      });
      return comments;
    });
  }

  Future<void> addComment({
    required String eventId,
    required StudentProfile student,
    required String text,
  }) async {
    await _firestore.collection(commentsCollection).add({
      'eventId': eventId,
      'uid': student.uid,
      'studentName': student.name,
      'indexNumber': student.indexNumber,
      'text': text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Students may remove their own comment; admins moderate from the
  /// dashboard.
  Future<void> deleteComment(String commentId) {
    return _firestore.collection(commentsCollection).doc(commentId).delete();
  }
}
