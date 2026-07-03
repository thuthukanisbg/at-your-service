import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:at_your_service/app.dart';
import 'package:at_your_service/core/theme/app_theme.dart';
import 'package:at_your_service/core/widgets/mobile_frame.dart';
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

void main() {
  testWidgets('provider jobs list opens Job Details for the tapped job', (tester) async {
    await tester.pumpWidget(const AtYourServiceApp());
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
