const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// Formats a booking's `scheduledFor` DateTime as e.g. "9 Jun · 12:00 PM".
String formatSchedule(DateTime dt) {
  final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final period = dt.hour < 12 ? 'AM' : 'PM';
  final minute = dt.minute.toString().padLeft(2, '0');
  return '${dt.day} ${_months[dt.month - 1]} · $hour12:$minute $period';
}

/// price/basePrice fields are strings in most existing Firestore docs but a
/// raw number in a few (e.g. QA-created ones) — coerce either way.
double parsePrice(Object? raw) {
  if (raw is num) return raw.toDouble();
  return double.tryParse(raw?.toString() ?? '') ?? 0;
}
