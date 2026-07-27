import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android native settings meet the FlutterFire minimums', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();

    expect(gradle, contains('ndkVersion = "27.0.12077973"'));
    expect(gradle, contains('minSdk = 23'));
  });

  test('iOS deployment target is consistently set to 15.0', () {
    final podfile = File('ios/Podfile').readAsStringSync();
    final frameworkInfo =
        File('ios/Flutter/AppFrameworkInfo.plist').readAsStringSync();
    final xcodeProject =
        File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();

    expect(podfile, contains("platform :ios, '15.0'"));
    expect(frameworkInfo, contains('<string>15.0</string>'));
    expect(
      RegExp(r'IPHONEOS_DEPLOYMENT_TARGET = 15\.0;').allMatches(xcodeProject),
      hasLength(3),
    );
  });

  test('public role assignment cannot self-promote to admin', () {
    final rules = File('firestore.rules').readAsStringSync();

    expect(
      rules,
      contains("request.resource.data.role in ['customer', 'provider']"),
    );
    expect(
      rules,
      contains(
        "get(/databases/\$(database)/documents/providers/\$(uid())).data.status == 'active'",
      ),
    );
  });
}
