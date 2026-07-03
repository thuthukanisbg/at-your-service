import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/currency.dart';
import '../../core/widgets/detail_screen_header.dart';
import '../../core/widgets/primary_cta_button.dart';
import '../../models/provider_job.dart';
import 'provider_mock_data.dart';
import 'provider_navigate_screen.dart';

class ProviderJobDetailsScreen extends StatelessWidget {
  const ProviderJobDetailsScreen({super.key, required this.job});

  final ProviderJob job;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final jobInfo = [
      (LucideIcons.mapPin, 'Address', providerJobAddress),
      (LucideIcons.user, 'Customer', providerJobCustomer),
      (LucideIcons.banknote, 'Payout', '${formatRand(job.price * 0.9)} (after 10% fee)'),
    ];
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 18),
              child: DetailScreenHeader(title: 'Job Details'),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job.title, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: tokens.tx)),
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            job.timeLabel,
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: tokens.mut),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(formatRand(job.price), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary)),
                ],
              ),
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
                  for (final row in jobInfo)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: tokens.line))),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(color: tokens.chip, borderRadius: BorderRadius.circular(10)),
                            child: Icon(row.$1, size: 16, color: AppColors.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(row.$2, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: tokens.mut)),
                                Padding(
                                  padding: const EdgeInsets.only(top: 1),
                                  child: Text(
                                    row.$3,
                                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: tokens.tx),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 22),
              decoration: BoxDecoration(
                color: const Color(0x1AFFC107), // rgba(255,193,7,.1)
                border: Border.all(color: const Color(0x4DFFC107)), // rgba(255,193,7,.3)
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.info, size: 14, color: AppColors.accent),
                        SizedBox(width: 6),
                        Text('CUSTOMER NOTES', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.accent)),
                      ],
                    ),
                  ),
                  Text(
                    providerJobCustomerNote,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.5, color: tokens.tx),
                  ),
                ],
              ),
            ),
            PrimaryCtaButton(
              label: 'Accept Job',
              style: AppTheme.amberAction,
              shadowColor: AppColors.accent,
              shadowAlpha: 0.6,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProviderNavigateScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
