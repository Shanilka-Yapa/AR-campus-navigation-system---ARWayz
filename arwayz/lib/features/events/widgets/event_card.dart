import 'package:flutter/material.dart';

import '../event_theme.dart';
import '../models/event.dart';
import 'event_date_text.dart';

/// A single row in the campus events list.
class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const EventCard({super.key, required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final inProgress = event.isInProgress();
    final past = event.isPast();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DateBadge(date: event.startAt, dimmed: past),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: past ? kEventSteelBlue : kEventPrimaryDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    _IconLine(
                      icon: Icons.place_outlined,
                      text: event.venueName,
                      dimmed: past,
                    ),
                    const SizedBox(height: 4),
                    _IconLine(
                      icon: Icons.schedule,
                      text: formatEventTimeRange(event.startAt, event.endAt),
                      dimmed: past,
                    ),
                    if (inProgress) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: kEventMutedTeal,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Happening now',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: past ? kEventLightGray : kEventSteelBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  final DateTime date;
  final bool dimmed;

  const _DateBadge({required this.date, required this.dimmed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: dimmed ? kEventSteelBlue : kEventDeepTeal,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            date.day.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
          Text(
            formatShortMonth(date),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconLine extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool dimmed;

  const _IconLine({
    required this.icon,
    required this.text,
    required this.dimmed,
  });

  @override
  Widget build(BuildContext context) {
    final color = dimmed ? kEventSteelBlue : kEventMutedTeal;
    return Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
