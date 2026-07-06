import 'package:flutter/material.dart';

class ServiceCategory {
  const ServiceCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.tint,
    required this.chipBg,
    this.price,
  });

  final String id;
  final String name;
  final IconData icon;

  /// Icon color for this category's badge.
  final Color tint;

  /// Badge background — the handoff specifies this per category rather than
  /// a uniform tint alpha (e.g. Cleaning/Electrical use a .14 tint, Plumbing/
  /// Painting use .16), so it's a distinct field rather than derived from
  /// [tint] with a fixed alpha.
  final Color chipBg;

  /// "From R___" caption shown on the category card. Null when the source
  /// data has no price for this category (e.g. real Firestore
  /// serviceCategories docs don't carry one — price lives per-service).
  final String? price;
}
