import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import 'admin_providers_service.dart';

/// A plain, functional providers directory — there's no design-handoff
/// spec for this bottom-nav tab (its own "Providers" nav button just links
/// to the provider-review screen, and the README lists it as a nav label
/// with no described screen content), so this follows the app's existing
/// visual conventions (tokens/card/border pattern used everywhere else)
/// rather than a pixel-perfect handoff match.
class AdminProvidersScreen extends StatefulWidget {
  const AdminProvidersScreen({super.key});

  @override
  State<AdminProvidersScreen> createState() => _AdminProvidersScreenState();
}

class _AdminProvidersScreenState extends State<AdminProvidersScreen> {
  late final Future<List<AdminProviderSummary>> _providersFuture = fetchProviders();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
          children: [
            Text(
              'Providers',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: tokens.tx),
            ),
            const SizedBox(height: 4),
            Text(
              'Everyone approved to work jobs on the platform.',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: tokens.mut),
            ),
            const SizedBox(height: 18),
            FutureBuilder<List<AdminProviderSummary>>(
              future: _providersFuture,
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
                      child: Text(
                        "Couldn't load providers.",
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: tokens.mut),
                      ),
                    ),
                  );
                }
                final providers = snapshot.data!;
                if (providers.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'No providers yet.',
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: tokens.mut),
                      ),
                    ),
                  );
                }
                return Column(
                  children: [for (final provider in providers) _ProviderCard(provider: provider)],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({required this.provider});

  final AdminProviderSummary provider;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isActive = provider.status == 'active';
    final statusColor = isActive ? AppColors.success : AppColors.danger;
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
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.14), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const Icon(LucideIcons.user, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: tokens.tx),
                ),
                const SizedBox(height: 2),
                Text(
                  '${provider.category} · ${provider.location} · ${provider.experience} yrs',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: tokens.mut),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
            child: Text(
              isActive ? 'Active' : provider.status,
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: statusColor),
            ),
          ),
        ],
      ),
    );
  }
}
