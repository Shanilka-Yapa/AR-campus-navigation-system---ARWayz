import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../outdoor_navigation/route_preview_page.dart';


import '../event_theme.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../widgets/event_date_text.dart';
import '../widgets/event_engagement.dart';

/// Full details for one event, plus the hand-off into navigation.
class EventDetailsPage extends StatefulWidget {
  final Event event;

  const EventDetailsPage({super.key, required this.event});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  final EventService _service = EventService();
  late Future<EventVenue> _venueFuture;
  late Future<Uint8List?> _posterFuture;

  @override
  void initState() {
    super.initState();
    _venueFuture = _service.resolveVenue(widget.event);
    _posterFuture = _service.loadPoster(widget.event);
  }

  /// Builds the plain-text summary handed to the system share sheet.
  ///
  /// There is no public web page for an event, so the share carries the
  /// details themselves rather than a link.
  String _buildShareText(EventVenue? venue) {
    final event = widget.event;
    final lines = <String>[event.title];

    final caption = event.caption;
    if (caption != null && caption.trim().isNotEmpty) {
      lines.add(caption.trim());
    }

    lines
      ..add('')
      ..add('Date: ${formatEventDateWithWeekday(event.startAt)}')
      ..add('Time: ${formatEventTimeRange(event.startAt, event.endAt)}')
      ..add('Venue: ${event.venueName}');

    final buildingName = venue?.buildingName;
    if (buildingName != null && buildingName.isNotEmpty) {
      lines.add('Building: $buildingName');
    }
    if (event.floor != null) {
      lines.add('Floor: ${event.floor}');
    }
    if (event.description.trim().isNotEmpty) {
      lines
        ..add('')
        ..add(event.description.trim());
    }

    lines
      ..add('')
      ..add('Shared from ARWayz');

    return lines.join('\n');
  }

  Future<void> _shareEvent(EventVenue? venue) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: _buildShareText(venue),
          subject: widget.event.title,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open the share sheet: $error'),
          backgroundColor: kEventPrimaryDark,
        ),
      );
    }
  }

  void _startNavigation(EventVenue venue) {
    final latitude = venue.latitude;
    final longitude = venue.longitude;

    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This event has no mapped location yet.'),
          backgroundColor: kEventPrimaryDark,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoutePreviewPage(
          destLat: latitude,
          destLng: longitude,
          placeName: widget.event.venueName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return Scaffold(
      backgroundColor: kEventScaffoldBg,
      appBar: AppBar(
        title: const Text('Event Details'),
        backgroundColor: kEventPrimaryDark,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<EventVenue>(
        future: _venueFuture,
        builder: (context, snapshot) {
          final venue = snapshot.data;
          final loading = snapshot.connectionState == ConnectionState.waiting;
          // Sharing works before the venue resolves; the building line is
          // simply omitted until it is known.

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    if (event.hasPoster)
                      _EventPoster(posterFuture: _posterFuture),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  event.title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: kEventPrimaryDark,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => _shareEvent(venue),
                                icon: const Icon(Icons.share),
                                color: kEventDeepTeal,
                                tooltip: 'Share this event',
                              ),
                            ],
                          ),
                          if (event.caption != null &&
                              event.caption!.trim().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              event.caption!.trim(),
                              style: const TextStyle(
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                                color: kEventMutedTeal,
                              ),
                            ),
                          ],
                          if (event.isPast()) ...[
                            const SizedBox(height: 8),
                            const _StatusChip(
                              label: 'This event has ended',
                              color: kEventSteelBlue,
                            ),
                          ] else if (event.isInProgress()) ...[
                            const SizedBox(height: 8),
                            const _StatusChip(
                              label: 'Happening now',
                              color: kEventMutedTeal,
                            ),
                          ],
                          const SizedBox(height: 20),
                          _DetailTile(
                            icon: Icons.calendar_today,
                            label: 'Date',
                            value: formatEventDateWithWeekday(event.startAt),
                          ),
                          _DetailTile(
                            icon: Icons.schedule,
                            label: 'Time',
                            value: formatEventTimeRange(
                              event.startAt,
                              event.endAt,
                            ),
                          ),
                          _DetailTile(
                            icon: Icons.place,
                            label: 'Venue',
                            value: event.venueName,
                          ),
                          if (venue?.buildingName != null)
                            _DetailTile(
                              icon: Icons.business,
                              label: 'Building',
                              value: venue!.buildingName!,
                            ),
                          if (event.description.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Text(
                              'About this event',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: kEventPrimaryDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              event.description,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.5,
                                color: kEventDeepTeal,
                              ),
                            ),
                          ],
                          if (event.hasIndoorLocation) ...[
                            const SizedBox(height: 20),
                            _IndoorLocationCard(event: event),
                          ],
                          EventEngagement(event: event),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _NavigateBar(
                loading: loading,
                venue: venue,
                onNavigate: venue == null
                    ? null
                    : () => _startNavigation(venue),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Renders the poster stored for this event.
///
/// The bytes come from the `event_posters` collection as a compressed JPEG,
/// so there is no network image to fetch - only a Firestore read and a decode.
class _EventPoster extends StatelessWidget {
  final Future<Uint8List?> posterFuture;

  const _EventPoster({required this.posterFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: posterFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 190,
            color: kEventLightGray,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        final bytes = snapshot.data;
        if (bytes == null || bytes.isEmpty) {
          return _posterPlaceholder();
        }

        return Image.memory(
          bytes,
          height: 190,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _posterPlaceholder(),
        );
      },
    );
  }

  Widget _posterPlaceholder() {
    return Container(
      height: 190,
      color: kEventLightGray,
      child: const Center(
        child: Icon(Icons.image_not_supported, color: Colors.white, size: 40),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: kEventMutedTeal),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: kEventSteelBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: kEventPrimaryDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown for venues that sit on a mapped building floor.
///
/// Indoor navigation cannot be started directly from here: the indoor pages
/// take a scanned QR payload as their starting point and do not accept a
/// destination, so the student is pointed at the in-building QR codes instead.
class _IndoorLocationCard extends StatelessWidget {
  final Event event;

  const _IndoorLocationCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kEventDeepTeal,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.stairs, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Indoor location',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _IndoorRow(label: 'Floor', value: event.floor.toString()),
          if (event.indoorPointId != null && event.indoorPointId!.isNotEmpty)
            _IndoorRow(label: 'Access point', value: event.indoorPointId!),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.qr_code_scanner, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Scan the QR code inside the building to start indoor '
                    'navigation.',
                    style: TextStyle(color: Colors.white, fontSize: 12.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IndoorRow extends StatelessWidget {
  final String label;
  final String value;

  const _IndoorRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: kEventLightGray, fontSize: 13),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigateBar extends StatelessWidget {
  final bool loading;
  final EventVenue? venue;
  final VoidCallback? onNavigate;

  const _NavigateBar({
    required this.loading,
    required this.venue,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final hasCoordinates = venue?.hasCoordinates ?? false;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: kEventLightGray)),
      ),
      child: Column(
        children: [
          if (!loading && !hasCoordinates)
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                'This event has no mapped location yet.',
                style: TextStyle(fontSize: 12.5, color: kEventSteelBlue),
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: loading || !hasCoordinates ? null : onNavigate,
              icon: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.navigation, color: Colors.white),
              label: Text(
                loading ? 'Loading venue...' : 'Navigate to Event',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kEventPrimaryDark,
                disabledBackgroundColor: kEventLightGray,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
