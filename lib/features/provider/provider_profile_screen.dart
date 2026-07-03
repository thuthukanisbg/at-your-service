import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import 'provider_mock_data.dart';
import 'verify_screen.dart';

class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 18),
              child: Column(
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: const Text('SM', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                              border: Border.all(color: tokens.surface, width: 3),
                            ),
                            child: const Icon(LucideIcons.check, size: 13, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text('Sipho M.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: tokens.tx)),
                  ),
                  Text(
                    'Cleaning Specialist · Cape Town',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: tokens.mut),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 9),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0x1F2ECC71), // rgba(46,204,113,.12)
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.shieldCheck, size: 14, color: AppColors.success),
                          SizedBox(width: 6),
                          Text('Verified Pro', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.success)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Row(
                children: [
                  for (var i = 0; i < providerStats.length; i++) ...[
                    Expanded(child: _StatTile(stat: providerStats[i])),
                    if (i != providerStats.length - 1) const SizedBox(width: 10),
                  ],
                ],
              ),
            ),
            Text('Verification status', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: tokens.tx)),
            const SizedBox(height: 11),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: tokens.card,
                border: Border.all(color: tokens.line),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  for (final item in providerVerificationMini)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: tokens.line))),
                      child: Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: item.verified ? const Color(0x242ECC71) : const Color(0x24FFC107),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              item.verified ? LucideIcons.check : LucideIcons.clock,
                              size: 14,
                              color: item.verified ? AppColors.success : AppColors.accent,
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Text(item.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: tokens.tx)),
                          ),
                          Text(
                            item.verified ? 'Verified' : 'Pending',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: item.verified ? AppColors.success : AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const VerifyScreen()),
              ),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tokens.card,
                  border: Border.all(color: tokens.line),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'View verification flow',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: tokens.tx),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.stat});

  final ProviderStat stat;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 15),
      decoration: BoxDecoration(
        color: tokens.card,
        border: Border.all(color: tokens.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(stat.value, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: stat.color ?? tokens.tx)),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(stat.label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: tokens.mut)),
          ),
        ],
      ),
    );
  }
}
