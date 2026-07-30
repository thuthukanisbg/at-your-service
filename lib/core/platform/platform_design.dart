import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// The app keeps one Flutter feature/data layer, then adapts presentation at
/// the platform boundary. This avoids parallel iOS/Android screen trees while
/// still allowing native-feeling motion, controls, navigation, and spacing.
enum AppDesignPlatform { ios, android, other }

abstract final class PlatformDesign {
  static AppDesignPlatform resolve(TargetPlatform platform) {
    return switch (platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => AppDesignPlatform.ios,
      TargetPlatform.android => AppDesignPlatform.android,
      _ => AppDesignPlatform.other,
    };
  }

  static TargetPlatform get current => defaultTargetPlatform;
}

extension PlatformDesignContext on BuildContext {
  TargetPlatform get targetPlatform => Theme.of(this).platform;

  AppDesignPlatform get designPlatform =>
      PlatformDesign.resolve(targetPlatform);

  bool get usesCupertinoDesign => designPlatform == AppDesignPlatform.ios;

  bool get usesMaterialDesign => designPlatform == AppDesignPlatform.android;

  double get controlRadius => usesCupertinoDesign ? 12 : 16;

  double get cardRadius => usesCupertinoDesign ? 16 : 20;

  double get phonePreviewRadius => usesCupertinoDesign ? 42 : 28;
}
