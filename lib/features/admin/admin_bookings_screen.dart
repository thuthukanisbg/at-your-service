import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/currency.dart';
import 'admin_bookings_service.dart';
import 'admin_status_badge.dart';

/// Plain, functional bookings list for admin — no design-handoff spec
/// exists for this tab (same situation as Providers), so this follows the
/// app's existing tokens/card visual pattern rather than a pixel-perfect
/// match.
class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  late final Future<List<AdminBookingSummary>> _bookingsFuture = fetchAllBookings();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
          children: [
            Text(
              'Bookings',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: tokens.tx),
            ),
            const SizedBox(height: 4),
            Text(
              'Every booking on the platform.',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: tokens.mut),
            ),
            const SizedBox(height: 18),
            FutureBuilder<List<AdminBookingSummary>>(
              future: _bookingsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData && !snapshot.hasError) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text("Couldn't load bookings.", style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: tokens.mut)),
                    ),
                  );
                }
                final bookings = snapshot.data!;
                if (bookings.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text('No bookings yet.', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: tokens.mut)),
                    ),
                  );
                }
                return Column(children: [for (final b in bookings) _BookingRow(booking: b)]);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingRow extends StatelessWidget {
  const _BookingRow({required this.booking});

  final AdminBookingSummary booking;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tokens.card,
        border: Border.all(color: tokens.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.serviceName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: tokens.tx),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(LucideIcons.mapPin, size: 12, color: tokens.mut),
                    const SizedBox(width: 4),
                    Text(booking.city, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: tokens.mut)),
                    const SizedBox(width: 10),
                    Icon(LucideIcons.calendar, size: 12, color: tokens.mut),
                    const SizedBox(width: 4),
                    Text(booking.scheduleLabel, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: tokens.mut)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatRand(booking.price), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary)),
              const SizedBox(height: 4),
              StatusBadge(status: booking.status),
            ],
          ),
        ],
      ),
    );
  }
}
