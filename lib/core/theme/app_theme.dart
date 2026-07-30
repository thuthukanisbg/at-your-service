import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../platform/platform_design.dart';
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
    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
  );

  static ThemeData light({TargetPlatform? platform}) => _build(
    Brightness.light,
    AppTokens.light,
    platform ?? defaultTargetPlatform,
  );

  static ThemeData dark({TargetPlatform? platform}) => _build(
    Brightness.dark,
    AppTokens.dark,
    platform ?? defaultTargetPlatform,
  );

  static ThemeData _build(
    Brightness brightness,
    AppTokens tokens,
    TargetPlatform platform,
  ) {
    final designPlatform = PlatformDesign.resolve(platform);
    final isCupertino = designPlatform == AppDesignPlatform.ios;
    final controlRadius = isCupertino ? 12.0 : 16.0;
    final cardRadius = isCupertino ? 16.0 : 20.0;
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

    final base = (brightness == Brightness.dark
            ? ThemeData.dark().textTheme
            : ThemeData.light().textTheme)
        .apply(fontFamily: 'Manrope');

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
      platform: platform,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: tokens.bg,
      textTheme: textTheme,
      extensions: [tokens],
      splashFactory:
          isCupertino ? NoSplash.splashFactory : InkSparkle.splashFactory,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity:
          isCupertino ? VisualDensity.standard : VisualDensity.comfortable,
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: brightness,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: tokens.bg,
        barBackgroundColor: tokens.surface,
        textTheme: CupertinoTextThemeData(
          primaryColor: tokens.tx,
          textStyle: textTheme.bodyMedium,
          actionTextStyle: textTheme.labelLarge?.copyWith(
            color: AppColors.primary,
          ),
          navTitleTextStyle: textTheme.titleMedium,
          navLargeTitleTextStyle: textTheme.headlineSmall,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: ScrInPageTransitionsBuilder(),
          TargetPlatform.windows: ScrInPageTransitionsBuilder(),
          TargetPlatform.fuchsia: ScrInPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: tokens.bg,
        foregroundColor: tokens.tx,
        elevation: 0,
        centerTitle: isCupertino,
        toolbarHeight: isCupertino ? 44 : 64,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: tokens.card,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(color: tokens.line, width: isCupertino ? 0.75 : 1),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: tokens.line,
        thickness: 1,
        space: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(controlRadius),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            color: AppColors.textOnPrimary,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: tokens.tx,
          side: BorderSide(color: tokens.line),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(controlRadius),
          ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isCupertino ? 10 : 100),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: tokens.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.16),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 22,
            color:
                states.contains(WidgetState.selected)
                    ? AppColors.primary
                    : tokens.mut,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color:
                states.contains(WidgetState.selected)
                    ? AppColors.primary
                    : tokens.mut,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: tokens.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: !isCupertino,
        dragHandleColor: tokens.mut.withValues(alpha: 0.45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(isCupertino ? 18 : 28),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.card,
        hintStyle: textTheme.bodyMedium,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(color: tokens.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(color: tokens.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
