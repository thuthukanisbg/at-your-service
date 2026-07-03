import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/currency.dart';
import '../../models/service_category.dart';
import 'customer_mock_data.dart';
import 'service_details_screen.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  static const routeName = '/customer';

  void _comingSoon(BuildContext context, String what) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$what arrives in the next milestone.')),
    );
  }

  void _goToService(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ServiceDetailsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.mapPin, size: 13, color: AppColors.primary),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              'Cape Town, South Africa',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: tokens.mut),
                            ),
                          ),
                          Icon(LucideIcons.chevronDown, size: 13, color: tokens.mut),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hello, Thandi 👋',
                        style: theme.textTheme.headlineSmall?.copyWith(fontSize: 22, letterSpacing: -0.5),
                      ),
                      Text('How can we help you today?', style: theme.textTheme.bodyLarge),
                    ],
                  ),
                ),
                _NotificationButton(onTap: () => _comingSoon(context, 'Notifications')),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _comingSoon(context, 'Search'),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: tokens.card,
                        border: Border.all(color: tokens.line),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.search, size: 18, color: tokens.mut),
                          const SizedBox(width: 9),
                          Flexible(
                            child: Text(
                              'Search for a service…',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: tokens.mut),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () => _comingSoon(context, 'Filters'),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(LucideIcons.slidersHorizontal, size: 19, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _RowHeader(title: 'Popular Services'),
            const SizedBox(height: 13),
            Row(
              children: [
                for (final category in customerCategories) ...[
                  Expanded(
                    child: _CategoryTile(
                      category: category,
                      onTap: () => _goToService(context),
                    ),
                  ),
                  if (category != customerCategories.last) const SizedBox(width: 10),
                ],
              ],
            ),
            const SizedBox(height: 24),
            _PromoCard(onTap: () => _goToService(context)),
            const SizedBox(height: 24),
            _RowHeader(title: 'Recommended'),
            const SizedBox(height: 13),
            _RecommendedCard(onTap: () => _goToService(context)),
          ],
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: tokens.card,
          border: Border.all(color: tokens.line),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(LucideIcons.bell, size: 19, color: tokens.tx),
            Positioned(
              top: 9,
              right: 10,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RowHeader extends StatelessWidget {
  const _RowHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: tokens.tx),
          ),
        ),
        const Text(
          'View all',
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.primary),
        ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.onTap});

  final ServiceCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 6),
        decoration: BoxDecoration(
          color: tokens.card,
          border: Border.all(color: tokens.line),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: category.chipBg,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(category.icon, size: 21, color: category.tint),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: tokens.tx),
            ),
            Text(
              'From ${category.price}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: tokens.mut),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Book a trusted pro today',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white, height: 1.25),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 13),
                    child: Text(
                      'Get the job done right, the first time.',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.85)),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Book Now',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.accentOnAccent),
                        ),
                        SizedBox(width: 6),
                        Icon(LucideIcons.arrowRight, size: 15, color: AppColors.accentOnAccent),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(LucideIcons.hardHat, size: 40, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendedCard extends StatelessWidget {
  const _RecommendedCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final listing = customerRecommendedListing;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: tokens.card,
          border: Border.all(color: tokens.line),
          borderRadius: BorderRadius.circular(18),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              color: tokens.elev,
              child: const Icon(LucideIcons.sparkles, size: 32, color: AppColors.primary),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          listing.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: tokens.tx),
                        ),
                      ),
                      Text(
                        'From ${formatRand(listing.priceFrom)}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(LucideIcons.star, size: 14, color: AppColors.accent),
                      const SizedBox(width: 5),
                      Text(
                        '${listing.rating}',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: tokens.tx),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${listing.reviewCount} reviews)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: tokens.mut),
                      ),
                    ],
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
