import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/event.dart';
import '../models/event_comment.dart';
import '../models/student_profile.dart';

/// Firestore writes for the admin portal: events, posters, comments and
/// student registrations.
///
/// Every write here is rejected unless an allowlisted admin is signed in -
/// the Firestore rules, not this class, are what enforce that.
class AdminDataService {
  AdminDataService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String eventsCollection = 'events';
  static const String postersCollection = 'event_posters';
  static const String commentsCollection = 'event_comments';
  static const String studentsCollection = 'students';

  // ---------------------------------------------------------------- events

  /// Every event including hidden ones, in display order.
  ///
  /// Differs from the student stream, which filters hidden events out.
  Stream<List<Event>> watchAllEvents() {
    return _firestore
        .collection(eventsCollection)
        .orderBy('startAt')
        .snapshots()
        .map((snapshot) {
      final events = <Event>[];
      for (final doc in snapshot.docs) {
        try {
          events.add(Event.fromFirestore(doc.id, doc.data()));
        } on FormatException catch (error) {
          debugPrint('Skipping event ${doc.id}: ${error.message}');
        }
      }
      events.sort(
        (a, b) => a.effectiveSortOrder.compareTo(b.effectiveSortOrder),
      );
      return events;
    });
  }

  Future<void> setHidden(String eventId, bool hidden) {
    return _firestore
        .collection(eventsCollection)
        .doc(eventId)
        .update({'hidden': hidden, 'updatedAt': FieldValue.serverTimestamp()});
  }

  /// Swaps two events' positions by exchanging their sort values.
  ///
  /// Written as one batch so the pair can never end up disagreeing.
  Future<void> swapOrder(Event a, Event b) async {
    final first = a.effectiveSortOrder;
    // Identical values would make the swap a no-op, so nudge them apart.
    final second =
        first == b.effectiveSortOrder ? b.effectiveSortOrder + 1 : b.effectiveSortOrder;

    final batch = _firestore.batch();
    batch.update(_firestore.collection(eventsCollection).doc(a.id), {
      'sortOrder': second,
    });
    batch.update(_firestore.collection(eventsCollection).doc(b.id), {
      'sortOrder': first,
    });
    await batch.commit();
  }

  Future<void> deleteEvent(String eventId) async {
    await _firestore.collection(eventsCollection).doc(eventId).delete();
    try {
      await _firestore.collection(postersCollection).doc(eventId).delete();
    } catch (_) {
      // No poster, or already removed.
    }
  }

  /// Creates or updates an event, and writes or clears its poster.
  ///
  /// On create the document id is generated up front so the poster can be
  /// stored against a matching id in the same save.
  Future<void> saveEvent({
    String? eventId,
    required Map<String, dynamic> data,
    required String? posterBase64,
    required bool posterChanged,
  }) async {
    final isCreate = eventId == null;
    final ref = isCreate
        ? _firestore.collection(eventsCollection).doc()
        : _firestore.collection(eventsCollection).doc(eventId);

    final body = <String, dynamic>{
      ...data,
      'hasPoster': posterChanged ? posterBase64 != null : data['hasPoster'],
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (isCreate) {
      await ref.set({
        ...body,
        'hidden': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.update(body);
    }

    if (posterChanged) {
      final posterRef = _firestore.collection(postersCollection).doc(ref.id);
      if (posterBase64 == null) {
        try {
          await posterRef.delete();
        } catch (_) {
          // Nothing to remove.
        }
      } else {
        await posterRef.set({
          'data': posterBase64,
          'contentType': 'image/jpeg',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  Future<Uint8List?> loadPoster(String eventId) async {
    try {
      final doc =
          await _firestore.collection(postersCollection).doc(eventId).get();
      final encoded = doc.data()?['data'];
      if (encoded is! String || encoded.isEmpty) return null;
      return base64Decode(encoded);
    } catch (error) {
      debugPrint('Could not load poster for $eventId: $error');
      return null;
    }
  }

  // -------------------------------------------------------------- comments

  /// Every comment across every event, newest first.
  Stream<List<EventComment>> watchAllComments() {
    return _firestore.collection(commentsCollection).snapshots().map((
      snapshot,
    ) {
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
        // A comment awaiting its server timestamp was just written.
        if (left == null) return -1;
        if (right == null) return 1;
        return right.compareTo(left);
      });
      return comments;
    });
  }

  Future<void> deleteComment(String commentId) {
    return _firestore.collection(commentsCollection).doc(commentId).delete();
  }

  // -------------------------------------------------------------- students

  Stream<List<StudentProfile>> watchStudents() {
    return _firestore.collection(studentsCollection).snapshots().map((
      snapshot,
    ) {
      final students = snapshot.docs
          .map((doc) => StudentProfile.fromFirestore(doc.id, doc.data()))
          .toList();
      students.sort((a, b) {
        final left = a.createdAt;
        final right = b.createdAt;
        if (left != null && right != null) return right.compareTo(left);
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
      return students;
    });
  }

  Future<void> setStudentStatus(String uid, StudentStatus status) {
    return _firestore.collection(studentsCollection).doc(uid).update({
      'status': statusToFirestore(status),
      'reviewedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Removes a registration record, which locks the student out.
  ///
  /// Their Firebase Authentication account still exists; deleting that needs
  /// the Admin SDK and must be done from the Firebase console.
  Future<void> deleteStudent(String uid) {
    return _firestore.collection(studentsCollection).doc(uid).delete();
  }
}
