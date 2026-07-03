import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/detail_screen_header.dart';
import '../../core/widgets/primary_cta_button.dart';
import 'track_booking_screen.dart';

enum _PayMethod { card, eft }

class ReviewPayScreen extends StatefulWidget {
  const ReviewPayScreen({super.key, required this.selectedDate, required this.selectedTime});

  static const routeName = '/customer/pay';

  final String selectedDate;
  final String selectedTime;

  @override
  State<ReviewPayScreen> createState() => _ReviewPayScreenState();
}

class _ReviewPayScreenState extends State<ReviewPayScreen> {
  _PayMethod _method = _PayMethod.card;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final summary = [
      ('Service', 'Deep House Cleaning'),
      ('Date', '${widget.selectedDate} 2024'),
      ('Time', widget.selectedTime),
      ('Address', '23 Loop Street, Cape Town'),
    ];
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 18),
              child: DetailScreenHeader(title: 'Review & Pay'),
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
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: tokens.line))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(row.$1, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: tokens.mut)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              row.$2,
                              textAlign: TextAlign.right,
                              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: tokens.tx),
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
                        Text('Total', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: tokens.tx)),
                        const Text('R600', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.primary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Text('Payment Method', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: tokens.tx)),
            const SizedBox(height: 11),
            _PayMethodTile(
              icon: LucideIcons.creditCard,
              label: 'Visa •••• 4242',
              selected: _method == _PayMethod.card,
              onTap: () => setState(() => _method = _PayMethod.card),
            ),
            const SizedBox(height: 10),
            _PayMethodTile(
              icon: LucideIcons.building2,
              label: 'Instant EFT',
              selected: _method == _PayMethod.eft,
              onTap: () => setState(() => _method = _PayMethod.eft),
            ),
            const SizedBox(height: 24),
            PrimaryCtaButton(
              label: 'Confirm & Pay R600',
              icon: LucideIcons.lock,
              iconSize: 17,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TrackBookingScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayMethodTile extends StatelessWidget {
  const _PayMethodTile({required this.icon, required this.label, required this.selected, required this.onTap});

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: tokens.card,
          border: Border.all(color: selected ? AppColors.primary : tokens.line, width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 26,
              decoration: BoxDecoration(color: tokens.chip, borderRadius: BorderRadius.circular(6)),
              child: Icon(icon, size: 17, color: tokens.tx),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: tokens.tx)),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: selected ? AppColors.primary : tokens.mut, width: 2),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
