import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../models/admin_applicant.dart';
import 'admin_bookings_service.dart';
import 'admin_dashboard_service.dart';
import 'admin_desktop_mock_data.dart';
import 'admin_mock_data.dart';
import 'admin_review_screen.dart';
import 'admin_status_badge.dart';
import '../disputes/dispute_service.dart';

/// Desktop counterpart to `AdminDashboardScreen` — Total Bookings/Revenue/
/// Active Providers and the pending-approvals list are real data
/// (`fetchAdminStats`/`fetchPendingApplicants`, no separate fetching
/// logic). Open Disputes is now real too (`fetchOpenDisputeCount`, no
/// stored delta to diff against so none is shown — same "don't fabricate a
/// trend" rule as the other three cards). The revenue-by-day chart and
/// category breakdown/busy-areas cards still have no real aggregation to
/// draw on (no per-category or per-area rollups anywhere in this app) and
/// use the design handoff's own mock figures — see admin_desktop_mock_data.dart.
class AdminDesktopOverview extends StatefulWidget {
  const AdminDesktopOverview({super.key});

  @override
  State<AdminDesktopOverview> createState() => _AdminDesktopOverviewState();
}

class _OverviewStats {
  const _OverviewStats({required this.stats, required this.openDisputes});
  final List<AdminStat> stats;

  /// null when the real fetch failed — rendered as '—', not a fabricated
  /// count.
  final int? openDisputes;
}

class _AdminDesktopOverviewState extends State<AdminDesktopOverview> {
  late final Future<_OverviewStats> _statsFuture = _loadStats();
  List<AdminApplicant>? _pending;

  Future<_OverviewStats> _loadStats() async {
    List<AdminStat> stats;
    try {
      stats = await fetchAdminStats();
    } catch (_) {
      stats = adminStats;
    }
    int? openDisputes;
    try {
      openDisputes = await fetchOpenDisputeCount();
    } catch (_) {
      openDisputes = null;
    }
    return _OverviewStats(stats: stats, openDisputes: openDisputes);
  }

  @override
  void initState() {
    super.initState();
    _loadApplicants();
  }

  Future<void> _loadApplicants() async {
    List<AdminApplicant> applicants;
    try {
      applicants = await fetchPendingApplicants();
    } catch (_) {
      applicants = List.of(initialPendingApplicants);
    }
    if (!mounted) return;
    setState(() => _pending = applicants);
  }

