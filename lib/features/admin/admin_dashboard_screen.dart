import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../models/admin_applicant.dart';
import 'admin_mock_data.dart';
import 'admin_review_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final List<AdminApplicant> _pending = List.of(initialPendingApplicants);

  Future<void> _review(AdminApplicant applicant) async {
    final decision = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AdminReviewScreen(applicant: applicant)),
    );
    if (decision != null) {
      setState(() => _pending.remove(applicant));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Admin · Operations', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: tokens.mut)),
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            'Dashboard',
                            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: tokens.tx),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                    decoration: BoxDecoration(
                      color: tokens.card,
                      border: Border.all(color: tokens.line),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('This Month', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: tokens.mut)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Row(
                children: [
                  for (var i = 0; i < adminStats.length; i++) ...[
                    Expanded(child: _StatCard(stat: adminStats[i])),
                    if (i != adminStats.length - 1) const SizedBox(width: 9),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: tokens.card,
                border: Border.all(color: tokens.line),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Revenue trend', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: tokens.tx)),
                        const Text('+15%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 88,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (var i = 0; i < revenueBars.length; i++) ...[
                          Expanded(child: _RevenueBarColumn(bar: revenueBars[i])),
                          if (i != revenueBars.length - 1) const SizedBox(width: 7),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      for (var i = 0; i < revenueBars.length; i++) ...[
                        Expanded(
                          child: Text(
                            revenueBars[i].label,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: tokens.mut),
                          ),
                        ),
                        if (i != revenueBars.length - 1) const SizedBox(width: 7),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pending approvals', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: tokens.tx)),
                  Text('${_pending.length} new', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ],
              ),
            ),
            for (final applicant in _pending)
              _PendingApplicantCard(applicant: applicant, onTap: () => _review(applicant)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final AdminStat stat;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: tokens.card,
        border: Border.all(color: tokens.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(stat.value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3, color: tokens.tx)),
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(stat.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: tokens.mut)),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(stat.delta, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.success)),
          ),
        ],
      ),
    );
  }
}

class _RevenueBarColumn extends StatelessWidget {
  const _RevenueBarColumn({required this.bar});

  final RevenueBar bar;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88 * bar.heightFraction,
      decoration: BoxDecoration(
        color: bar.highlighted ? AppColors.accent : AppColors.primary,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
      ),
    );
  }
}

class _PendingApplicantCard extends StatelessWidget {
  const _PendingApplicantCard({required this.applicant, required this.onTap});

  final AdminApplicant applicant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(13),
        margin: const EdgeInsets.only(bottom: 11),
        decoration: BoxDecoration(
          color: tokens.card,
          border: Border.all(color: tokens.line),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: applicant.avatarColor, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(applicant.initials, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(applicant.name, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: tokens.tx)),
                  Text(applicant.role, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: tokens.mut)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: const Color(0x1FFFC107), borderRadius: BorderRadius.circular(999)),
              child: const Text('Pending', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.accent)),
            ),
            const SizedBox(width: 8),
            Icon(LucideIcons.chevronRight, size: 18, color: tokens.mut),
          ],
        ),
      ),
    );
  }
}
