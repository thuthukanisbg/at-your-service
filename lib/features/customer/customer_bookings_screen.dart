import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/currency.dart';
import '../messaging/conversation_screen.dart';
import 'customer_bookings_service.dart';
import 'track_booking_screen.dart';

/// Plain, functional bookings list — no design-handoff spec exists for this
/// tab, so this follows the app's existing tokens/card visual pattern
/// rather than a pixel-perfect match.
class CustomerBookingsScreen extends StatefulWidget {
  const CustomerBookingsScreen({super.key});

  @override
  State<CustomerBookingsScreen> createState() => _CustomerBookingsScreenState();
}

class _CustomerBookingsScreenState extends State<CustomerBookingsScreen> {
  late final Future<List<CustomerBookingSummary>> _bookingsFuture =
      fetchMyBookings();

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
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: tokens.tx,
              ),
            ),
            const SizedBox(height: 18),
            FutureBuilder<List<CustomerBookingSummary>>(
              future: _bookingsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData && !snapshot.hasError) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        "Couldn't load bookings.",
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: tokens.mut,
                        ),
                      ),
                    ),
                  );
                }
                final bookings = snapshot.data!;
                if (bookings.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'No bookings yet.',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: tokens.mut,
                        ),
                      ),
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final b in bookings) _BookingCard(booking: b),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final CustomerBookingSummary booking;

  /// Looks up the assigned provider's real display name — used by both the
  /// "Message" chip (opens the conversation directly) and tapping the card
  /// (opens the real TrackBookingScreen, chat included).
  Future<String> _providerName() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('providers')
              .doc(booking.providerId)
              .get();
      return doc.data()?['displayName'] as String? ?? booking.serviceName;
    } catch (_) {
      return booking.serviceName;
    }
  }

  Future<void> _openConversation(BuildContext context) async {
    final providerId = booking.providerId;
    if (providerId == null) return;
    final customerId = FirebaseAuth.instance.currentUser?.uid;
    if (customerId == null) return;
    final otherPartyName = await _providerName();
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => ConversationScreen(
              bookingId: booking.id,
              customerId: customerId,
              providerId: providerId,
              serviceName: booking.serviceName,
              otherPartyName: otherPartyName,
            ),
      ),
    );
  }

  Future<void> _openTracking(BuildContext context) async {
    final providerId = booking.providerId;
    if (providerId == null) return;
    final customerId = FirebaseAuth.instance.currentUser?.uid;
    if (customerId == null) return;
    final otherPartyName = await _providerName();
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => TrackBookingScreen(
              bookingId: booking.id,
              customerId: customerId,
              providerId: providerId,
              serviceName: booking.serviceName,
              otherPartyName: otherPartyName,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isCompleted = booking.status == 'completed';
    final statusColor = isCompleted ? AppColors.success : AppColors.accent;
    return InkWell(
      onTap: booking.providerId != null ? () => _openTracking(context) : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: tokens.card,
          border: Border.all(color: tokens.line),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    booking.serviceName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: tokens.tx,
                    ),
                  ),
                ),
                Text(
                  formatRand(booking.price),
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(LucideIcons.calendar, size: 13, color: tokens.mut),
                const SizedBox(width: 5),
                Text(
                  booking.scheduleLabel,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: tokens.mut,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    isCompleted ? 'Completed' : booking.status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                ),
                if (booking.providerId != null) ...[
                  const Spacer(),
                  InkWell(
                    onTap: () => _openConversation(context),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.messageCircle,
                            size: 12,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'Message',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
