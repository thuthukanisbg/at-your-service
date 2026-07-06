import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:at_your_service/core/services/auth_service.dart';
import 'package:at_your_service/core/theme/app_theme.dart';
import 'package:at_your_service/core/widgets/mobile_frame.dart';
import 'package:at_your_service/features/admin/admin_login_screen.dart';
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

  testWidgets('Auth Google button is coming-soon, not an auth bypass', (tester) async {
    await tester.pumpWidget(_harness(const AuthScreen()));

    await tester.tap(find.text('Google'));
    await tester.pump();

    expect(find.text('Google sign-in arrives in the next milestone.'), findsOneWidget);
    expect(find.byType(RoleSelectScreen), findsNothing);
  });

  testWidgets('Auth Phone button opens the phone sign-in sheet with empty-input validation', (tester) async {
    await tester.pumpWidget(_harness(const AuthScreen()));

    await tester.tap(find.text('Phone'));
    await tester.pumpAndSettle();

    expect(find.text('Sign in with phone'), findsOneWidget);

    // Validation happens before any Firebase call, so this is safely
    // testable without a live app — actually sending/confirming a code
    // isn't (ConfirmationResult can't be constructed outside the package),
    // so that part is verified manually in the browser instead.
    await tester.tap(find.text('Send Code'));
    await tester.pump();

    expect(find.text('Enter a phone number.'), findsOneWidget);
  });

  testWidgets('Auth screen links to the dedicated Admin sign-in screen', (tester) async {
    addTearDown(MobileFrame.resetWideLayoutForTest);
    await tester.pumpWidget(_harness(const AuthScreen()));

    // `scrollable: find.byType(Scrollable).first`, not the bare finder used
    // elsewhere in this codebase's tests — AuthScreen's two TextFields each
    // have their own internal Scrollable (for text overflow), so the bare
    // finder matches 3 elements here and scrollUntilVisible throws "too
    // many elements" resolving which one to drag. `.first` picks the outer
    // ListView's own Scrollable, which is what actually needs scrolling.
    final adminLink = find.widgetWithText(TextButton, 'Admin? Sign in here');
    await tester.scrollUntilVisible(adminLink, 300, scrollable: find.byType(Scrollable).first);
    // scrollUntilVisible stops as soon as any sliver of the target enters
    // the viewport, which can still leave its center (what tap() targets)
    // below the fold — nudge a bit further to be safe.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -80));
    await tester.pump();
    await tester.tap(adminLink);
    await tester.pumpAndSettle();

    expect(find.byType(AdminLoginScreen), findsOneWidget);
    expect(find.text('Admin sign in'), findsOneWidget);
    // Sign-in only — no sign-up toggle like the regular Auth screen.
    expect(find.text('Sign Up'), findsNothing);
  });

  testWidgets('Admin sign-in with empty fields shows a validation message instead of navigating', (tester) async {
    addTearDown(MobileFrame.resetWideLayoutForTest);
    await tester.pumpWidget(_harness(const AdminLoginScreen()));

    await tester.tap(find.text('Sign In'));
    await tester.pump();

    expect(find.text('Please enter both email and password.'), findsOneWidget);
  });

  testWidgets('Admin sign-in navigates straight to the desktop-capable AdminShell, no role picker', (tester) async {
    addTearDown(MobileFrame.resetWideLayoutForTest);
    await tester.pumpWidget(_harness(const AdminLoginScreen()));

    await tester.enterText(find.byType(TextField).at(0), 'admin@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await tester.tap(find.text('Sign In'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(RoleSelectScreen), findsNothing);
    // Default (narrow) test viewport falls back to the mobile Admin
    // experience, same as any other Admin entry point below the desktop
    // breakpoint — this just confirms it landed in Admin at all.
    expect(find.text('Dashboard'), findsOneWidget);
  });
}

class _FailingAuthService extends AuthService {
  @override
  Future<void> signIn({required String email, required String password}) async {
    throw const AuthException('Email or password is incorrect.');
  }
}
