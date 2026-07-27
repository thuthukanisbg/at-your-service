import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../platform/platform_design.dart';
import '../theme/app_tokens.dart';

/// Applies platform-appropriate system bar styling while the Flutter content
/// remains shared. Android gets an edge-to-edge navigation bar that blends
/// into the app shell; iOS leaves the home-indicator region transparent and
/// lets the native controller choose the status-bar contrast.
class PlatformChrome extends StatelessWidget {
  const PlatformChrome({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final tokens = context.tokens;
    final dark = brightness == Brightness.dark;
    final style = context.usesCupertinoDesign
        ? SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarBrightness: dark ? Brightness.dark : Brightness.light,
            statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: dark
                ? Brightness.light
                : Brightness.dark,
          )
        : SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarBrightness: dark ? Brightness.dark : Brightness.light,
            statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: tokens.surface,
            systemNavigationBarDividerColor: tokens.line,
            systemNavigationBarIconBrightness: dark
                ? Brightness.light
                : Brightness.dark,
          );
    return AnnotatedRegion<SystemUiOverlayStyle>(value: style, child: child);
  }
}
