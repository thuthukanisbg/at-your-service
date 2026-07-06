import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/currency.dart';
import '../../models/service_category.dart';
import 'customer_categories_service.dart';
import 'customer_mock_data.dart';
import 'customer_notifications_screen.dart';
import 'customer_notifications_service.dart';
import 'customer_search_screen.dart';
import 'customer_services_list_screen.dart';
import 'service_details_screen.dart';

/// Static list — there's no "cities" collection in Firestore to fetch from,
/// and services aren't location-scoped in the real data (no city field on
/// any `services` doc), so picking one only changes the displayed label,
/// not what's shown below it. Matches the pill's own existing static text.
const _availableLocations = [
  'Cape Town, South Africa',
  'Johannesburg, South Africa',
  'Durban, South Africa',
  'Pretoria, South Africa',
  'Port Elizabeth, South Africa',
  'Bloemfontein, South Africa',
];

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  static const routeName = '/customer';

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  late final Future<List<ServiceCategory>> _categoriesFuture = fetchActiveServiceCategories();
  late final Future<bool> _hasUnreadFuture =
      fetchMyNotifications().then((list) => list.any((n) => !n.read)).catchError((_) => false);
  String _location = _availableLocations.first;

  Future<void> _openLocationPicker(BuildContext context) async {
    final tokens = context.tokens;
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: tokens.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Text(
                    'Choose your location',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: tokens.tx),
                  ),
                ),
                for (final location in _availableLocations)
                  ListTile(
                    leading: Icon(
                      LucideIcons.mapPin,
                      size: 20,
                      color: location == _location ? AppColors.primary : tokens.mut,
                    ),
                    title: Text(location, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: tokens.tx)),
                    trailing: location == _location ? const Icon(LucideIcons.check, size: 18, color: AppColors.primary) : null,
                    onTap: () => Navigator.of(sheetContext).pop(location),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (selected != null && mounted) {
      setState(() => _location = selected);
    }
  }

  void _openServicesList(BuildContext context, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CustomerServicesListScreen(title: title)),
    );
  }

  void _goToService(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ServiceDetailsScreen()),
    );
  }

  void _openNotifications(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CustomerNotificationsScreen()),
    );
  }

  void _openSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CustomerSearchScreen()),
    );
  }

  Future<void> _openFilters(BuildContext context) async {
    final categories = await _categoriesFuture.catchError((_) => customerCategories);
    if (!context.mounted) return;
    final tokens = context.tokens;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: tokens.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Text(
                    'Filter by category',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: tokens.tx),
                  ),
                ),
                for (final category in categories)
                  ListTile(
                    leading: Icon(category.icon, size: 20, color: category.tint),
                    title: Text(category.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: tokens.tx)),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CustomerSearchScreen(initialCategoryId: category.id, initialCategoryName: category.name),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
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
                      InkWell(
                        onTap: () => _openLocationPicker(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.mapPin, size: 13, color: AppColors.primary),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                _location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: tokens.mut),
                              ),
                            ),
                            Icon(LucideIcons.chevronDown, size: 13, color: tokens.mut),
                          ],
                        ),
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
                FutureBuilder<bool>(
                  future: _hasUnreadFuture,
                  builder: (context, snapshot) => _NotificationButton(
                    hasUnread: snapshot.data ?? false,
                    onTap: () => _openNotifications(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _openSearch(context),
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
                  onTap: () => _openFilters(context),
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
            _RowHeader(title: 'Popular Services', onViewAll: () => _openServicesList(context, 'Popular Services')),
            const SizedBox(height: 13),
            FutureBuilder<List<ServiceCategory>>(
              future: _categoriesFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData && !snapshot.hasError) {
                  return const SizedBox(
                    height: 96,
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
                  );
                }
                final categories = snapshot.hasError ? customerCategories : snapshot.data!;
                return Row(
                  children: [
                    for (final category in categories) ...[
                      Expanded(
                        child: _CategoryTile(
                          category: category,
                          onTap: () => _goToService(context),
                        ),
                      ),
                      if (category != categories.last) const SizedBox(width: 10),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            _PromoCard(onTap: () => _goToService(context)),
            const SizedBox(height: 24),
            _RowHeader(title: 'Recommended', onViewAll: () => _openServicesList(context, 'Recommended')),
            const SizedBox(height: 13),
            _RecommendedCard(onTap: () => _goToService(context)),
          ],
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.onTap, required this.hasUnread});

  final VoidCallback onTap;
  final bool hasUnread;

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
            if (hasUnread)
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
  const _RowHeader({required this.title, required this.onViewAll});

  final String title;
  final VoidCallback onViewAll;

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
        InkWell(
          onTap: onViewAll,
          child: const Text(
            'View all',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.primary),
          ),
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
            if (category.price != null)
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
