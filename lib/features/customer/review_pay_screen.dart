import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/currency.dart';
import '../../core/utils/schedule_format.dart';
import '../../core/widgets/detail_screen_header.dart';
import '../../core/widgets/primary_cta_button.dart';
import 'booking_service.dart';
import 'track_booking_screen.dart';

class ReviewPayScreen extends StatefulWidget {
  const ReviewPayScreen({
    super.key,
    required this.scheduledFor,
    required this.address,
    required this.serviceName,
    required this.price,
    this.serviceId,
    this.notes,
  });

  static const routeName = '/customer/pay';

  final DateTime scheduledFor;
  final String address;
  final String serviceName;
  final num price;
  final String? serviceId;
  final String? notes;

  @override
  State<ReviewPayScreen> createState() => _ReviewPayScreenState();
}

class _ReviewPayScreenState extends State<ReviewPayScreen> {
  bool _submitting = false;

  Future<void> _confirmBooking() async {
    setState(() => _submitting = true);
    try {
      final bookingId = await BookingService.instance.createBooking(
        serviceId: widget.serviceId,
        serviceName: widget.serviceName,
        price: widget.price,
        scheduledFor: widget.scheduledFor,
        address: widget.address,
        notes: widget.notes,
      );
      if (!mounted) return;
      // Guarded separately from the booking write above: this should never
      // block navigation on a successful booking — TrackBookingScreen just
      // falls back to its demo/mock look if this comes back null.
      String? customerId;
      try {
        customerId = FirebaseAuth.instance.currentUser?.uid;
      } catch (_) {
        customerId = null;
      }
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TrackBookingScreen(
            bookingId: bookingId,
            customerId: customerId,
            serviceName: widget.serviceName,
            // providerId stays null — the booking is unassigned right after
            // creation, so Chat correctly still shows "coming soon" until a
            // provider claims it (see TrackBookingScreen's _hasRealBooking).
          ),
        ),
      );
    } on BookingException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Couldn't confirm your booking — please try again."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final summary = [
      ('Service', widget.serviceName),
      ('Date', formatScheduleDate(widget.scheduledFor)),
      ('Time', formatScheduleTime(widget.scheduledFor)),
      ('Address', widget.address),
    ];
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 18),
              child: DetailScreenHeader(title: 'Review Booking'),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: tokens.card,
                border: Border.all(color: tokens.line),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  for (final row in summary)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: tokens.line)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            row.$1,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: tokens.mut,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              row.$2,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: tokens.tx,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: tokens.tx,
                          ),
                        ),
                        Text(
                          formatRand(widget.price),
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: tokens.elev,
                border: Border.all(color: tokens.line),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Online payments are not enabled yet. Confirming creates the booking, but you will not be charged.',
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: tokens.mut,
                ),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryCtaButton(
              label: _submitting ? 'Confirming…' : 'Confirm Booking',
              onPressed: _submitting ? null : _confirmBooking,
            ),
          ],
        ),
      ),
    );
  }
}
