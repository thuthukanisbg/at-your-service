import '../../core/theme/app_colors.dart';
import '../../models/admin_applicant.dart';

class AdminStat {
  const AdminStat({required this.value, required this.label, this.delta});
  final String value;
  final String label;

  /// Null when there's no real basis for a trend figure (no stored
  /// prior-period value to diff against) — the delta chip just isn't
  /// rendered in that case, rather than fabricating a percentage.
  final String? delta;
}

const adminStats = [
  AdminStat(value: '1,245', label: 'Total Bookings', delta: '+12%'),
  AdminStat(value: 'R24.5k', label: 'Revenue', delta: '+15%'),
  AdminStat(value: '256', label: 'Active Pros', delta: '+8%'),
];

class RevenueBar {
  const RevenueBar({required this.label, required this.heightFraction, this.highlighted = false});
  final String label;
  final double heightFraction;
  final bool highlighted;
}

const revenueBars = [
  RevenueBar(label: 'M', heightFraction: 0.40),
  RevenueBar(label: 'T', heightFraction: 0.62),
  RevenueBar(label: 'W', heightFraction: 0.48),
  RevenueBar(label: 'T', heightFraction: 0.78),
  RevenueBar(label: 'F', heightFraction: 0.92, highlighted: true),
  RevenueBar(label: 'S', heightFraction: 0.58),
  RevenueBar(label: 'S', heightFraction: 0.70),
];

const initialPendingApplicants = [
  AdminApplicant(initials: 'JM', name: 'John M.', role: 'Cleaning Specialist', avatarColor: AppColors.purple),
  AdminApplicant(initials: 'NP', name: 'Nomsa P.', role: 'Plumber', avatarColor: AppColors.primary),
  AdminApplicant(initials: 'TK', name: 'Themba K.', role: 'Electrician', avatarColor: AppColors.success),
];

/// Application details/checks are fixed generic mock content (the handoff's
/// one review example doesn't vary these per applicant) — the review screen
/// does still receive and display the tapped applicant's own name/role/
/// avatar correctly, just not these detail fields.
const applicantAppliedDate = 'Applied 30 May 2024';

const applicantDetails = [
  ('Experience', '3 years'),
  ('Area', 'Germiston, JHB'),
  ('Documents', '3 of 3 uploaded'),
];

class AdminCheck {
  const AdminCheck({required this.label, required this.verified});
  final String label;
  final bool verified;
}

const adminChecks = [
  AdminCheck(label: 'ID document', verified: true),
  AdminCheck(label: 'Selfie match', verified: true),
  AdminCheck(label: 'Proof of address', verified: true),
  AdminCheck(label: 'Background check', verified: false),
];
