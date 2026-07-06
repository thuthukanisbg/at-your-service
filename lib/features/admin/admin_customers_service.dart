import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/utils/currency.dart';
import '../../core/utils/schedule_format.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

class AdminCustomerSummary {
  const AdminCustomerSummary({
    required this.name,
    required this.email,
    required this.joined,
    required this.bookings,
    required this.spent,
    required this.hasBookings,
  });

  final String name;
  final String email;
  final String joined;
  final int bookings;
  final String spent;

  /// "Active"/"Inactive" isn't a stored field on real `users` docs — this
  /// is a derived heuristic (has at least one real booking), not fabricated
  /// backend state. Flagged so it isn't mistaken for a stored status.
  final bool hasBookings;
}

/// Real customers — `users/{uid}` docs with `role == 'customer'` (the same
/// role value `RoleSelectScreen._persistRole` writes). Booking count/spend
/// are computed by grouping the real `bookings` collection by `customerId`,
/// same join shape as `fetchAllBookings`'s customer/provider name
/// resolution — not a new collection, just an aggregation over two that
/// already exist. Real user docs have no "Status" field at all (confirmed
/// by grepping every users-doc read in this app), so `hasBookings` stands
/// in for it rather than inventing an Active/Inactive field.
Future<List<AdminCustomerSummary>> fetchCustomers() async {
  final usersSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'customer')
      .get();
  final bookingsSnapshot = await FirebaseFirestore.instance.collection('bookings').get();

  final bookingCounts = <String, int>{};
  final bookingSpend = <String, double>{};
  for (final doc in bookingsSnapshot.docs) {
    final data = doc.data();
    final customerId = data['customerId'] as String?;
    if (customerId == null) continue;
    bookingCounts[customerId] = (bookingCounts[customerId] ?? 0) + 1;
    bookingSpend[customerId] = (bookingSpend[customerId] ?? 0) + parsePrice(data['price']);
  }

  return usersSnapshot.docs.map((doc) {
    final data = doc.data();
    final displayName = data['displayName'] as String?;
    final legacyName = data['name'] as String?;
    final email = data['email'] as String?;
    final name = (displayName != null && displayName.isNotEmpty)
        ? displayName
        : (legacyName != null && legacyName.isNotEmpty ? legacyName : (email ?? 'Customer'));

    final createdAt = data['createdAt'];
    final joined = createdAt is Timestamp
        ? '${_months[createdAt.toDate().month - 1]} ${createdAt.toDate().year}'
        : '—';

    final count = bookingCounts[doc.id] ?? 0;
    return AdminCustomerSummary(
      name: name,
      email: email ?? '—',
      joined: joined,
      bookings: count,
      spent: formatRand(bookingSpend[doc.id] ?? 0),
      hasBookings: count > 0,
    );
  }).toList();
}
