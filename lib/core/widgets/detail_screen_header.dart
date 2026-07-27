import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../platform/platform_design.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// Shared detail header that preserves one navigation contract while adapting
/// its title alignment and back affordance to the active mobile platform.
class DetailScreenHeader extends StatelessWidget {
  const DetailScreenHeader({super.key, required this.title, this.onBack});

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    if (context.usesCupertinoDesign) {
      return SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: CupertinoButton(
                // Supports the repository's Dart/Flutter 3.29 floor while
                // remaining valid on the 3.32 CI toolchain.
                // ignore: deprecated_member_use
                minSize: 44,
                padding: EdgeInsets.zero,
                onPressed: onBack ?? () => Navigator.of(context).pop(),
                child: const Icon(
                  CupertinoIcons.chevron_back,
                  size: 23,
                  color: AppColors.primary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 52),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: tokens.tx,
                ),
              ),
            ),
          ],
        ),
      );
    }
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
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: tokens.tx,
          ),
        ),
      ],
    );
  }
}
