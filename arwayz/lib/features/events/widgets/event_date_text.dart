// Date and time formatting helpers.
//
// The project does not depend on `intl` (it is absent from both pubspec.yaml
// and pubspec.lock), so `DateFormat` is unavailable and these are hand-rolled.

const List<String> _months = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const List<String> _weekdays = <String>[
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

/// `4 November 2026`
String formatEventDate(DateTime date) {
  return '${date.day} ${_months[date.month - 1]} ${date.year}';
}

/// `Wednesday, 4 November 2026`
String formatEventDateWithWeekday(DateTime date) {
  return '${_weekdays[date.weekday - 1]}, ${formatEventDate(date)}';
}

/// `Nov`, for the compact date badge on a list row.
String formatShortMonth(DateTime date) {
  return _months[date.month - 1].substring(0, 3);
}

/// `09:00`
String formatEventTime(DateTime time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

/// `09:00 - 16:00`, or `4 Nov 09:00 - 5 Nov 11:00` when the event spans days.
String formatEventTimeRange(DateTime start, DateTime end) {
  final sameDay =
      start.year == end.year && start.month == end.month && start.day == end.day;
  if (sameDay) {
    return '${formatEventTime(start)} - ${formatEventTime(end)}';
  }
  return '${formatEventDate(start)} ${formatEventTime(start)} '
      '- ${formatEventDate(end)} ${formatEventTime(end)}';
}
