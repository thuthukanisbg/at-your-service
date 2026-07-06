import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/utils/schedule_format.dart';

class CustomerBookingSummary {
  const CustomerBookingSummary({
    required this.id,
    required this.serviceName,
    required this.price,
    required this.status,
    required this.scheduleLabel,
    required this.providerId,
  });

  final String id;
  final String serviceName;
  final double price;
  final String status;
  final String scheduleLabel;

  /// Null until a provider claims the booking — messaging only makes
  /// sense once there's someone on the other end.
  final String? providerId;
}

/// Fetches the signed-in customer's own bookings (any status).
Future<List<CustomerBookingSummary>> fetchMyBookings() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return [];

  final snapshot =
      await FirebaseFirestore.instance.collection('bookings').where('customerId', isEqualTo: uid).get();

  return snapshot.docs.map((doc) {
    final data = doc.data();
    final scheduledFor = data['scheduledFor'];
    return CustomerBookingSummary(
      id: doc.id,
      serviceName: data['serviceName'] as String? ?? 'Service',
      price: parsePrice(data['price']),
      status: data['status'] as String? ?? 'pending',
      scheduleLabel: scheduledFor is Timestamp ? formatSchedule(scheduledFor.toDate()) : '—',
      providerId: data['providerId'] as String?,
    );
  }).toList();
}
