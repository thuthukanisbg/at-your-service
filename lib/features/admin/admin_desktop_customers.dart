import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_tokens.dart';
import '../../models/user_role.dart';
import 'admin_customers_service.dart';
import 'admin_management_dialogs.dart';
import 'admin_responsive_table.dart';
import 'admin_status_badge.dart';

/// Real customers — `users` docs with `role == 'customer'`, joined against
/// `bookings` for count/spend. See admin_customers_service.dart for exactly
/// what's real vs. derived (the "Active"/"Inactive" status is a derived
/// heuristic — has ≥1 real booking — not a stored field).
class AdminDesktopCustomers extends StatefulWidget {
  const AdminDesktopCustomers({super.key});

  @override
  State<AdminDesktopCustomers> createState() => _AdminDesktopCustomersState();
}

Future<List<AdminCustomerSummary>> _loadCustomers() async {
  await Future<void>.delayed(Duration.zero);
  return fetchCustomers();
}

class _AdminDesktopCustomersState extends State<AdminDesktopCustomers> {
  Future<List<AdminCustomerSummary>> _customersFuture = _loadCustomers();

  void _reloadCustomers() {
    final completer = Completer<List<AdminCustomerSummary>>();
    setState(() {
      _customersFuture = completer.future;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        completer.complete(await fetchCustomers());
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
        child: SizedBox(
          width: double.infinity,
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
                        Text(
                          'Customers',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: tokens.tx,
                          ),
                        ),
                        const SizedBox(height: 3),
                        FutureBuilder<List<AdminCustomerSummary>>(
                          future: _customersFuture,
                          builder:
                              (context, snapshot) => Text(
                                snapshot.hasData
                                    ? '${snapshot.data!.length} registered customers'
                                    : 'Everyone who has ever signed up as a customer.',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: tokens.mut,
                                ),
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: null,
                        icon: const Icon(LucideIcons.download, size: 14),
                        label: const Text('Export'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed:
                            () => showAddManagedUserDialog(
                              context: context,
                              role: UserRole.customer,
                              onCreated: _reloadCustomers,
                            ),
                        icon: const Icon(LucideIcons.userPlus, size: 14),
                        label: const Text('Add customer'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FutureBuilder<List<AdminCustomerSummary>>(
                future: _customersFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData && !snapshot.hasError) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Text(
                          "Couldn't load customers.",
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: tokens.mut,
                          ),
                        ),
                      ),
                    );
                  }
                  final customers = snapshot.data!;
                  if (customers.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Text(
                          'No customers yet.',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: tokens.mut,
                          ),
                        ),
                      ),
                    );
                  }
                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: tokens.card,
                      border: Border.all(color: tokens.line),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: AdminResponsiveDataTable(
                      table: DataTable(
                        headingRowColor: WidgetStateProperty.all(tokens.elev),
                        columnSpacing: 64,
                        horizontalMargin: 24,
                        columns: const [
                          DataColumn(label: Text('Customer')),
                          DataColumn(label: Text('Joined')),
                          DataColumn(label: Text('Bookings'), numeric: true),
                          DataColumn(label: Text('Spent'), numeric: true),
                          DataColumn(label: Text('Status')),
                        ],
                        rows: [
                          for (final c in customers)
                            DataRow(
                              cells: [
                                DataCell(
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.name,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: tokens.tx,
                                        ),
                                      ),
                                      Text(
                                        c.email,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: tokens.mut,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    c.joined,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: tokens.mut,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '${c.bookings}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: tokens.tx,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    c.spent,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: tokens.tx,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  StatusBadge(
                                    status:
                                        c.hasBookings ? 'Active' : 'Inactive',
                                  ),
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
