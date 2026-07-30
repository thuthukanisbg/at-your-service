import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android native settings meet the FlutterFire minimums', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    final settings = File('android/settings.gradle.kts').readAsStringSync();

    expect(gradle, contains('ndkVersion = "27.0.12077973"'));
    expect(gradle, contains('minSdk = 23'));
    expect(
      settings,
      contains('id("org.jetbrains.kotlin.android") version "2.0.0"'),
    );
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
    expect(rules, contains("request.resource.data.role == 'customer'"));
    expect(
      rules,
      contains(
        "get(/databases/\$(database)/documents/providers/\$(uid())).data.status == 'active'",
      ),
    );
  });

  test(
    'job claims and chat identities are protected by trusted boundaries',
    () {
      final rules = File('firestore.rules').readAsStringSync();
      final functions = File('functions/src/index.ts').readAsStringSync();

      expect(
        rules,
        isNot(
          contains(
            "resource.data.get('providerId', null) == uid()\n"
            "        && request.resource.data.providerId == uid()",
          ),
        ),
      );
      expect(
        rules,
        contains('request.resource.data.providerId == booking().providerId'),
      );
      expect(rules, contains('request.resource.data.text.size() <= 2000'));
      expect(functions, contains('export const updateJobStatus'));
      expect(functions, contains('status: "accepted"'));
    },
  );

  test('admin-managed profiles are limited to customer and provider roles', () {
    final rules = File('firestore.rules').readAsStringSync();

    expect(
      rules,
      contains(
        "isAdmin()\n"
        "                && request.resource.data.role in ['customer', 'provider']",
      ),
    );
  });
}
