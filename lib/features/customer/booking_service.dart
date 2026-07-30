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
    required String address,
    String? notes,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw const BookingException(
        'You need to be signed in to book a service.',
      );
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
        'address': address,
        'city': _cityFromAddress(address),
        'notes': notes ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } catch (_) {
      throw const BookingException(
        "Couldn't confirm your booking — please try again.",
      );
    }
  }
}

String _cityFromAddress(String address) {
  final parts = address
      .split(',')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();
  return parts.length > 1 ? parts.last : '';
}
