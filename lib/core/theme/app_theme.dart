import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_tokens.dart';
import 'scr_in_page_transitions.dart';

abstract final class AppTheme {
  /// CTA style for the "do the thing" actions the spec calls out in amber:
  /// Book Now. Distinct from the default (blue) [ElevatedButton] used for
  /// neutral confirm/continue actions.
  static final ButtonStyle amberAction = ElevatedButton.styleFrom(
    backgroundColor: AppColors.accent,
    foregroundColor: AppColors.accentOnAccent,
    disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.4),
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    textStyle: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w800,
    ),
  );

  static ThemeData light() => _build(Brightness.light, AppTokens.light);

  static ThemeData dark() => _build(Brightness.dark, AppTokens.dark);

  static ThemeData _build(Brightness brightness, AppTokens tokens) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    ).copyWith(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: tokens.surface,
      error: AppColors.danger,
      onSurface: tokens.tx,
      outline: tokens.line,
    );

    final base = GoogleFonts.manropeTextTheme(
      brightness == Brightness.dark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    );

    final textTheme = base.copyWith(
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 25,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
        color: tokens.tx,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
        color: tokens.tx,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 15.5,
        fontWeight: FontWeight.w800,
        color: tokens.tx,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: tokens.mut,
        height: 1.4,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
        color: tokens.mut,
        height: 1.45,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 15.5,
        fontWeight: FontWeight.w800,
        color: tokens.tx,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        color: tokens.mut,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: tokens.bg,
      textTheme: textTheme,
      extensions: [tokens],
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ScrInPageTransitionsBuilder(),
          TargetPlatform.iOS: ScrInPageTransitionsBuilder(),
          TargetPlatform.macOS: ScrInPageTransitionsBuilder(),
          TargetPlatform.linux: ScrInPageTransitionsBuilder(),
          TargetPlatform.windows: ScrInPageTransitionsBuilder(),
          TargetPlatform.fuchsia: ScrInPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: tokens.bg,
        foregroundColor: tokens.tx,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: tokens.card,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: tokens.line),
        ),
      ),
      dividerTheme: DividerThemeData(color: tokens.line, thickness: 1, space: 1),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          textStyle: textTheme.labelLarge?.copyWith(color: AppColors.textOnPrimary),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: tokens.tx,
          side: BorderSide(color: tokens.line),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: textTheme.labelLarge?.copyWith(color: AppColors.primary),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: tokens.chip,
        side: BorderSide(color: tokens.line),
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.card,
        hintStyle: textTheme.bodyMedium,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: tokens.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: tokens.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
