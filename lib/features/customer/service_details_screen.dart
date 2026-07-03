import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/currency.dart';
import '../../core/widgets/detail_screen_header.dart';
import '../../core/widgets/primary_cta_button.dart';
import 'book_schedule_screen.dart';
import 'customer_mock_data.dart';

class ServiceDetailsScreen extends StatelessWidget {
  const ServiceDetailsScreen({super.key});

  static const routeName = '/customer/service';

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final listing = customerRecommendedListing;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
              child: const DetailScreenHeader(title: 'Service Details'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                height: 182,
                decoration: BoxDecoration(color: tokens.elev, borderRadius: BorderRadius.circular(18)),
                child: const Icon(LucideIcons.sparkles, size: 36, color: AppColors.primary),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          listing.title,
                          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, letterSpacing: -0.4, color: tokens.tx),
                        ),
                      ),
                      Text(
                        'From ${formatRand(listing.priceFrom)}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.star, size: 15, color: AppColors.accent),
                        const SizedBox(width: 6),
                        Text('${listing.rating}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: tokens.tx)),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '(${listing.reviewCount} reviews)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: tokens.mut),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text('·', style: TextStyle(color: tokens.line)),
                        ),
                        const SizedBox(width: 6),
                        Icon(LucideIcons.clock, size: 14, color: tokens.mut),
                        const SizedBox(width: 6),
                        Text(
                          listing.durationLabel,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: tokens.mut),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      customerServiceDescription,
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, height: 1.55, color: tokens.mut),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 18),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: tokens.card,
                      border: Border.all(color: tokens.line),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        for (final item in customerServiceIncluded)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: tokens.line))),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: const Color(0x242E7DFF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(LucideIcons.check, size: 15, color: AppColors.primary),
                                ),
                                const SizedBox(width: 11),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: tokens.tx),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  PrimaryCtaButton(
                    label: 'Continue',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const BookScheduleScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
