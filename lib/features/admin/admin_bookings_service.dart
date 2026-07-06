import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/utils/schedule_format.dart';
import '../../core/utils/user_display_name.dart';

class AdminBookingSummary {
  const AdminBookingSummary({
    required this.id,
    required this.serviceName,
    required this.price,
    required this.status,
    required this.city,
    required this.scheduleLabel,
    required this.customerName,
    required this.providerName,
  });

  final String id;
  final String serviceName;
  final double price;
  final String status;
  final String city;
  final String scheduleLabel;
  final String customerName;
  final String providerName;
}

/// Booking docs only store `customerId`/`providerId` (see booking_service.dart),
/// display labels are shown Title Case to match the design handoff's status
/// badges (`Pending`, `Completed`, …) — the two real values seen in live
/// data (confirmed in provider_jobs_service.dart's own comment).
String _displayStatus(String raw) => switch (raw) {
  'pending' => 'Pending',
  'completed' => 'Completed',
  'confirmed' => 'Confirmed',
  'in_progress' => 'In Progress',
  'cancelled' => 'Cancelled',
  _ => raw,
};

/// Fetches every booking on the platform — permitted by the existing
/// `isAdmin()` clause in the deployed bookings read rule.
///
/// Customer/provider names aren't stored on the booking doc itself (only
/// their uids), so this resolves each distinct id once via the `users`
/// collection ([fetchUserDisplayName], already built for exactly this) and
/// the `providers` collection's own `displayName` field — a small, batched
/// join, not a per-row query.
Future<List<AdminBookingSummary>> fetchAllBookings() async {
  final snapshot = await FirebaseFirestore.instance.collection('bookings').get();
  final docs = snapshot.docs;

  final customerIds = docs.map((d) => d.data()['customerId'] as String?).whereType<String>().toSet();
  final providerIds = docs.map((d) => d.data()['providerId'] as String?).whereType<String>().toSet();

  final customerNames = Map.fromEntries(
    await Future.wait(customerIds.map((id) async => MapEntry(id, await fetchUserDisplayName(id) ?? '—'))),
  );
  final providerNames = Map.fromEntries(
    await Future.wait(providerIds.map((id) async {
      final doc = await FirebaseFirestore.instance.collection('providers').doc(id).get();
      return MapEntry(id, doc.data()?['displayName'] as String? ?? '—');
    })),
  );

  return docs.map((doc) {
    final data = doc.data();
    final scheduledFor = data['scheduledFor'];
    final customerId = data['customerId'] as String?;
    final providerId = data['providerId'] as String?;
    return AdminBookingSummary(
      id: 'BK-${doc.id.length >= 6 ? doc.id.substring(0, 6).toUpperCase() : doc.id.toUpperCase()}',
      serviceName: data['serviceName'] as String? ?? 'Service',
      price: parsePrice(data['price']),
      status: _displayStatus(data['status'] as String? ?? 'pending'),
      city: data['city'] as String? ?? '—',
      scheduleLabel: scheduledFor is Timestamp ? formatSchedule(scheduledFor.toDate()) : '—',
      customerName: customerId != null ? (customerNames[customerId] ?? '—') : '—',
      // Unclaimed bookings (providerId still null) have no provider yet —
      // '—' is the honest state, not a placeholder name.
      providerName: providerId != null ? (providerNames[providerId] ?? '—') : '—',
    );
  }).toList();
}
