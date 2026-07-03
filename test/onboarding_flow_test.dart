import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:at_your_service/core/services/auth_service.dart';
import 'package:at_your_service/core/theme/app_theme.dart';
import 'package:at_your_service/core/widgets/mobile_frame.dart';
import 'package:at_your_service/features/onboarding/auth_screen.dart';
import 'package:at_your_service/features/onboarding/onboarding_screen.dart';
import 'package:at_your_service/features/onboarding/splash_screen.dart';
import 'package:at_your_service/features/role_select/role_select_screen.dart';

/// Wraps a screen the same way the real app does (theme + Navigator +
/// MobileFrame) without requiring the full entry-flow chain to be pushed
/// first. See customer_booking_flow_test.dart for why MobileFrame matters.
Widget _harness(Widget screen) {
  return MaterialApp(
    theme: AppTheme.dark(),
    builder: (context, child) => MobileFrame(child: child!),
    home: screen,
  );
}

/// Succeeds without touching Firebase — AuthScreen's real service needs a
/// live Firebase app, which widget tests don't have.
class _StubAuthService extends AuthService {
  @override
  Future<void> signIn({required String email, required String password}) async {}

  @override
  Future<void> signUp({required String name, required String email, required String password}) async {}
}

void main() {
  setUp(() {
    AuthService.instance = _StubAuthService();
  });

  testWidgets('Splash shows the brand copy and both entry CTAs, Get Started opens Onboarding', (tester) async {
    await tester.pumpWidget(_harness(const SplashScreen()));

    expect(find.text('At Your Service'), findsOneWidget);
    expect(find.text('Every time.'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);

    // Splash's floaty logo animation repeats forever, so pumpAndSettle()
    // would hang while it's still mounted mid-transition — pump manually
    // instead (see the pulsing-dot gotcha noted in CLAUDE.md).
    await tester.tap(find.text('Get Started'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Find trusted pros'), findsOneWidget);
  });

  testWidgets('Splash "I already have an account" opens Auth directly', (tester) async {
    await tester.pumpWidget(_harness(const SplashScreen()));

    await tester.tap(find.text('I already have an account'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('Onboarding Next advances slides and updates the button label, Skip jumps to Auth', (tester) async {
    await tester.pumpWidget(_harness(const OnboardingScreen()));

    expect(find.text('Find trusted pros'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Next'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle();
    expect(find.text('Book in seconds'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle();
    expect(find.text('Safe & guaranteed'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Get Started'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Get Started'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('Onboarding Skip jumps straight to Auth from the first slide', (tester) async {
    await tester.pumpWidget(_harness(const OnboardingScreen()));

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('Auth swaps field count between Sign In and Sign Up, and sign-up opens the chooser', (tester) async {
    await tester.pumpWidget(_harness(const AuthScreen()));

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Full name'), findsNothing);

    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Full name'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(3));

    await tester.enterText(find.byType(TextField).at(0), 'Thandi Nkosi');
    await tester.enterText(find.byType(TextField).at(1), 'thandi@example.com');
    await tester.enterText(find.byType(TextField).at(2), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
    await tester.pumpAndSettle();

    expect(find.text('Customer'), findsOneWidget);
    expect(find.text('Provider'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
  });

  testWidgets('Auth sign-in with empty fields shows a validation message instead of navigating', (tester) async {
    await tester.pumpWidget(_harness(const AuthScreen()));

    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
    await tester.pump();

    expect(find.text('Please fill in all fields.'), findsOneWidget);
    expect(find.byType(RoleSelectScreen), findsNothing);
  });

  testWidgets('Auth surfaces sign-in failures from the service as a snackbar', (tester) async {
    AuthService.instance = _FailingAuthService();
    await tester.pumpWidget(_harness(const AuthScreen()));

    await tester.enterText(find.byType(TextField).at(0), 'thandi@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'wrong');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Email or password is incorrect.'), findsOneWidget);
    expect(find.byType(RoleSelectScreen), findsNothing);
  });

  testWidgets('Auth Google/Phone buttons are coming-soon, not an auth bypass', (tester) async {
    await tester.pumpWidget(_harness(const AuthScreen()));

    await tester.tap(find.text('Google'));
    await tester.pump();

    expect(find.text('Google sign-in arrives in the next milestone.'), findsOneWidget);
    expect(find.byType(RoleSelectScreen), findsNothing);
  });
}

class _FailingAuthService extends AuthService {
  @override
  Future<void> signIn({required String email, required String password}) async {
    throw const AuthException('Email or password is incorrect.');
  }
}
