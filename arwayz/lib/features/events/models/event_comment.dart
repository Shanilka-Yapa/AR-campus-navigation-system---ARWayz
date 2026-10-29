import 'package:cloud_firestore/cloud_firestore.dart';

/// A student's comment on an event, stored in `event_comments`.
///
/// The author's display name is denormalised onto the comment so the list can
/// be rendered with one query, without a lookup per row into `students`.
class EventComment {
  final String id;
  final String eventId;
  final String uid;
  final String studentName;
  final String indexNumber;
  final String text;
  final DateTime? createdAt;

  const EventComment({
    required this.id,
    required this.eventId,
    required this.uid,
    required this.studentName,
    required this.indexNumber,
    required this.text,
    this.createdAt,
  });

  factory EventComment.fromFirestore(
    String documentId,
    Map<String, dynamic> data,
  ) {
    return EventComment(
      id: documentId,
      eventId: data['eventId'] as String? ?? '',
      uid: data['uid'] as String? ?? '',
      studentName: data['studentName'] as String? ?? 'Student',
      indexNumber: data['indexNumber'] as String? ?? '',
      text: data['text'] as String? ?? '',
      // A freshly written comment reads back with a null server timestamp
      // until the write round-trips, so this stays nullable.
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
