import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../event_theme.dart';
import '../models/event.dart';
import '../widgets/event_date_text.dart';
import 'admin_data_service.dart';
import 'admin_event_form_page.dart';

/// Event management: the full list including hidden events, with reordering,
/// visibility toggling, editing and deletion.
class AdminEventsTab extends StatefulWidget {
  const AdminEventsTab({super.key});

  @override
  State<AdminEventsTab> createState() => _AdminEventsTabState();
}

class _AdminEventsTabState extends State<AdminEventsTab> {
  final AdminDataService _service = AdminDataService();
  late final Stream<List<Event>> _stream = _service.watchAllEvents();

  final Map<String, Uint8List?> _posters = {};
  String _busyId = '';

  /// Posters live in their own collection, so fetch the ones on screen. The
  /// admin list is small; the student list deliberately never does this.
  void _ensurePosters(List<Event> events) {
    for (final event in events) {
      if (!event.hasPoster || _posters.containsKey(event.id)) continue;
      _posters[event.id] = null;
      _service.loadPoster(event.id).then((bytes) {
        if (mounted && bytes != null) {
          setState(() => _posters[event.id] = bytes);
        }
      });
    }
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

  Future<void> _confirmDelete(Event event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete event?'),
        content: Text('"${event.title}" will be removed permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _run(event.id, () => _service.deleteEvent(event.id));
      _posters.remove(event.id);
    }
  }

  void _openForm({Event? event}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminEventFormPage(event: event),
      ),
    ).then((_) {
      // The poster may have changed; drop the cached copy so it reloads.
      if (event != null) {
        setState(() => _posters.remove(event.id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kEventScaffoldBg,
      appBar: AppBar(
        backgroundColor: kEventPrimaryDark,
        foregroundColor: Colors.white,
        title: const Text('Manage Events'),
      ),
      body: StreamBuilder<List<Event>>(
        stream: _stream,
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
                  'Could not load events.\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: kEventSteelBlue,
                  ),
                ),
              ),
            );
          }

          final events = snapshot.data ?? const <Event>[];
          _ensurePosters(events);

          if (events.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Text(
                  'No events yet. Tap + to create the first one.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: kEventSteelBlue),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 90),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return _EventAdminCard(
                event: event,
                poster: _posters[event.id],
                busy: _busyId == event.id,
                canMoveUp: index > 0,
                canMoveDown: index < events.length - 1,
                onMoveUp: () => _run(
                  event.id,
                  () => _service.swapOrder(event, events[index - 1]),
                ),
                onMoveDown: () => _run(
                  event.id,
                  () => _service.swapOrder(event, events[index + 1]),
                ),
                onToggleHidden: () => _run(
                  event.id,
                  () => _service.setHidden(event.id, !event.hidden),
                ),
                onEdit: () => _openForm(event: event),
                onDelete: () => _confirmDelete(event),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'adminEventsFab',
        onPressed: () => _openForm(),
        backgroundColor: kEventDeepTeal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _EventAdminCard extends StatelessWidget {
  final Event event;
  final Uint8List? poster;
  final bool busy;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onToggleHidden;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EventAdminCard({
    required this.event,
    required this.poster,
    required this.busy,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onToggleHidden,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Opacity(
        opacity: event.hidden ? 0.6 : 1,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Thumbnail(event: event, poster: poster),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                            color: kEventPrimaryDark,
                          ),
                        ),
                        if (event.caption != null &&
                            event.caption!.trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              event.caption!.trim(),
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontStyle: FontStyle.italic,
                                color: kEventMutedTeal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        const SizedBox(height: 5),
                        Text(
                          formatEventDate(event.startAt),
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: kEventMutedTeal,
                          ),
                        ),
                        Text(
                          formatEventTimeRange(event.startAt, event.endAt),
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: kEventMutedTeal,
                          ),
                        ),
                        Text(
                          event.venueName,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: kEventMutedTeal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (event.hidden)
                          const Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: _Pill(label: 'Hidden'),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        onPressed: busy || !canMoveUp ? null : onMoveUp,
                        icon: const Icon(Icons.arrow_upward),
                        iconSize: 19,
                        color: kEventMutedTeal,
                        tooltip: 'Move earlier',
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(6),
                      ),
                      IconButton(
                        onPressed: busy || !canMoveDown ? null : onMoveDown,
                        icon: const Icon(Icons.arrow_downward),
                        iconSize: 19,
                        color: kEventMutedTeal,
                        tooltip: 'Move later',
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(6),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: busy ? null : onToggleHidden,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kEventMutedTeal,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                      ),
                      child: Text(event.hidden ? 'Show' : 'Hide'),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: busy ? null : onEdit,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kEventDeepTeal,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                      ),
                      child: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: busy ? null : onDelete,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final Event event;
  final Uint8List? poster;

  const _Thumbnail({required this.event, required this.poster});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 72,
        height: 72,
        child: poster != null
            ? Image.memory(poster!, fit: BoxFit.cover)
            : Container(
                color: kEventLightGray,
                child: Center(
                  child: Icon(
                    event.hasPoster ? Icons.hourglass_empty : Icons.event,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;

  const _Pill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: kEventSteelBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
