import 'package:cloud_firestore/cloud_firestore.dart';

/// A campus event stored in the Firestore `events` collection.
///
/// The Firestore document id *is* the event id, so there is no separate
/// `eventId` field to drift out of sync. This mirrors the approach taken by
/// [Destination] in lib/core/models/destination.dart.
///
/// `buildingId` references a document in the existing `buildings` collection
/// rather than duplicating building data. Coordinates are resolved from that
/// building at navigation time; see EventService.resolveVenueCoordinates.
class Event {
  final String id;
  final String title;
  final String description;

  /// Short line shown under the title and included in the share text.
  final String? caption;

  final DateTime startAt;
  final DateTime endAt;
  final String venueName;
  final String? buildingId;
  final int? floor;
  final String? indoorPointId;
  final double? venueLatitude;
  final double? venueLongitude;

  /// Whether a poster document exists for this event in `event_posters`.
  /// Stored on the event so the list can avoid a lookup per row.
  final bool hasPoster;

  /// Hidden events stay in Firestore and remain visible to admins, but are
  /// filtered out of the student list.
  final bool hidden;

  /// Manual display order set by the admin. Null means "not reordered yet",
  /// in which case the event falls back to its start time - see
  /// [effectiveSortOrder].
  final double? sortOrder;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    this.caption,
    required this.startAt,
    required this.endAt,
    required this.venueName,
    this.buildingId,
    this.floor,
    this.indoorPointId,
    this.venueLatitude,
    this.venueLongitude,
    this.hasPoster = false,
    this.hidden = false,
    this.sortOrder,
  });

  factory Event.fromFirestore(String documentId, Map<String, dynamic> data) {
    final startAt = data['startAt'];
    final endAt = data['endAt'];

    if (startAt is! Timestamp || endAt is! Timestamp) {
      throw FormatException('Invalid start or end time for event $documentId');
    }

    return Event(
      id: documentId,
      title: data['title'] as String? ?? 'Untitled Event',
      description: data['description'] as String? ?? '',
      caption: data['caption'] as String?,
      startAt: startAt.toDate(),
      endAt: endAt.toDate(),
      venueName: data['venueName'] as String? ?? 'Venue to be announced',
      buildingId: data['buildingId'] as String?,
      floor: (data['floor'] as num?)?.toInt(),
      indoorPointId: data['indoorPointId'] as String?,
      venueLatitude: (data['venueLatitude'] as num?)?.toDouble(),
      venueLongitude: (data['venueLongitude'] as num?)?.toDouble(),
      hasPoster: data['hasPoster'] as bool? ?? false,
      hidden: data['hidden'] as bool? ?? false,
      sortOrder: (data['sortOrder'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'title': title,
      'description': description,
      'caption': caption,
      'startAt': Timestamp.fromDate(startAt),
      'endAt': Timestamp.fromDate(endAt),
      'venueName': venueName,
      'buildingId': buildingId,
      'floor': floor,
      'indoorPointId': indoorPointId,
      'venueLatitude': venueLatitude,
      'venueLongitude': venueLongitude,
      'hasPoster': hasPoster,
      'hidden': hidden,
      'sortOrder': effectiveSortOrder,
    };
  }

  /// The value the list actually sorts on.
  ///
  /// Events that have never been reordered fall back to their start time, so
  /// the default ordering stays chronological and the admin's arrows only
  /// affect what they have explicitly moved.
  double get effectiveSortOrder =>
      sortOrder ?? startAt.millisecondsSinceEpoch.toDouble();

  /// An event counts as past only once it has finished, so an event running
  /// right now still shows under "Upcoming" rather than disappearing.
  bool isPast({DateTime? now}) => endAt.isBefore(now ?? DateTime.now());

  bool isUpcoming({DateTime? now}) => !isPast(now: now);

  bool isInProgress({DateTime? now}) {
    final moment = now ?? DateTime.now();
    return !startAt.isAfter(moment) && endAt.isAfter(moment);
  }

  /// True when the venue is mapped to a building floor, which is what the
  /// details page uses to decide whether to show indoor guidance.
  bool get hasIndoorLocation => buildingId != null && floor != null;

  bool get hasExplicitCoordinates =>
      venueLatitude != null && venueLongitude != null;

  /// Case-insensitive substring match across the fields a student would
  /// search by. Firestore cannot do substring queries, so searching is done
  /// in the client against the already-streamed list.
  bool matchesQuery(String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      return true;
    }
    return title.toLowerCase().contains(trimmed) ||
        venueName.toLowerCase().contains(trimmed) ||
        description.toLowerCase().contains(trimmed) ||
        (caption?.toLowerCase().contains(trimmed) ?? false);
  }
}
