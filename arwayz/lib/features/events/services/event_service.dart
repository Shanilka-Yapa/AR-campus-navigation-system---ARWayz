import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/event.dart';

/// A resolved venue for an event: the coordinates navigation should target,
/// plus the display name of the building the venue sits in (when it has one).
class EventVenue {
  final double? latitude;
  final double? longitude;
  final String? buildingName;

  const EventVenue({this.latitude, this.longitude, this.buildingName});

  bool get hasCoordinates => latitude != null && longitude != null;
}

/// All Firestore access for the events feature lives here.
class EventService {
  EventService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String eventsCollection = 'events';
  static const String buildingsCollection = 'buildings';
  static const String postersCollection = 'event_posters';

  /// Every event a student should see, in display order.
  ///
  /// Hidden events are filtered out and the final ordering is applied in the
  /// client, so this is a single-field `orderBy` that needs no composite
  /// index. Client-side handling is also what makes substring search possible,
  /// which Firestore cannot do server-side. Suitable for a campus event list;
  /// if the collection ever grows into the thousands, add a
  /// `where('endAt', ...)` filter on the same field.
  Stream<List<Event>> watchEvents() {
    return _firestore
        .collection(eventsCollection)
        .orderBy('startAt')
        .snapshots()
        .map(_mapSnapshot);
  }

  List<Event> _mapSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final events = <Event>[];
    for (final doc in snapshot.docs) {
      try {
        final event = Event.fromFirestore(doc.id, doc.data());
        // Hidden events stay in Firestore for the admin, but never reach
        // the student list.
        if (!event.hidden) {
          events.add(event);
        }
      } on FormatException catch (error) {
        // Skip a malformed document rather than breaking the whole stream.
        debugPrint('Skipping event ${doc.id}: ${error.message}');
      }
    }

    events.sort(
      (a, b) => a.effectiveSortOrder.compareTo(b.effectiveSortOrder),
    );
    return events;
  }

  /// Resolves where an event actually is.
  ///
  /// Coordinates come from, in order:
  ///   1. explicit `venueLatitude`/`venueLongitude` on the event
  ///      (outdoor venues with no building),
  ///   2. the referenced `buildings` document,
  ///   3. nothing - the caller should disable navigation.
  ///
  /// The building is fetched once so the caller also gets its display name
  /// for the indoor-location card.
  Future<EventVenue> resolveVenue(Event event) async {
    String? buildingName;
    double? buildingLatitude;
    double? buildingLongitude;

    final buildingId = event.buildingId;
    if (buildingId != null && buildingId.isNotEmpty) {
      try {
        final doc = await _firestore
            .collection(buildingsCollection)
            .doc(buildingId)
            .get();
        final data = doc.data();
        if (data != null) {
          buildingName = data['name'] as String?;
          buildingLatitude = (data['latitude'] as num?)?.toDouble();
          buildingLongitude = (data['longitude'] as num?)?.toDouble();
        }
      } catch (error) {
        debugPrint('Could not load building $buildingId: $error');
      }
    }

    return EventVenue(
      latitude: event.venueLatitude ?? buildingLatitude,
      longitude: event.venueLongitude ?? buildingLongitude,
      buildingName: buildingName,
    );
  }

  /// Loads an event's poster image.
  ///
  /// Posters live in their own collection, keyed by the event id, so that
  /// listing events never downloads image bytes - only the details page pays
  /// that cost, and only for events that actually have one.
  ///
  /// Returns null when there is no poster or it cannot be decoded.
  Future<Uint8List?> loadPoster(Event event) async {
    if (!event.hasPoster) {
      return null;
    }

    try {
      final doc =
          await _firestore.collection(postersCollection).doc(event.id).get();
      final data = doc.data();
      final encoded = data?['data'];
      if (encoded is! String || encoded.isEmpty) {
        return null;
      }
      return base64Decode(encoded);
    } catch (error) {
      debugPrint('Could not load poster for event ${event.id}: $error');
      return null;
    }
  }
}
