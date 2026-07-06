import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:at_your_service/core/theme/app_theme.dart';
import 'package:at_your_service/core/widgets/mobile_frame.dart';
import 'package:at_your_service/features/provider/provider_profile_screen.dart';
import 'package:at_your_service/features/provider/verify_screen.dart';

Widget _harness(Widget screen) {
  return MaterialApp(
    theme: AppTheme.dark(),
    builder: (context, child) => MobileFrame(child: child!),
    home: screen,
  );
}

void main() {
  testWidgets('Provider Profile View verification flow opens the Verify stepper', (tester) async {
    await tester.pumpWidget(_harness(const ProviderProfileScreen()));

    await tester.scrollUntilVisible(find.text('View verification flow'), 300, scrollable: find.byType(Scrollable));
    await tester.tap(find.text('View verification flow'));
    await tester.pumpAndSettle();

    expect(find.text('Provider Verification'), findsOneWidget);
    // Matches the handoff's initial demo state: step 4 of 7 (0-indexed),
    // so 4 steps already done.
    expect(find.text('4 of 7 complete'), findsOneWidget);
    expect(find.text('Verified'), findsNWidgets(4));
    expect(find.text('Action needed'), findsOneWidget);
    expect(find.text('Pending'), findsNWidgets(2));
  });

  testWidgets('advancing through remaining steps reveals the completed state', (tester) async {
    await tester.pumpWidget(_harness(const VerifyScreen()));

    // scrollUntilVisible stops as soon as the target has ANY overlap with
    // the viewport, which can leave its tap-center just past the edge —
    // the extra drag afterwards pulls it fully into view before tapping.
    Future<void> scrollToButtonAndTap() async {
      await tester.scrollUntilVisible(find.byType(ElevatedButton), 300, scrollable: find.byType(Scrollable));
      await tester.drag(find.byType(Scrollable), const Offset(0, -80));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
    }

    await tester.scrollUntilVisible(find.byType(ElevatedButton), 300, scrollable: find.byType(Scrollable));
    expect(find.text('Submit: Skills & Experience'), findsOneWidget);

    // Only Skills & Experience and References are provider-submitted;
    // Approved is granted automatically once those are done, not tapped.
    for (var i = 0; i < 2; i++) {
      await scrollToButtonAndTap();
    }

    await tester.scrollUntilVisible(find.text('7 of 7 complete'), -300, scrollable: find.byType(Scrollable));
    expect(find.text('7 of 7 complete'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Verified & ready to work! 🎉'), 300, scrollable: find.byType(Scrollable));
    expect(find.text('Verified & ready to work! 🎉'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
  });
}
