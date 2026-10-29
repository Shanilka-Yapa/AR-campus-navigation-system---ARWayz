import 'package:cloud_firestore/cloud_firestore.dart';

/// Likes on events.
///
/// One document per student per event, with the id built from both so a
/// student physically cannot like the same event twice. That also lets the
/// Firestore rules verify a student is only ever writing their own like.
class LikeService {
  LikeService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String likesCollection = 'event_likes';

  static String likeId(String eventId, String uid) => '${eventId}_$uid';

  /// Every like on an event. The count is the document count, and whether the
  /// current student has liked is membership in the same set, so one stream
  /// serves both.
  Stream<Set<String>> watchLikes(String eventId) {
    return _firestore
        .collection(likesCollection)
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => doc.data()['uid'] as String? ?? '')
          .where((uid) => uid.isNotEmpty)
          .toSet();
    });
  }

  Future<void> setLiked({
    required String eventId,
    required String uid,
    required bool liked,
  }) async {
    final ref = _firestore.collection(likesCollection).doc(likeId(eventId, uid));

    if (liked) {
      await ref.set({
        'eventId': eventId,
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.delete();
    }
  }
}
