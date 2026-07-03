import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import 'provider_mock_data.dart';

class ProviderEarningsScreen extends StatelessWidget {
  const ProviderEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
          children: [
            Text(
              'Earnings',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: tokens.tx),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: AppColors.heroGradientBegin,
                  end: AppColors.heroGradientEnd,
                  colors: AppColors.heroGradient,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.6),
                    blurRadius: 30,
                    offset: const Offset(0, 14),
                    spreadRadius: -12,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This month',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.85)),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 4, bottom: 2),
                    child: Text(
                      'R24,580',
                      style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -1, color: Colors.white),
                    ),
                  ),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.trendingUp, size: 15, color: Colors.white),
                      SizedBox(width: 5),
                      Text('+15% vs last month', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Row(
                children: [
                  Expanded(child: _StatBox(label: 'Jobs done', value: '128', tokens: tokens)),
                  const SizedBox(width: 10),
                  Expanded(child: _StatBox(label: 'Avg / job', value: 'R192', tokens: tokens)),
                ],
              ),
            ),
            Text('Recent payouts', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: tokens.tx)),
            const SizedBox(height: 11),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: tokens.card,
                border: Border.all(color: tokens.line),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  for (final payout in providerPayouts)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: tokens.line))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(payout.title, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: tokens.tx)),
                              Text(payout.date, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: tokens.mut)),
                            ],
                          ),
                          Text(payout.amount, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.success)),
                        ],
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

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value, required this.tokens});

  final String label;
  final String value;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: tokens.card,
        border: Border.all(color: tokens.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: tokens.mut)),
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: tokens.tx)),
          ),
        ],
      ),
    );
  }
}
