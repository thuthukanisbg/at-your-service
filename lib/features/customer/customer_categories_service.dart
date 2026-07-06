import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../models/service_category.dart';

/// Fetches active service categories from Firestore, sorted by `sortOrder`.
///
/// Sorted client-side rather than via `.orderBy('sortOrder')`: the real data
/// stores `sortOrder` as a string ("1", "850"...), so a Firestore-side sort
/// would be lexicographic (wrong for multi-digit values) and combining it
/// with `where('active', ...)` would need a composite index that isn't
/// deployed. Parsing and sorting here sidesteps both.
Future<List<ServiceCategory>> fetchActiveServiceCategories() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('serviceCategories')
      .where('active', isEqualTo: true)
      .get();

  final docs = snapshot.docs.toList()
    ..sort((a, b) {
      final aOrder = int.tryParse(a.data()['sortOrder']?.toString() ?? '') ?? 0;
      final bOrder = int.tryParse(b.data()['sortOrder']?.toString() ?? '') ?? 0;
      return aOrder.compareTo(bOrder);
    });

  return docs.map((doc) {
    final data = doc.data();
    final iconKey = (data['iconKey'] as String? ?? '').toLowerCase();
    final visuals = categoryIconVisuals[iconKey] ?? defaultCategoryVisuals;
    return ServiceCategory(
      id: doc.id,
      name: data['name'] as String? ?? 'Untitled',
      icon: visuals.icon,
      tint: visuals.tint,
      chipBg: visuals.chipBg,
    );
  }).toList();
}

class CategoryVisuals {
  const CategoryVisuals(this.icon, this.tint, this.chipBg);
  final IconData icon;
  final Color tint;
  final Color chipBg;
}

/// Public (not just used by [fetchActiveServiceCategories]) — the admin
/// desktop Catalog page reuses this same icon/color mapping rather than
/// duplicating it, since it renders the same real `serviceCategories` docs.
const defaultCategoryVisuals = CategoryVisuals(
  LucideIcons.wrench,
  AppColors.primary,
  Color(0x242E7DFF),
);

const categoryIconVisuals = {
  'cleaning': CategoryVisuals(LucideIcons.sparkles, AppColors.primary, Color(0x242E7DFF)),
  'plumbing': CategoryVisuals(LucideIcons.wrench, AppColors.accent, Color(0x29FFC107)),
  'electrical': CategoryVisuals(LucideIcons.zap, AppColors.success, Color(0x242ECC71)),
  'painting': CategoryVisuals(LucideIcons.paintbrush2, AppColors.purple, Color(0x299B59B6)),
  'home_repair': CategoryVisuals(LucideIcons.hammer, AppColors.accent, Color(0x29FFC107)),
};
