import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/currency.dart';
import '../../models/admin_applicant.dart';
import 'admin_mock_data.dart';

const _avatarPalette = [AppColors.purple, AppColors.primary, AppColors.success, AppColors.accent];

/// Total bookings, revenue, and active-provider counts from real data.
///
/// `delta` (the "+12%" style trend) has no real basis — there's no stored
/// prior-period figure to diff against — so it's left null here and simply
/// not rendered, rather than fabricating a percentage.
Future<List<AdminStat>> fetchAdminStats() async {
  final bookingsSnapshot = await FirebaseFirestore.instance.collection('bookings').get();

  var revenue = 0.0;
  for (final doc in bookingsSnapshot.docs) {
    // price is a string in most existing docs but a raw number in at least
    // one — same inconsistency seen in services.basePrice.
    final rawPrice = doc.data()['price'];
    revenue += rawPrice is num ? rawPrice.toDouble() : (double.tryParse(rawPrice?.toString() ?? '') ?? 0);
  }

  final providersSnapshot = await FirebaseFirestore.instance.collection('providers').get();
  final activeProviders = providersSnapshot.docs.where((doc) => doc.data()['status'] == 'active').length;

  return [
    AdminStat(value: '${bookingsSnapshot.docs.length}', label: 'Total Bookings'),
    AdminStat(value: formatRand(revenue), label: 'Revenue'),
    AdminStat(value: '$activeProviders', label: 'Active Pros'),
  ];
}

/// Provider applications awaiting an admin decision.
///
/// Real `providerApplications` statuses (confirmed against live data) are
/// `needs_updates`, `verified`, `approved`, `rejected` — there's no literal
/// 'pending' value. `verified` is the closest real analog to "awaiting an
/// admin approve/reject decision": it means the applicant's documents
/// already passed a first check and are sitting in the queue for the admin,
/// which is what the mock "Pending approvals" list represents.
Future<List<AdminApplicant>> fetchPendingApplicants() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('providerApplications')
      .where('status', isEqualTo: 'verified')
      .get();

  final applicants = <AdminApplicant>[];
  for (var i = 0; i < snapshot.docs.length; i++) {
    final data = snapshot.docs[i].data();
    // Two document shapes coexist in this collection (confirmed against
    // live data) — older ones use fullName/selectedServices, newer ones use
    // name/category.
    final name = (data['fullName'] as String?) ?? (data['name'] as String?) ?? 'Applicant';
    final selectedServices = data['selectedServices'];
    final role = (data['category'] as String?) ??
        (selectedServices is List && selectedServices.isNotEmpty ? selectedServices.join(', ') : 'Service Provider');
    applicants.add(AdminApplicant(
      initials: _initialsFor(name),
      name: name,
      role: role,
      avatarColor: _avatarPalette[i % _avatarPalette.length],
    ));
  }
  return applicants;
}

String _initialsFor(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
}
