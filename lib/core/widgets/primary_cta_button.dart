import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Full-width 54px primary CTA with the design handoff's colored glow shadow
/// (`0 12px 26px -10px rgba(...)`) — [ElevatedButton]'s `elevation` only
/// draws a plain Material drop shadow, so the glow is layered on with a
/// [Container] instead. Used for every "Continue"/"Confirm" style action in
/// the customer booking flow.
class PrimaryCtaButton extends StatelessWidget {
  const PrimaryCtaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.iconSize = 18,
    this.style,
    this.shadowColor = AppColors.primary,
    this.shadowAlpha = 0.7,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double iconSize;
  final ButtonStyle? style;
  final Color shadowColor;
  final double shadowAlpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: shadowAlpha),
            blurRadius: 26,
            offset: const Offset(0, 12),
            spreadRadius: -10,
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: onPressed,
          style: style,
          child: icon == null
              ? Text(label)
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: iconSize),
                    const SizedBox(width: 8),
                    Text(label),
                  ],
                ),
        ),
      ),
    );
  }
}
