import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../disputes/dispute_service.dart';
import 'admin_status_badge.dart';

Color _priorityColor(String priority, Color mut) => switch (priority) {
  'High' => AppColors.danger,
  'Medium' => AppColors.accent,
  _ => mut,
};

/// Real `disputes` docs (see dispute_service.dart) — filed by customers/
/// providers from a real booking (`TrackBookingScreen`'s "Report a
/// problem" / `ProviderJobDetailsScreen`'s "Report an issue"). Admin can
/// move Open → Escalated/Resolved here; each transition notifies whoever
/// filed it via the real `notifications` collection.
class AdminDesktopDisputes extends StatefulWidget {
  const AdminDesktopDisputes({super.key});

  @override
  State<AdminDesktopDisputes> createState() => _AdminDesktopDisputesState();
}

const _tabs = ['All', 'Open', 'Escalated', 'Resolved'];

class _AdminDesktopDisputesState extends State<AdminDesktopDisputes> {
  List<AdminDisputeSummary>? _disputes;
  bool _loadFailed = false;
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final disputes = await fetchAllDisputes();
      if (!mounted) return;
      setState(() => _disputes = disputes);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadFailed = true);
    }
  }

  Future<void> _transition(AdminDisputeSummary dispute, String newStatus) async {
    try {
      await updateDisputeStatus(
        disputeId: dispute.id,
        newStatus: newStatus,
        filedBy: dispute.filedBy,
        subject: dispute.subject,
      );
      if (!mounted) return;
      setState(() {
        final index = _disputes!.indexWhere((d) => d.id == dispute.id);
        if (index != -1) {
          _disputes![index] = AdminDisputeSummary(
            id: dispute.id,
            subject: dispute.subject,
            description: dispute.description,
            customerName: dispute.customerName,
            providerName: dispute.providerName,
            priority: dispute.priority,
            status: newStatus,
            dateLabel: dispute.dateLabel,
            filedBy: dispute.filedBy,
          );
        }
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't update that report — please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final disputes = _disputes;
    final filtered = disputes == null
        ? null
        : (_filter == 'All' ? disputes : disputes.where((d) => d.status == _filter).toList());

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Disputes & Support', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.4, color: tokens.tx)),
              const SizedBox(height: 3),
              Text(
                disputes == null ? 'Reports filed by customers and providers.' : '${disputes.length} total reports',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: tokens.mut),
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
              if (disputes == null && !_loadFailed)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
                )
              else if (_loadFailed)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: Text("Couldn't load disputes.", style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: tokens.mut)),
                  ),
                )
              else if (filtered!.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: Text('No reports match this filter.', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: tokens.mut)),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(color: tokens.card, border: Border.all(color: tokens.line), borderRadius: BorderRadius.circular(16)),
                  clipBehavior: Clip.antiAlias,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(tokens.elev),
                      columns: const [
                        DataColumn(label: Text('Subject')),
                        DataColumn(label: Text('Customer')),
                        DataColumn(label: Text('Priority')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: [
                        for (final d in filtered)
                          DataRow(cells: [
                            DataCell(
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(d.subject, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: tokens.tx)),
                                  Text('vs ${d.providerName}', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: tokens.mut)),
                                ],
                              ),
                            ),
                            DataCell(Text(d.customerName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: tokens.tx))),
                            DataCell(Text(d.priority, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _priorityColor(d.priority, tokens.mut)))),
                            DataCell(StatusBadge(status: d.status)),
                            DataCell(Text(d.dateLabel, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: tokens.mut))),
                            DataCell(_ActionsCell(dispute: d, onTransition: (status) => _transition(d, status))),
                          ]),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionsCell extends StatelessWidget {
  const _ActionsCell({required this.dispute, required this.onTransition});

  final AdminDisputeSummary dispute;
  final ValueChanged<String> onTransition;

  @override
  Widget build(BuildContext context) {
    switch (dispute.status) {
      case 'Open':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton(onPressed: () => onTransition('Escalated'), child: const Text('Escalate')),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: () => onTransition('Resolved'), child: const Text('Resolve')),
          ],
        );
      case 'Escalated':
        return OutlinedButton(onPressed: () => onTransition('Resolved'), child: const Text('Resolve'));
      default:
        return const SizedBox.shrink();
    }
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
          decoration: BoxDecoration(border: Border.all(color: selected ? AppColors.primary : tokens.line), borderRadius: BorderRadius.circular(9)),
          child: Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: selected ? Colors.white : tokens.mut)),
        ),
      ),
    );
  }
}
