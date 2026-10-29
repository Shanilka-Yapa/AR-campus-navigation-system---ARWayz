import 'package:flutter/material.dart';

import 'event_theme.dart';
import 'models/event.dart';
import 'pages/event_details_page.dart';
import 'services/event_service.dart';
import 'widgets/event_card.dart';
import 'widgets/student_account_action.dart';

enum _EventFilter { upcoming, past }

/// Student-facing campus events list: search, upcoming/past filtering, and a
/// tap-through to details and navigation.
class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final EventService _service = EventService();
  final TextEditingController _searchController = TextEditingController();

  /// Created once, not in `build`. Rebuilding on every keystroke would
  /// otherwise tear down and re-subscribe the Firestore listener, flashing the
  /// loading spinner and costing extra reads while the user types.
  late final Stream<List<Event>> _eventsStream = _service.watchEvents();

  String _query = '';
  _EventFilter _filter = _EventFilter.upcoming;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Splits the date-ordered stream into the selected tab and applies search.
  ///
  /// Past events are reversed so the most recent appears first, while upcoming
  /// events keep their ascending order so the soonest is at the top.
  List<Event> _visibleEvents(List<Event> all) {
    final now = DateTime.now();
    final filtered = all.where((event) {
      final matchesFilter = _filter == _EventFilter.past
          ? event.isPast(now: now)
          : event.isUpcoming(now: now);
      return matchesFilter && event.matchesQuery(_query);
    }).toList();

    if (_filter == _EventFilter.past) {
      return filtered.reversed.toList();
    }
    return filtered;
  }

  void _openEvent(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EventDetailsPage(event: event)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kEventScaffoldBg,
      appBar: AppBar(
        title: const Text('Campus Events'),
        backgroundColor: kEventPrimaryDark,
        foregroundColor: Colors.white,
        actions: const [StudentAccountAction()],
      ),
      body: Column(
        children: [
          _SearchField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            onClear: () {
              _searchController.clear();
              setState(() => _query = '');
            },
          ),
          _FilterTabs(
            filter: _filter,
            onChanged: (value) => setState(() => _filter = value),
          ),
          Expanded(
            child: StreamBuilder<List<Event>>(
              stream: _eventsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: kEventDeepTeal),
                  );
                }

                if (snapshot.hasError) {
                  return _EmptyState(
                    icon: Icons.error_outline,
                    title: 'Could not load events',
                    message: '${snapshot.error}',
                  );
                }

                final all = snapshot.data ?? const <Event>[];
                if (all.isEmpty) {
                  return const _EmptyState(
                    icon: Icons.event_busy,
                    title: 'No events yet',
                    message:
                        'Campus events will appear here once they are added.',
                  );
                }

                final events = _visibleEvents(all);
                if (events.isEmpty) {
                  return _EmptyState(
                    icon: _query.isEmpty ? Icons.event_busy : Icons.search_off,
                    title: _query.isEmpty
                        ? (_filter == _EventFilter.past
                            ? 'No past events'
                            : 'No upcoming events')
                        : 'No matching events',
                    message: _query.isEmpty
                        ? 'Check back later for new campus events.'
                        : 'Try a different event name or venue.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 16),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return EventCard(
                      event: event,
                      onTap: () => _openEvent(event),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search events or venues',
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(Icons.search, color: kEventMutedTeal),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close, color: kEventSteelBlue),
                  onPressed: onClear,
                ),
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
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
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final _EventFilter filter;
  final ValueChanged<_EventFilter> onChanged;

  const _FilterTabs({required this.filter, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _FilterChip(
            label: 'Upcoming',
            selected: filter == _EventFilter.upcoming,
            onTap: () => onChanged(_EventFilter.upcoming),
          ),
          const SizedBox(width: 10),
          _FilterChip(
            label: 'Past',
            selected: filter == _EventFilter.past,
            onTap: () => onChanged(_EventFilter.past),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? kEventPrimaryDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? kEventPrimaryDark : kEventLightGray,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : kEventMutedTeal,
            fontWeight: FontWeight.bold,
            fontSize: 13.5,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 52, color: kEventLightGray),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: kEventPrimaryDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13.5, color: kEventSteelBlue),
            ),
          ],
        ),
      ),
    );
  }
}
