import 'package:flutter/material.dart';

/// App-wide dark/light toggle. The app ships both `AppTheme.light()` and
/// `AppTheme.dark()` fully built (see app_theme.dart) but had no control
/// wired to switch between them — this is that control, first exposed by
/// the Admin desktop sidebar's theme toggle (see the Admin Dashboard design
/// handoff, which treats it as functional, not decorative).
class ThemeModeController {
  ThemeModeController._();

  static final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.dark);

  static void toggle() {
    mode.value = mode.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}
