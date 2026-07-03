import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:at_your_service/app.dart';
import 'package:at_your_service/core/theme/app_theme.dart';
import 'package:at_your_service/core/widgets/mobile_frame.dart';
import 'package:at_your_service/features/admin/admin_dashboard_screen.dart';

Widget _harness(Widget screen) {
  return MaterialApp(
    theme: AppTheme.dark(),
    builder: (context, child) => MobileFrame(child: child!),
    home: screen,
  );
}

Future<void> _scrollTo(WidgetTester tester, Finder finder) =>
    tester.scrollUntilVisible(finder, 300, scrollable: find.byType(Scrollable));

/// Walks from Splash to the role chooser via the shortest path. Splash's
/// floaty logo animation repeats forever and stays mounted underneath the
/// outgoing page transition for a few hundred ms after `pushReplacement`,
/// so `pumpAndSettle()` would hang here the same way it does on
/// TrackBookingScreen's pulsing dot — pump fixed durations instead.
Future<void> _skipToChooser(WidgetTester tester) async {
  await tester.pump();
  await tester.tap(find.text('I already have an account'));
  // Splash's floaty logo animation repeats forever, so pumpAndSettle() would
  // hang while it's still mounted mid-transition — pump manually until it's
  // fully replaced by AuthScreen instead (a single large pump() doesn't give
  // the transition's completion callbacks a chance to run either; two
  // smaller pumps reliably do).
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
  // Auth/RoleSelect have no repeating animations, so it's safe to fully
  // settle this second transition normally.
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('admin dashboard shows stats and pending applicants', (tester) async {
    await tester.pumpWidget(const AtYourServiceApp());
    await _skipToChooser(tester);
    await _scrollTo(tester, find.text('Admin'));
    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('3 new'), findsOneWidget);
    expect(find.text('John M.'), findsOneWidget);

    await _scrollTo(tester, find.text('Nomsa P.'));
    expect(find.text('Nomsa P.'), findsOneWidget);

    await _scrollTo(tester, find.text('Themba K.'));
    expect(find.text('Themba K.'), findsOneWidget);
  });

  testWidgets('approving an applicant removes them from the pending list', (tester) async {
    await tester.pumpWidget(_harness(const AdminDashboardScreen()));

    await tester.tap(find.text('John M.'));
    await tester.pumpAndSettle();

    expect(find.text('Provider Review'), findsOneWidget);
    expect(find.text('3 years'), findsOneWidget);
    expect(find.text('Background check'), findsOneWidget);

    await _scrollTo(tester, find.text('Approve'));
    await tester.tap(find.text('Approve'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('2 new'), findsOneWidget);
    expect(find.text('John M.'), findsNothing);
    expect(find.text('Nomsa P.'), findsOneWidget);
  });

  testWidgets('rejecting an applicant also removes them from the pending list', (tester) async {
    await tester.pumpWidget(_harness(const AdminDashboardScreen()));

    await _scrollTo(tester, find.text('Nomsa P.'));
    await tester.tap(find.text('Nomsa P.'));
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.text('Reject'));
    await tester.tap(find.text('Reject'));
    await tester.pumpAndSettle();

    expect(find.text('2 new'), findsOneWidget);
    expect(find.text('Nomsa P.'), findsNothing);
  });

  testWidgets('navigating back without a decision keeps the applicant pending', (tester) async {
    await tester.pumpWidget(_harness(const AdminDashboardScreen()));

    await _scrollTo(tester, find.text('Themba K.'));
    await tester.tap(find.text('Themba K.'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(LucideIcons.chevronLeft));
    await tester.pumpAndSettle();

    expect(find.text('3 new'), findsOneWidget);
    expect(find.text('Themba K.'), findsOneWidget);
  });
}
