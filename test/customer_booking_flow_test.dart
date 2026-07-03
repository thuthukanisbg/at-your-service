import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:at_your_service/app.dart';
import 'package:at_your_service/core/services/auth_service.dart';
import 'package:at_your_service/core/theme/app_colors.dart';
import 'package:at_your_service/core/theme/app_theme.dart';
import 'package:at_your_service/core/widgets/mobile_frame.dart';
import 'package:at_your_service/features/customer/book_schedule_screen.dart';
import 'package:at_your_service/features/customer/rate_review_screen.dart';
import 'package:at_your_service/features/customer/review_pay_screen.dart';
import 'package:at_your_service/features/customer/service_details_screen.dart';
import 'package:at_your_service/features/customer/track_booking_screen.dart';

/// Wraps a screen the same way the real app does (theme + Navigator +
/// MobileFrame) without requiring the full role-select -> shell chain to be
/// pushed first. Including MobileFrame matters: at the default (wide) test
/// viewport, it's what actually constrains the screen to the handoff's
/// 392px phone width — omitting it would test layout at a width the app
/// never really renders at, and miss overflow bugs that only show up at
/// the correct narrower width.
Widget _harness(Widget screen) {
  return MaterialApp(
    theme: AppTheme.dark(),
    builder: (context, child) => MobileFrame(child: child!),
    home: screen,
  );
}

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
  // AuthScreen now performs real (test-stubbed) sign-in with non-empty
  // validation, so credentials must be entered before tapping the CTA.
  await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
  await tester.enterText(find.byType(TextField).at(1), 'password123');
  await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
  // Auth/RoleSelect have no repeating animations, so it's safe to fully
  // settle this second transition normally.
  await tester.pumpAndSettle();
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

  testWidgets('customer home Recommended card opens Service Details', (tester) async {
    await tester.pumpWidget(const AtYourServiceApp());
    await _skipToChooser(tester);
    await tester.tap(find.text('Customer'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Deep House Cleaning'), 300, scrollable: find.byType(Scrollable));
    await tester.tap(find.text('Deep House Cleaning'));
    await tester.pumpAndSettle();

    expect(find.text('Service Details'), findsOneWidget);
    expect(find.text('Kitchen deep clean'), findsOneWidget);
  });

  testWidgets('Service Details Continue opens Book & Schedule', (tester) async {
    await tester.pumpWidget(_harness(const ServiceDetailsScreen()));

    expect(find.text('From R600'), findsOneWidget);

    await tester.drag(find.byType(Scrollable), const Offset(0, -1000));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Book & Schedule'), findsOneWidget);
    expect(find.text('Select Date'), findsOneWidget);
  });

  testWidgets('Book & Schedule carries the selected date/time into Review & Pay', (tester) async {
    await tester.pumpWidget(_harness(const BookScheduleScreen()));

    await tester.tap(find.text('22'));
    await tester.pump();
    await tester.tap(find.text('02:00 PM'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Review & Pay'), findsOneWidget);
    expect(find.text('22 May 2024'), findsOneWidget);
    expect(find.text('02:00 PM'), findsOneWidget);
  });

  testWidgets('Review & Pay Confirm & Pay opens Track Booking', (tester) async {
    await tester.pumpWidget(_harness(const ReviewPayScreen(selectedDate: '21 May', selectedTime: '10:00 AM')));

    expect(find.text('R600'), findsWidgets);

    await tester.tap(find.text('Instant EFT'));
    await tester.pump();
    await tester.tap(find.text('Confirm & Pay R600'));
    // Track Booking runs an infinite pulse animation, so avoid pumpAndSettle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('My Booking'), findsOneWidget);
    expect(find.text('Sipho M.'), findsOneWidget);
  });

  testWidgets('Track Booking Mark as complete opens Rate & Review', (tester) async {
    await tester.pumpWidget(_harness(const TrackBookingScreen()));
    await tester.pump();

    expect(find.text('Booking confirmed'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Mark as complete & rate'), 300, scrollable: find.byType(Scrollable));
    await tester.tap(find.text('Mark as complete & rate'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Rate & Review'), findsOneWidget);
  });

  testWidgets('Rate & Review star selection and Submit pops back to the caller', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        builder: (context, child) => MobileFrame(child: child!),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RateReviewScreen()),
                ),
                child: const Text('open rate screen'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open rate screen'));
    await tester.pumpAndSettle();

    expect(find.text('Sipho M.'), findsOneWidget);
    expect(find.text('Professional'), findsOneWidget);

    final stars = find.byIcon(LucideIcons.star);
    expect(stars, findsNWidgets(5));
    await tester.tap(stars.at(2)); // select the 3rd star
    await tester.pump();

    // Quick-tag chips toggle selected state on tap.
    final tagContainer = find.ancestor(of: find.text('Professional'), matching: find.byType(Container)).first;
    expect((tester.widget<Container>(tagContainer).decoration as BoxDecoration).color, isNot(AppColors.primary));
    await tester.tap(find.text('Professional'));
    await tester.pump();
    expect((tester.widget<Container>(tagContainer).decoration as BoxDecoration).color, AppColors.primary);

    await tester.tap(find.text('Submit Review'));
    await tester.pumpAndSettle();

    expect(find.text('open rate screen'), findsOneWidget);
  });
}
