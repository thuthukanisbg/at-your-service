import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../models/service_category.dart';
import '../../models/service_listing.dart';

const customerCategories = [
  ServiceCategory(
    id: 'cleaning',
    name: 'Cleaning',
    icon: LucideIcons.sparkles,
    tint: AppColors.primary,
    chipBg: Color(0x242E7DFF), // rgba(46,125,255,.14)
    price: 'R600',
  ),
  ServiceCategory(
    id: 'plumbing',
    name: 'Plumbing',
    icon: LucideIcons.wrench,
    tint: AppColors.accent,
    chipBg: Color(0x29FFC107), // rgba(255,193,7,.16)
    price: 'R500',
  ),
  ServiceCategory(
    id: 'electrical',
    name: 'Electrical',
    icon: LucideIcons.zap,
    tint: AppColors.success,
    chipBg: Color(0x242ECC71), // rgba(46,204,113,.14)
    price: 'R600',
  ),
  ServiceCategory(
    id: 'painting',
    name: 'Painting',
    icon: LucideIcons.paintbrush2,
    tint: AppColors.purple,
    chipBg: Color(0x299B59B6), // rgba(155,89,182,.16)
    price: 'R550',
  ),
];

const customerRecommendedListing = ServiceListing(
  id: 'svc-deep-cleaning',
  categoryId: 'cleaning',
  title: 'Deep House Cleaning',
  providerName: null,
  rating: 4.8,
  reviewCount: 534,
  priceFrom: 600,
  durationLabel: '3–4 hrs',
);

const customerServiceDescription =
    'Professional deep cleaning for your entire home, handled by verified and background-checked pros.';

const customerServiceIncluded = [
  'Kitchen deep clean',
  'Bathroom sanitisation',
  'Floor & surface cleaning',
  'Dusting & more',
];
