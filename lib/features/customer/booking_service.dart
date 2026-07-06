import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Thrown by [BookingService] with a message safe to show the user directly.
class BookingException implements Exception {
  const BookingException(this.message);
  final String message;
}

/// Wraps the Firestore booking write behind an overridable instance, same
/// pattern as [AuthService] — lets widget tests stub it without a live
/// Firebase app.
class BookingService {
  static BookingService instance = BookingService();

  /// Creates a new booking and returns its doc ID. `providerId` starts
  /// null — the booking is unassigned until a provider claims it via the
  /// "Available" tab.
  Future<String> createBooking({
    required String? serviceId,
    required String serviceName,
    required num price,
    required DateTime scheduledFor,
    String? notes,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw const BookingException('You need to be signed in to book a service.');
    }
    try {
      final ref = await FirebaseFirestore.instance.collection('bookings').add({
        'customerId': uid,
        // Real Firestore services doc ID, not the short category-slug style
        // seen in some historical booking docs (e.g. "electrical") — those
        // don't correspond to any doc in the current services collection.
        'serviceId': serviceId,
        'serviceName': serviceName,
        'price': price,
        'currency': 'ZAR',
        'status': 'pending',
        'providerId': null,
        'scheduledFor': Timestamp.fromDate(scheduledFor),
        // No saved-address feature exists yet (a known separate open item) —
        // same static placeholder the rest of this mock flow already uses.
        'address': '23 Loop Street, Cape Town',
        'city': 'Cape Town',
        'notes': notes ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } catch (_) {
      throw const BookingException("Couldn't confirm your booking — please try again.");
    }
  }
}

const _months = [
  'jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec',
];

/// Parses this screen's "22 May" + "02:00 PM" style labels into a real
/// DateTime, rolled forward a year if that day/month has already passed
/// this year — the date/time picker itself is still a fixed demo set of
/// options, not a real calendar, so this is the closest honest reading of
/// "the next time this date/time occurs."
DateTime parseScheduledFor(String dateLabel, String timeLabel) {
  final dateParts = dateLabel.trim().split(RegExp(r'\s+'));
  final day = int.tryParse(dateParts.isNotEmpty ? dateParts[0] : '') ?? 1;
  final monthName = (dateParts.length > 1 ? dateParts[1] : '').toLowerCase();
  final month = _months.indexOf(monthName) + 1;

  final timeMatch = RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM)', caseSensitive: false).firstMatch(timeLabel);
  var hour = 0;
  var minute = 0;
  if (timeMatch != null) {
    hour = int.parse(timeMatch.group(1)!) % 12;
    minute = int.parse(timeMatch.group(2)!);
    if (timeMatch.group(3)!.toUpperCase() == 'PM') hour += 12;
  }

  final now = DateTime.now();
  var year = now.year;
  var candidate = DateTime(year, month == 0 ? now.month : month, day, hour, minute);
  if (candidate.isBefore(now)) {
    year += 1;
    candidate = DateTime(year, month == 0 ? now.month : month, day, hour, minute);
  }
  return candidate;
}
