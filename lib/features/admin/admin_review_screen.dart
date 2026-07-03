import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/detail_screen_header.dart';
import '../../models/admin_applicant.dart';
import 'admin_mock_data.dart';

/// Pops with `true` if approved, `false` if rejected, or `null` if the user
/// just navigated back without deciding.
class AdminReviewScreen extends StatelessWidget {
  const AdminReviewScreen({super.key, required this.applicant});

  final AdminApplicant applicant;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 18),
              child: DetailScreenHeader(title: 'Provider Review'),
            ),
            Container(
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: tokens.card,
                border: Border.all(color: tokens.line),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(color: applicant.avatarColor, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Text(applicant.initials, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(applicant.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: tokens.tx)),
                        Text(applicant.role, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: tokens.mut)),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(applicantAppliedDate, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: tokens.mut)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Text('Application details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: tokens.tx)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: tokens.card,
                border: Border.all(color: tokens.line),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  for (final detail in applicantDetails)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: tokens.line))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(detail.$1, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: tokens.mut)),
                          Text(detail.$2, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: tokens.tx)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Text('Verification checks', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: tokens.tx)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              margin: const EdgeInsets.only(bottom: 22),
              decoration: BoxDecoration(
                color: tokens.card,
                border: Border.all(color: tokens.line),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  for (final check in adminChecks)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: tokens.line))),
                      child: Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: check.verified ? const Color(0x242ECC71) : const Color(0x24FFC107),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              check.verified ? LucideIcons.check : LucideIcons.clock,
                              size: 14,
                              color: check.verified ? AppColors.success : AppColors.accent,
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Text(check.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: tokens.tx)),
                          ),
                          Text(
                            check.verified ? 'Verified' : 'Pending',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: check.verified ? AppColors.success : AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: _DecisionButton(
                    label: 'Reject',
                    icon: LucideIcons.x,
                    color: AppColors.danger,
                    onTap: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: _DecisionButton(
                    label: 'Approve',
                    icon: LucideIcons.check,
                    color: AppColors.success,
                    onTap: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DecisionButton extends StatelessWidget {
  const _DecisionButton({required this.label, required this.icon, required this.color, required this.onTap});

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 52,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: Colors.white),
            const SizedBox(width: 7),
            Text(label, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
