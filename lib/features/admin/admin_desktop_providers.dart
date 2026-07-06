import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import 'admin_providers_service.dart';
import 'admin_status_badge.dart';

/// Desktop counterpart to `AdminProvidersScreen` — same data
/// (`fetchProviders`, no separate fetching logic), reflowed to match the
/// Admin Dashboard design handoff's table layout.
///
/// Two deliberate deviations from the handoff, both because the real
/// `providers` collection doesn't carry the fields the handoff assumes:
/// - Filter tabs are All/Active/Suspended, not All/Verified/Pending/
///   Suspended — this app's providers only ever carry `status: 'active'`
///   or another value once suspended (confirmed in admin_providers_screen.dart);
///   "Pending" already means something specific elsewhere in this app (an
///   applicant awaiting approval, a different collection entirely — see
///   Overview's Pending Approvals), so reusing it here for an always-empty
///   tab would be actively misleading, not just an honest gap.
/// - Rating/Jobs/Joined columns render '—': no real provider doc has a
///   rating, completed-job count, or join date field anywhere in this app
///   today (confirmed by grepping every provider-facing screen) — showing
///   invented numbers there would be fabrication, not a UI gap.
class AdminDesktopProviders extends StatefulWidget {
  const AdminDesktopProviders({super.key});

  @override
  State<AdminDesktopProviders> createState() => _AdminDesktopProvidersState();
}

const _tabs = ['All', 'Active', 'Suspended'];

class _AdminDesktopProvidersState extends State<AdminDesktopProviders> {
  late final Future<List<AdminProviderSummary>> _providersFuture = fetchProviders();
  String _filter = 'All';

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
                        Text('Providers', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.4, color: tokens.tx)),
                        const SizedBox(height: 3),
                        FutureBuilder<List<AdminProviderSummary>>(
                          future: _providersFuture,
                          builder: (context, snapshot) => Text(
                            snapshot.hasData ? '${snapshot.data!.length} providers on the platform' : 'Everyone approved to work jobs on the platform.',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: tokens.mut),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: null,
                    icon: const Icon(LucideIcons.userPlus, size: 14),
                    label: const Text('Invite provider'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final tab in _tabs)
                    _FilterTab(label: tab, selected: _filter == tab, onTap: () => setState(() => _filter = tab)),
                ],
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<AdminProviderSummary>>(
                future: _providersFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData && !snapshot.hasError) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
                    );
                  }
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Text("Couldn't load providers.", style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: tokens.mut)),
                      ),
                    );
                  }
                  final displayed = snapshot.data!.map((p) {
                    final isActive = p.status == 'active';
                    return (provider: p, displayStatus: isActive ? 'Active' : 'Suspended');
                  }).where((row) => _filter == 'All' || row.displayStatus == _filter).toList();
                  if (displayed.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Text('No providers match this filter.', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: tokens.mut)),
                      ),
                    );
                  }
                  return Container(
                    decoration: BoxDecoration(
                      color: tokens.card,
                      border: Border.all(color: tokens.line),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(tokens.elev),
                        columns: const [
                          DataColumn(label: Text('Provider')),
                          DataColumn(label: Text('Category')),
                          DataColumn(label: Text('Rating')),
                          DataColumn(label: Text('Jobs')),
                          DataColumn(label: Text('Joined')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: [
                          for (final row in displayed)
                            DataRow(
                              cells: [
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(8)),
                                        alignment: Alignment.center,
                                        child: const Icon(LucideIcons.user, size: 15, color: AppColors.primary),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(row.provider.displayName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: tokens.tx)),
                                    ],
                                  ),
                                ),
                                DataCell(Text(row.provider.category, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: tokens.tx))),
                                DataCell(Text('—', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: tokens.mut))),
                                DataCell(Text('—', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: tokens.mut))),
                                DataCell(Text('—', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: tokens.mut))),
                                DataCell(StatusBadge(status: row.displayStatus)),
                                DataCell(
                                  OutlinedButton(onPressed: null, child: const Text('View')),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  const _FilterTab({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Material(
      color: selected ? AppColors.primary : tokens.card,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: selected ? AppColors.primary : tokens.line),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: selected ? Colors.white : tokens.mut)),
        ),
      ),
    );
  }
}
