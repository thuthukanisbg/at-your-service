import 'package:flutter/material.dart';

/// Brand accent colors — per the design handoff these are **identical in
/// light and dark mode**. Theme-variant tokens (background/surface/card/
/// border/text) live in [AppTheme]'s light/dark [ColorScheme]s instead,
/// since those genuinely differ by brightness.
abstract final class AppColors {
  static const Color primary = Color(0xFF2E7DFF);
  static const Color accent = Color(0xFFFFC107);
  static const Color accentOnAccent = Color(0xFF0B132B);
  static const Color success = Color(0xFF2ECC71);
  static const Color danger = Color(0xFFFF4D67);
  static const Color purple = Color(0xFF9B59B6);

  static const Color textOnPrimary = Color(0xFFFFFFFF);

  /// The handoff's hero/CTA gradient is `linear-gradient(120deg, #1E3ABA,
  /// #2E7DFF)`. These alignments approximate that 120° angle (Flutter has no
  /// direct angle API) — used by the role-select primary card and the
  /// customer home promo card, which share this exact gradient.
  static const List<Color> heroGradient = [Color(0xFF1E3ABA), primary];
  static const Alignment heroGradientBegin = Alignment(-1, -0.58);
  static const Alignment heroGradientEnd = Alignment(1, 0.58);
}
