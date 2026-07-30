import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/utils/schedule_format.dart';
import '../../models/provider_job.dart';

ProviderJob _toProviderJob(String id, Map<String, dynamic> data) {
  final scheduledFor = data['scheduledFor'];
  final timeLabel =
      scheduledFor is Timestamp ? formatSchedule(scheduledFor.toDate()) : '—';

  return ProviderJob(
    id: id,
    customerId: data['customerId'] as String?,
    title: data['serviceName'] as String? ?? 'Job',
    price: parsePrice(data['price']),
    timeLabel: timeLabel,
    // Real bookings have no distance/geo data at all — reusing this slot
    // for the booking's city, the closest real "where" info available.
    distanceLabel: data['city'] as String? ?? '—',
    address: data['address'] as String?,
  );
}

/// Fetches bookings already assigned to the signed-in provider — the
/// "Accepted" tab.
Future<List<ProviderJob>> fetchAssignedJobs() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return [];

  final snapshot =
      await FirebaseFirestore.instance
          .collection('bookings')
          .where('providerId', isEqualTo: uid)
          .get();

  return snapshot.docs
      .map((doc) => _toProviderJob(doc.id, doc.data()))
      .toList();
}

/// Thrown by [claimJob] with a message safe to show the user directly.
class ClaimException implements Exception {
  const ClaimException(this.message);
  final String message;
}

/// Claims an unassigned booking through the trusted Johannesburg backend.
/// The Cloud Function uses a Firestore transaction, so two providers can
/// never both receive a successful claim for the same job.
Future<void> claimJob(String bookingId) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    throw const ClaimException('You need to be signed in to accept a job.');
  }
  try {
    await FirebaseFunctions.instanceFor(
      region: 'africa-south1',
    ).httpsCallable('claimJob').call<void>({'bookingId': bookingId});
  } on FirebaseFunctionsException catch (error) {
    throw ClaimException(
      error.message ?? 'This job could not be accepted. Please try again.',
    );
  } catch (_) {
    throw const ClaimException(
      'This job could not be accepted. Please try again.',
    );
  }
}

/// Fetches unclaimed, still-open bookings any provider may browse and
/// claim — the "Available" tab.
///
/// Confirmed against live data: every 'pending' booking has `providerId`
/// null and every 'completed' one has it set, so `providerId == null &&
/// status == 'pending'` is the real "available job" definition (matches
/// the read rule added for this). Requires being signed in as a provider —
/// the deployed rule only grants this read to `isProvider()`.
Future<List<ProviderJob>> fetchAvailableJobs() async {
  final snapshot =
      await FirebaseFirestore.instance
          .collection('bookings')
          .where('providerId', isEqualTo: null)
          .where('status', isEqualTo: 'pending')
          .get();

  return snapshot.docs
      .map((doc) => _toProviderJob(doc.id, doc.data()))
      .toList();
}