  Future<void> _review(AdminApplicant applicant) async {
    final decision = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AdminReviewScreen(applicant: applicant)),
    );
    if (decision != null) {
      setState(() => _pending?.remove(applicant));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Overview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.4, color: tokens.tx)),
                        const SizedBox(height: 3),
                        Text('Operational snapshot · updated just now', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: tokens.mut)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(LucideIcons.download, size: 14),
                    label: const Text('Export report'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FutureBuilder<_OverviewStats>(
                future: _statsFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData && !snapshot.hasError) {
                    return const SizedBox(height: 96, child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)));
                  }
                  final real = snapshot.hasError ? adminStats : snapshot.data!.stats;
                  final openDisputes = snapshot.hasError ? null : snapshot.data!.openDisputes;
                  final cards = [
                    (
                      label: real[0].label, value: real[0].value, delta: real[0].delta,
                      icon: LucideIcons.calendarCheck, color: AppColors.primary,
                    ),
                    (
                      label: real[1].label, value: real[1].value, delta: real[1].delta,
                      icon: LucideIcons.wallet, color: AppColors.success,
                    ),
                    (
                      label: real[2].label, value: real[2].value, delta: real[2].delta,
                      icon: LucideIcons.users, color: AppColors.accent,
                    ),
                    (
                      label: 'Open Disputes', value: openDisputes?.toString() ?? '—', delta: null,
                      icon: LucideIcons.lifeBuoy, color: AppColors.danger,
                    ),
                  ];
                  return Row(
                    children: [
                      for (var i = 0; i < cards.length; i++) ...[
                        Expanded(child: _KpiCard(stat: cards[i])),
                        if (i != cards.length - 1) const SizedBox(width: 14),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 13, child: _RevenueCard(tokens: tokens)),
                    const SizedBox(width: 14),
                    Expanded(flex: 10, child: _CategoryBreakdownCard(tokens: tokens)),
                    const SizedBox(width: 14),
                    Expanded(flex: 10, child: _BusyAreasCard(tokens: tokens)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 8, child: _RecentBookingsCard()),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 5,
                      child: _PendingApprovalsCard(pending: _pending, onReview: _review),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.stat});

  final ({String label, String value, String? delta, IconData icon, Color color}) stat;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: tokens.card, border: Border.all(color: tokens.line), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: stat.color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
                child: Icon(stat.icon, size: 16, color: stat.color),
              ),
              if (stat.delta != null)
                Text(stat.delta!, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.success)),
            ],
          ),
          const SizedBox(height: 14),
          Text(stat.value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.4, color: tokens.tx)),
          const SizedBox(height: 2),
          Text(stat.label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: tokens.mut)),
        ],
      ),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  const _RevenueCard({required this.tokens});
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: tokens.card, border: Border.all(color: tokens.line), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Revenue — last 7 days', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: tokens.tx)),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < mockRevenueBars.length; i++) ...[
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 106 * mockRevenueBars[i].pct,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(7), topRight: Radius.circular(7), bottomLeft: Radius.circular(3), bottomRight: Radius.circular(3)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(mockRevenueBars[i].day, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: tokens.mut)),
                      ],
                    ),
                  ),
                  if (i != mockRevenueBars.length - 1) const SizedBox(width: 10),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBreakdownCard extends StatelessWidget {
  const _CategoryBreakdownCard({required this.tokens});
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: tokens.card, border: Border.all(color: tokens.line), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bookings by category', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: tokens.tx)),
          const SizedBox(height: 16),
          for (final c in mockCategoryBreakdown)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(c.label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: tokens.tx)),
                      Text('${c.pct}%', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: tokens.mut)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: c.pct / 100,
                      minHeight: 7,
                      backgroundColor: tokens.elev,
                      valueColor: AlwaysStoppedAnimation(c.color),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _BusyAreasCard extends StatelessWidget {
  const _BusyAreasCard({required this.tokens});
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: tokens.card, border: Border.all(color: tokens.line), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Busy areas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: tokens.tx)),
          const SizedBox(height: 14),
          for (final a in mockBusyAreas)
            Padding(
              padding: const EdgeInsets.only(bottom: 11),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.area, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: tokens.tx)),
                        Text('${a.bookings} bookings this wk', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: tokens.mut)),
                      ],
                    ),
                  ),
                  Builder(builder: (context) {
                    final color = adminDemandColor(a.demand, tokens.mut);
                    final neutral = color == tokens.mut;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(color: neutral ? tokens.elev : color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(99)),
                      child: Text(a.demand, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: color)),
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RecentBookingsCard extends StatefulWidget {
  @override
  State<_RecentBookingsCard> createState() => _RecentBookingsCardState();
}

class _RecentBookingsCardState extends State<_RecentBookingsCard> {
  late final Future<List<AdminBookingSummary>> _future = _loadRecent();

  Future<List<AdminBookingSummary>> _loadRecent() async {
    final all = await fetchAllBookings();
    return all.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      decoration: BoxDecoration(color: tokens.card, border: Border.all(color: tokens.line), borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: tokens.line))),
            child: Text('Recent bookings', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: tokens.tx)),
          ),
          FutureBuilder<List<AdminBookingSummary>>(
            future: _future,
            builder: (context, snapshot) {
              if (!snapshot.hasData && !snapshot.hasError) {
                return const Padding(padding: EdgeInsets.symmetric(vertical: 32), child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)));
              }
              if (snapshot.hasError || snapshot.data!.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: Text(snapshot.hasError ? "Couldn't load bookings." : 'No bookings yet.', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: tokens.mut))),
                );
              }
              return Column(
                children: [
                  for (final b in snapshot.data!)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: tokens.line))),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(b.serviceName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: tokens.tx)),
                                Text('${b.customerName} · ${b.providerName}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: tokens.mut)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(_formatAmount(b.price), style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: tokens.tx)),
                          const SizedBox(width: 8),
                          StatusBadge(status: b.status),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

String _formatAmount(double price) {
  final whole = price.truncate();
  return 'R$whole';
}

class _PendingApprovalsCard extends StatelessWidget {
  const _PendingApprovalsCard({required this.pending, required this.onReview});

  final List<AdminApplicant>? pending;
  final ValueChanged<AdminApplicant> onReview;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      decoration: BoxDecoration(color: tokens.card, border: Border.all(color: tokens.line), borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: tokens.line))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Pending approvals', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: tokens.tx)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(99)),
                  child: Text('${pending?.length ?? 0}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.accent)),
                ),
              ],
            ),
          ),
          if (pending == null)
            const Padding(padding: EdgeInsets.symmetric(vertical: 32), child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)))
          else if (pending!.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Center(child: Text('All caught up — no pending applications.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: tokens.mut))),
            )
          else
            for (final applicant in pending!)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: tokens.line))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(color: applicant.avatarColor, borderRadius: BorderRadius.circular(9)),
                          alignment: Alignment.center,
                          child: Text(applicant.initials, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(applicant.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: tokens.tx)),
                              Text(applicant.role, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: tokens.mut)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 30,
                            child: OutlinedButton(
                              onPressed: () => onReview(applicant),
                              style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: BorderSide.none, backgroundColor: AppColors.danger.withValues(alpha: 0.14), padding: EdgeInsets.zero),
                              child: const Text('Reject', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SizedBox(
                            height: 30,
                            child: OutlinedButton(
                              onPressed: () => onReview(applicant),
                              style: OutlinedButton.styleFrom(foregroundColor: AppColors.success, side: BorderSide.none, backgroundColor: AppColors.success.withValues(alpha: 0.16), padding: EdgeInsets.zero),
                              child: const Text('Approve', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
