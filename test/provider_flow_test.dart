import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:at_your_service/app.dart';
import 'package:at_your_service/core/services/auth_service.dart';
import 'package:at_your_service/core/theme/app_theme.dart';
import 'package:at_your_service/core/widgets/mobile_frame.dart';
import 'package:at_your_service/features/disputes/file_dispute_screen.dart';
import 'package:at_your_service/features/provider/provider_earnings_screen.dart';
import 'package:at_your_service/features/provider/provider_in_progress_screen.dart';
import 'package:at_your_service/features/provider/provider_job_details_screen.dart';
import 'package:at_your_service/features/provider/provider_navigate_screen.dart';
import 'package:at_your_service/features/provider/provider_profile_screen.dart';
import 'package:at_your_service/features/provider/provider_schedule_screen.dart';
import 'package:at_your_service/models/provider_job.dart';

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

  testWidgets('provider jobs list opens Job Details for the tapped job', (tester) async {
    await tester.pumpWidget(const AtYourServiceApp());
    await _skipToChooser(tester);
    await tester.tap(find.text('Provider'));
    await tester.pumpAndSettle();

    expect(find.text('My Jobs'), findsOneWidget);
    expect(find.text('Plumbing Repair'), findsOneWidget);

    await tester.tap(find.text('Plumbing Repair'));
    await tester.pumpAndSettle();

    expect(find.text('Job Details'), findsOneWidget);
    // Payout is 90% of the tapped job's own price (R750 -> R675), not the
    // handoff's hardcoded R540 example (which is for the R600 job).
    expect(find.textContaining('R675'), findsOneWidget);
  });

  testWidgets('Job Details Accept Job opens Navigate', (tester) async {
    await tester.pumpWidget(
      _harness(const ProviderJobDetailsScreen(job: ProviderJob(title: 'Deep House Cleaning', price: 600, timeLabel: 'Today · 10:00 AM', distanceLabel: '2.3 km'))),
    );

    expect(find.text('CUSTOMER NOTES'), findsOneWidget);

    await tester.tap(find.text('Accept Job'));
    await tester.pumpAndSettle();

    expect(find.text('Navigate'), findsOneWidget);
    expect(find.text('Start Navigation'), findsOneWidget);
  });

  testWidgets('Job Details shows Report an issue only for an already-accepted real job', (tester) async {
    // Not shown on an Available-tab job (isAlreadyAccepted: false, the
    // default) — reporting an issue only makes sense once it's actually
    // this provider's job.
    await tester.pumpWidget(
      _harness(const ProviderJobDetailsScreen(
        job: ProviderJob(id: 'job-1', customerId: 'customer-1', title: 'Deep House Cleaning', price: 600, timeLabel: 'Today · 10:00 AM', distanceLabel: '2.3 km'),
      )),
    );
    expect(find.text('Report an issue'), findsNothing);

    // Shown once accepted. Tapping it resolves the provider's own uid via
    // FirebaseAuth, which is unavailable in tests (no live Firebase app) —
    // same limitation as this screen's existing "Message Customer" button —
    // so this only confirms the button renders and doesn't crash on tap,
    // not the full navigation (covered separately by pumping
    // FileDisputeScreen directly below).
    await tester.pumpWidget(
      _harness(const ProviderJobDetailsScreen(
        job: ProviderJob(id: 'job-1', customerId: 'customer-1', title: 'Deep House Cleaning', price: 600, timeLabel: 'Today · 10:00 AM', distanceLabel: '2.3 km'),
        isAlreadyAccepted: true,
      )),
    );
    await tester.scrollUntilVisible(find.text('Report an issue'), 300, scrollable: find.byType(Scrollable));
    expect(find.text('Report an issue'), findsOneWidget);
    await tester.tap(find.text('Report an issue'));
    await tester.pump();
  });

  testWidgets('FileDisputeScreen renders subject/priority/description fields', (tester) async {
    await tester.pumpWidget(_harness(const FileDisputeScreen(
      bookingId: 'booking-1',
      customerId: 'customer-1',
      providerId: 'provider-1',
      serviceName: 'Deep House Cleaning',
    )));

    expect(find.text('Report a Problem'), findsOneWidget);
    expect(find.text('Deep House Cleaning'), findsOneWidget);
    expect(find.text('Low'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);
    expect(find.text('Submit Report'), findsOneWidget);
  });

  testWidgets('Navigate Start Navigation opens In Progress', (tester) async {
    await tester.pumpWidget(_harness(const ProviderNavigateScreen()));

    await tester.tap(find.text('Start Navigation'));
    await tester.pumpAndSettle();

    expect(find.text('Job in Progress'), findsOneWidget);
  });

  testWidgets('In Progress task toggle updates status and Complete Job pops to root', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        builder: (context, child) => MobileFrame(child: child!),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProviderInProgressScreen()),
                ),
                child: const Text('open in-progress screen'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open in-progress screen'));
    await tester.pumpAndSettle();

    // Matches the handoff's initial demo state: first two tasks done already.
    expect(find.text('Completed'), findsNWidgets(2));
    expect(find.text('In progress'), findsNWidgets(2));

    await tester.tap(find.text('Floor & surface cleaning'));
    await tester.pumpAndSettle();

    expect(find.text('Completed'), findsNWidgets(3));
    expect(find.text('In progress'), findsNWidgets(1));

    await tester.tap(find.text('Complete Job'));
    await tester.pumpAndSettle();

    expect(find.text('open in-progress screen'), findsOneWidget);
  });

  testWidgets('provider Schedule tab renders the week strip and appointments', (tester) async {
    await tester.pumpWidget(_harness(const ProviderScheduleScreen()));

    expect(find.text('Schedule'), findsOneWidget);
    expect(find.text('Office Cleaning'), findsOneWidget);
    expect(find.text('Deep House Cleaning'), findsOneWidget);
  });

  testWidgets('provider Earnings tab renders the monthly total and payouts', (tester) async {
    await tester.pumpWidget(_harness(const ProviderEarningsScreen()));

    expect(find.text('R24,580'), findsOneWidget);
    expect(find.text('Recent payouts'), findsOneWidget);
    expect(find.text('R4,820'), findsOneWidget);
  });

  testWidgets('provider Profile tab renders stats and verification status', (tester) async {
    await tester.pumpWidget(_harness(const ProviderProfileScreen()));

    expect(find.text('Sipho M.'), findsOneWidget);
    expect(find.text('Verified Pro'), findsOneWidget);
    expect(find.text('Background check'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
  });
}
