import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:at_your_service/core/theme/app_theme.dart';
import 'package:at_your_service/core/widgets/detail_screen_header.dart';
import 'package:at_your_service/core/widgets/role_nav_shell.dart';

Widget _roleShellHarness(TargetPlatform platform) {
  return MaterialApp(
    theme: AppTheme.dark(platform: platform),
    home: const RoleNavShell(
      tabs: [
        NavTab(
          icon: LucideIcons.home,
          selectedIcon: LucideIcons.home,
          label: 'Home',
          body: Center(child: Text('Home body')),
        ),
        NavTab(
          icon: LucideIcons.user,
          selectedIcon: LucideIcons.user,
          label: 'Profile',
          body: Center(child: Text('Profile body')),
        ),
      ],
    ),
  );
}

Widget _headerHarness(TargetPlatform platform) {
  return MaterialApp(
    key: ValueKey(platform),
    theme: AppTheme.dark(platform: platform),
    home: const Scaffold(
      body: SafeArea(
        child: DetailScreenHeader(title: 'Service Details', onBack: _noop),
      ),
    ),
  );
}

void _noop() {}

void main() {
  test('themes select native route motion per mobile platform', () {
    final ios = AppTheme.dark(platform: TargetPlatform.iOS);
    final android = AppTheme.dark(platform: TargetPlatform.android);

    expect(
      ios.pageTransitionsTheme.builders[TargetPlatform.iOS],
      isA<CupertinoPageTransitionsBuilder>(),
    );
    expect(
      android.pageTransitionsTheme.builders[TargetPlatform.android],
      isA<ZoomPageTransitionsBuilder>(),
    );
    expect(ios.appBarTheme.centerTitle, isTrue);
    expect(android.appBarTheme.centerTitle, isFalse);
  });

  testWidgets('iOS uses Cupertino role navigation', (tester) async {
    await tester.pumpWidget(_roleShellHarness(TargetPlatform.iOS));

    expect(find.byType(CupertinoTabBar), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.tap(find.text('Profile'));
    await tester.pump();
    expect(find.text('Profile body'), findsOneWidget);
  });

  testWidgets('Android uses Material 3 role navigation', (tester) async {
    await tester.pumpWidget(_roleShellHarness(TargetPlatform.android));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(CupertinoTabBar), findsNothing);

    await tester.tap(find.text('Profile'));
    await tester.pump();
    expect(find.text('Profile body'), findsOneWidget);
  });

  testWidgets('detail headers adapt their back affordance', (tester) async {
    await tester.pumpWidget(_headerHarness(TargetPlatform.iOS));
    expect(find.byType(CupertinoButton), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.chevron_back), findsOneWidget);

    await tester.pumpWidget(_headerHarness(TargetPlatform.android));
    expect(find.byType(CupertinoButton), findsNothing);
    expect(find.byIcon(LucideIcons.chevronLeft), findsOneWidget);
  });
}
