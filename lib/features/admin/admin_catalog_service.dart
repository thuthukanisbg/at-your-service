import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/utils/currency.dart';
import '../../core/utils/schedule_format.dart';
import '../customer/customer_categories_service.dart';
import 'admin_providers_service.dart';

class AdminCatalogCategory {
  const AdminCatalogCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.bg,
    required this.priceLabel,
    required this.durationLabel,
    required this.activeProviders,
    required this.active,
  });

  final String name;
  final IconData icon;
  final Color color;
  final Color bg;

  /// '—' when no active `services` doc references this category — a real
  /// gap, not a fabricated price.
  final String priceLabel;
  final String durationLabel;
  final int activeProviders;

  /// Real `serviceCategories.active` boolean — "Active"/"Paused" in the UI.
  final bool active;
}

/// Real service categories — every `serviceCategories` doc (not just active
/// ones, unlike the customer-facing [fetchActiveServiceCategories]: an
/// admin catalog view needs to show paused categories too, not hide them).
/// Base price/avg. duration are computed by averaging the real `services`
/// docs that reference each category (`services.categoryId`) — not a
/// stored per-category field. Active-provider counts reuse [fetchProviders]
/// and this app's real `providers.category` field (a plain name string, not
/// a categoryId reference — matched by name, same as the mobile Admin
/// Providers screen already does).
Future<List<AdminCatalogCategory>> fetchCatalog() async {
  final categoriesSnapshot = await FirebaseFirestore.instance.collection('serviceCategories').get();
  final servicesSnapshot = await FirebaseFirestore.instance.collection('services').where('active', isEqualTo: true).get();
  final providers = await fetchProviders();

  final pricesByCategoryId = <String, List<double>>{};
  final durationsByCategoryId = <String, List<int>>{};
  for (final doc in servicesSnapshot.docs) {
    final data = doc.data();
    final categoryId = data['categoryId'] as String?;
    if (categoryId == null) continue;
    pricesByCategoryId.putIfAbsent(categoryId, () => []).add(parsePrice(data['basePrice']));
    final minutes = int.tryParse(data['estimatedDurationMinutes']?.toString() ?? '');
    if (minutes != null) durationsByCategoryId.putIfAbsent(categoryId, () => []).add(minutes);
  }

  final activeProvidersByCategory = <String, int>{};
  for (final p in providers) {
    if (p.status != 'active') continue;
    activeProvidersByCategory[p.category] = (activeProvidersByCategory[p.category] ?? 0) + 1;
  }

  final docs = categoriesSnapshot.docs.toList()
    ..sort((a, b) {
      final aOrder = int.tryParse(a.data()['sortOrder']?.toString() ?? '') ?? 0;
      final bOrder = int.tryParse(b.data()['sortOrder']?.toString() ?? '') ?? 0;
      return aOrder.compareTo(bOrder);
    });

  return docs.map((doc) {
    final data = doc.data();
    final iconKey = (data['iconKey'] as String? ?? '').toLowerCase();
    final visuals = categoryIconVisuals[iconKey] ?? defaultCategoryVisuals;
    final name = data['name'] as String? ?? 'Untitled';

    final prices = pricesByCategoryId[doc.id];
    final priceLabel = (prices == null || prices.isEmpty)
        ? '—'
        : formatRand(prices.reduce((a, b) => a + b) / prices.length);

    final durations = durationsByCategoryId[doc.id];
    final durationLabel = (durations == null || durations.isEmpty)
        ? '—'
        : _formatDuration(durations.reduce((a, b) => a + b) ~/ durations.length);

    return AdminCatalogCategory(
      name: name,
      icon: visuals.icon,
      color: visuals.tint,
      bg: visuals.chipBg,
      priceLabel: priceLabel,
      durationLabel: durationLabel,
      activeProviders: activeProvidersByCategory[name] ?? 0,
      active: data['active'] == true,
    );
  }).toList();
}

String _formatDuration(int minutes) {
  if (minutes < 60) return '$minutes mins';
  return minutes % 60 == 0 ? '${minutes ~/ 60} hrs' : '${(minutes / 60).toStringAsFixed(1)} hrs';
}
