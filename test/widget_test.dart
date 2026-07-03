import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:at_your_service/app.dart';
import 'package:at_your_service/core/services/auth_service.dart';

/// Succeeds without touching Firebase — AuthScreen's real service needs a
/// live Firebase app, which widget tests don't have.
class _StubAuthService extends AuthService {
  @override
  Future<void> signIn({required String email, required String password}) async {}

  @override
  Future<void> signUp({required String name, required String email, required String password}) async {}
}

/// Walks from the app's real entry point (Splash) to the role chooser via
/// the shortest path ("I already have an account" -> Sign In), so every
/// other test doesn't have to re-navigate the entry flow to reach the
/// screen it actually wants to exercise.
///
/// SplashScreen's floaty logo animation repeats forever, and it stays
/// mounted underneath the outgoing page-transition animation for a few
/// hundred milliseconds after `pushReplacement` — so `pumpAndSettle()`
/// would hang here the same way it does on TrackBookingScreen's pulsing
/// dot. Pump fixed durations instead until Splash/Auth are fully replaced.
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
  // AuthScreen now performs real (test-stubbed) sign-in with non-empty
  // validation, so credentials must be entered before tapping the CTA.
  await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
  await tester.enterText(find.byType(TextField).at(1), 'password123');
  await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
  // Auth/RoleSelect have no repeating animations, so it's safe to fully
  // settle this second transition normally.
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    AuthService.instance = _StubAuthService();
  });

  testWidgets('role select screen lists all three roles', (tester) async {
    await tester.pumpWidget(const AtYourServiceApp());
    await _skipToChooser(tester);

    expect(find.text('At Your Service'), findsOneWidget);
    expect(find.text('Customer'), findsOneWidget);
    expect(find.text('Provider'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
  });

  testWidgets('selecting Customer navigates to the customer home screen', (tester) async {
    await tester.pumpWidget(const AtYourServiceApp());
    await _skipToChooser(tester);

    await tester.tap(find.text('Customer'));
    await tester.pumpAndSettle();

    expect(find.text('Hello, Thandi 👋'), findsOneWidget);
  });

  testWidgets('selecting Provider navigates to the provider home screen', (tester) async {
    await tester.pumpWidget(const AtYourServiceApp());
    await _skipToChooser(tester);

    await tester.tap(find.text('Provider'));
    await tester.pumpAndSettle();

    expect(find.text('My Jobs'), findsOneWidget);
  });

  testWidgets('selecting Admin navigates to the admin home screen', (tester) async {
    await tester.pumpWidget(const AtYourServiceApp());
    await _skipToChooser(tester);

    // At the handoff's exact 392px frame width, the role card descriptions
    // wrap onto more lines than they used to, pushing Admin (the last card)
    // below the default test viewport — scroll it into view first.
    await tester.ensureVisible(find.text('Admin'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
  });
}
