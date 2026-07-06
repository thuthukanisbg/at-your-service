import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_tokens.dart';
import 'admin_desktop_mock_data.dart';
import 'admin_status_badge.dart';

/// No `transactions`/payouts collection exists in this app yet — this
/// renders the design handoff's own mock data verbatim. See
/// admin_desktop_mock_data.dart.
class AdminDesktopPayments extends StatelessWidget {
  const AdminDesktopPayments({super.key});

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
                        Text('Payments & Payouts', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.4, color: tokens.tx)),
                        const SizedBox(height: 3),
                        Text('R412,900 processed this month', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: tokens.mut)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(onPressed: null, icon: const Icon(LucideIcons.download, size: 14), label: const Text('Export')),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  for (var i = 0; i < mockPaymentStats.length; i++) ...[
                    Expanded(child: _StatCard(stat: mockPaymentStats[i])),
                    if (i != mockPaymentStats.length - 1) const SizedBox(width: 14),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(color: tokens.card, border: Border.all(color: tokens.line), borderRadius: BorderRadius.circular(16)),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: tokens.line))),
                      child: Text('Transactions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: tokens.tx)),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(tokens.elev),
                        columns: const [
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('Type')),
                          DataColumn(label: Text('Party')),
                          DataColumn(label: Text('Method')),
                          DataColumn(label: Text('Amount'), numeric: true),
                          DataColumn(label: Text('Date')),
                          DataColumn(label: Text('Status')),
                        ],
                        rows: [
                          for (final t in mockTransactions)
                            DataRow(cells: [
                              DataCell(Text(t.id, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: tokens.mut))),
                              DataCell(Text(t.type, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: tokens.tx))),
                              DataCell(Text(t.party, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: tokens.tx))),
                              DataCell(Text(t.method, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: tokens.mut))),
                              DataCell(Text(t.amount, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: tokens.tx))),
                              DataCell(Text(t.date, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: tokens.mut))),
                              DataCell(StatusBadge(status: t.status)),
                            ]),
                        ],
                      ),
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

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});
  final AdminPaymentStat stat;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(color: tokens.card, border: Border.all(color: tokens.line), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: stat.bg, borderRadius: BorderRadius.circular(9)),
            alignment: Alignment.center,
            child: Icon(stat.icon, size: 15, color: stat.color),
          ),
          const SizedBox(height: 12),
          Text(stat.value, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: -0.3, color: tokens.tx)),
          const SizedBox(height: 2),
          Text(stat.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: tokens.mut)),
        ],
      ),
    );
  }
}
