import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Static content for the desktop Admin Dashboard sections that have no
/// backing Firestore data yet: Payments & Payouts — plus Overview's
/// "category breakdown"/"busy areas" widgets, which need aggregations
/// (bookings by category, bookings by area) this app doesn't compute
/// anywhere. Discounts (part of Service Catalog) are here too — no
/// discount/promo data exists anywhere in this app's real data.
///
/// Customers, Service Catalog's category cards, Team & Roles, and Disputes
/// & Support (incl. Overview's "Open Disputes" KPI) were originally mocked
/// here too but are now wired to real data — see admin_customers_service.dart,
/// admin_catalog_service.dart, admin_team_service.dart, and
/// dispute_service.dart.
///
/// Transcribed verbatim from the design handoff's own `renderVals()` mock
/// arrays (`Admin Dashboard.dc.html`) — same "build the mock UI before
/// wiring real data" approach every other screen in this app used first
/// (see admin_mock_data.dart for the mobile Admin screens' equivalent).
/// Replace with real reads once those collections/aggregations exist.

class AdminPaymentStat {
  const AdminPaymentStat({required this.label, required this.value, required this.icon, required this.color, required this.bg});
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bg;
}

final mockPaymentStats = [
  AdminPaymentStat(label: 'Total Revenue (MTD)', value: 'R412,900', icon: Icons.account_balance_wallet_outlined, color: AppColors.success, bg: AppColors.success.withValues(alpha: 0.14)),
  AdminPaymentStat(label: 'Pending Payouts', value: 'R18,240', icon: Icons.schedule, color: AppColors.accent, bg: AppColors.accent.withValues(alpha: 0.14)),
  AdminPaymentStat(label: 'Refunds Issued', value: 'R6,150', icon: Icons.undo, color: AppColors.danger, bg: AppColors.danger.withValues(alpha: 0.14)),
  AdminPaymentStat(label: 'Platform Fees Earned', value: 'R41,290', icon: Icons.percent, color: AppColors.primary, bg: AppColors.primary.withValues(alpha: 0.14)),
];

class AdminTransaction {
  const AdminTransaction({
    required this.id,
    required this.type,
    required this.party,
    required this.method,
    required this.amount,
    required this.date,
    required this.status,
  });

  final String id;
  final String type;
  final String party;
  final String method;
  final String amount;
  final String date;
  final String status;
}

const mockTransactions = [
  AdminTransaction(id: 'TX-9021', type: 'Payment', party: 'Thandi N. → Sipho M.', method: 'Visa••4242', amount: 'R600', date: '20 Jun', status: 'Success'),
  AdminTransaction(id: 'TX-9020', type: 'Payout', party: 'Sipho M.', method: 'Bank EFT', amount: 'R540', date: '20 Jun', status: 'Success'),
  AdminTransaction(id: 'TX-9019', type: 'Payment', party: 'David P. → Ayesha P.', method: 'Instant EFT', amount: 'R2,400', date: '19 Jun', status: 'Success'),
  AdminTransaction(id: 'TX-9018', type: 'Refund', party: 'Grace M.', method: 'Visa••8871', amount: 'R950', date: '18 Jun', status: 'Success'),
  AdminTransaction(id: 'TX-9017', type: 'Payout', party: 'Kagiso D.', method: 'Bank EFT', amount: 'R675', date: '18 Jun', status: 'Pending'),
  AdminTransaction(id: 'TX-9016', type: 'Payment', party: 'Naledi T. → Sipho M.', method: 'Visa••2210', amount: 'R380', date: '17 Jun', status: 'Failed'),
  AdminTransaction(id: 'TX-9015', type: 'Payout', party: 'Ayesha P.', method: 'Bank EFT', amount: 'R2,160', date: '17 Jun', status: 'Success'),
  AdminTransaction(id: 'TX-9014', type: 'Payment', party: 'Chris B. → Kagiso D.', method: 'Instant EFT', amount: 'R1,650', date: '16 Jun', status: 'Success'),
];

class AdminDiscount {
  const AdminDiscount({
    required this.code,
    required this.discount,
    required this.category,
    required this.expires,
    required this.uses,
    required this.status,
  });

  final String code;
  final String discount;
  final String category;
  final String expires;
  final int uses;
  final String status;
}

const mockDiscounts = [
  AdminDiscount(code: 'CLEAN20', discount: '20% off', category: 'Cleaning', expires: '31 Jul 2026', uses: 184, status: 'Active'),
  AdminDiscount(code: 'WELCOME50', discount: 'R50 off first booking', category: 'All categories', expires: '—', uses: 920, status: 'Active'),
  AdminDiscount(code: 'PLUMB15', discount: '15% off', category: 'Plumbing', expires: '15 Jul 2026', uses: 47, status: 'Active'),
  AdminDiscount(code: 'WINTER10', discount: '10% off', category: 'Painting', expires: '30 Jun 2026', uses: 63, status: 'Expired'),
  AdminDiscount(code: 'REFER100', discount: 'R100 off', category: 'All categories', expires: '—', uses: 312, status: 'Active'),
];

/// Overview widgets with no real aggregation available (see file doc comment).
class AdminCategoryShare {
  const AdminCategoryShare({required this.label, required this.pct, required this.color});
  final String label;
  final int pct;
  final Color color;
}

const mockCategoryBreakdown = [
  AdminCategoryShare(label: 'Cleaning', pct: 38, color: AppColors.primary),
  AdminCategoryShare(label: 'Plumbing', pct: 24, color: AppColors.success),
  AdminCategoryShare(label: 'Electrical', pct: 22, color: AppColors.accent),
  AdminCategoryShare(label: 'Painting', pct: 16, color: AppColors.purple),
];

class AdminBusyArea {
  const AdminBusyArea({required this.area, required this.bookings, required this.demand});
  final String area;
  final int bookings;
  final String demand;
}

const mockBusyAreas = [
  AdminBusyArea(area: 'Cape Town CBD', bookings: 412, demand: 'High'),
  AdminBusyArea(area: 'Sandton, JHB', bookings: 356, demand: 'High'),
  AdminBusyArea(area: 'Umhlanga, Durban', bookings: 198, demand: 'Medium'),
  AdminBusyArea(area: 'Soweto', bookings: 143, demand: 'Medium'),
  AdminBusyArea(area: 'Pretoria East', bookings: 89, demand: 'Low'),
];

Color adminDemandColor(String demand, Color mut) => switch (demand) {
  'High' => AppColors.danger,
  'Medium' => AppColors.accent,
  _ => mut,
};

const mockRevenueBars = [
  (day: 'Mon', pct: 0.62),
  (day: 'Tue', pct: 0.74),
  (day: 'Wed', pct: 0.58),
  (day: 'Thu', pct: 0.88),
  (day: 'Fri', pct: 0.95),
  (day: 'Sat', pct: 0.70),
  (day: 'Sun', pct: 0.45),
];
