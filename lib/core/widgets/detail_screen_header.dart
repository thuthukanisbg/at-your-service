import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../theme/app_tokens.dart';

/// Back button + title row shared by every pushed detail screen in the
/// customer booking flow (Service Details, Book & Schedule, Review & Pay,
/// Rate & Review) — identical spacing/sizing across all of them in the
/// design handoff.
class DetailScreenHeader extends StatelessWidget {
  const DetailScreenHeader({super.key, required this.title, this.onBack});

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Row(
      children: [
        InkWell(
          onTap: onBack ?? () => Navigator.of(context).pop(),
          borderRadius: BorderRadius.circular(11),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: tokens.card,
              border: Border.all(color: tokens.line),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(LucideIcons.chevronLeft, size: 19, color: tokens.tx),
          ),
        ),
        const SizedBox(width: 12),
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: tokens.tx)),
      ],
    );
  }
}
