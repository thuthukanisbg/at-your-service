import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/currency.dart';
import 'admin_bookings_service.dart';
import 'admin_status_badge.dart';

/// Desktop counterpart to `AdminBookingsScreen` — same data
/// (`fetchAllBookings`, no separate fetching logic), reflowed to match the
/// Admin Dashboard design handoff: status filter tabs + a table with
/// ID/Customer/Provider/Service/Date/Amount/Status columns. Only
/// "Pending"/"Completed" ever have real matches — the handoff's other tabs
/// (Confirmed/In Progress/Cancelled) reflect booking states this app's
/// lifecycle doesn't produce yet, so they render an honest empty table
/// rather than fabricated rows.
class AdminDesktopBookings extends StatefulWidget {
  const AdminDesktopBookings({super.key});

  @override
  State<AdminDesktopBookings> createState() => _AdminDesktopBookingsState();
}

const _tabs = ['All', 'Pending', 'Confirmed', 'In Progress', 'Completed', 'Cancelled'];

class _AdminDesktopBookingsState extends State<AdminDesktopBookings> {
  late final Future<List<AdminBookingSummary>> _bookingsFuture = fetchAllBookings();
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
                        Text('Bookings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.4, color: tokens.tx)),
                        const SizedBox(height: 3),
                        FutureBuilder<List<AdminBookingSummary>>(
                          future: _bookingsFuture,
                          builder: (context, snapshot) => Text(
                            snapshot.hasData ? '${snapshot.data!.length} total bookings' : 'Every booking on the platform.',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: tokens.mut),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(LucideIcons.download, size: 14),
                    label: const Text('Export'),
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
              FutureBuilder<List<AdminBookingSummary>>(
                future: _bookingsFuture,
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
                        child: Text("Couldn't load bookings.", style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: tokens.mut)),
                      ),
                    );
                  }
                  final bookings = _filter == 'All'
                      ? snapshot.data!
                      : snapshot.data!.where((b) => b.status == _filter).toList();
                  if (bookings.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Text('No bookings match this filter.', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: tokens.mut)),
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
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('Customer')),
                          DataColumn(label: Text('Provider')),
                          DataColumn(label: Text('Service')),
                          DataColumn(label: Text('Date')),
                          DataColumn(label: Text('Amount'), numeric: true),
                          DataColumn(label: Text('Status')),
                        ],
                        rows: [
                          for (final booking in bookings)
                            DataRow(
                              cells: [
                                DataCell(Text(booking.id, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: tokens.mut))),
                                DataCell(Text(booking.customerName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: tokens.tx))),
                                DataCell(Text(booking.providerName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: tokens.tx))),
                                DataCell(Text(booking.serviceName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: tokens.tx))),
                                DataCell(Text(booking.scheduleLabel, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: tokens.mut))),
                                DataCell(Text(formatRand(booking.price), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: tokens.tx))),
                                DataCell(StatusBadge(status: booking.status)),
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
