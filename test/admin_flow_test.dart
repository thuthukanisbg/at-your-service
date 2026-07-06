import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:at_your_service/app.dart';
import 'package:at_your_service/core/services/auth_service.dart';
import 'package:at_your_service/core/theme/app_theme.dart';
import 'package:at_your_service/core/theme/theme_mode_controller.dart';
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
    // The pending list now loads asynchronously (falls back to mock data
    // here, since tests have no live Firebase app) — settle past that
    // before interacting with it.
    await tester.pumpAndSettle();

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
    await tester.pumpAndSettle();

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
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.text('Themba K.'));
    await tester.tap(find.text('Themba K.'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(LucideIcons.chevronLeft));
    await tester.pumpAndSettle();

    expect(find.text('3 new'), findsOneWidget);
    expect(find.text('Themba K.'), findsOneWidget);
  });

  testWidgets('Providers tab loads (or falls back gracefully without a live Firebase app)', (tester) async {
    await tester.pumpWidget(const AtYourServiceApp());
    await _skipToChooser(tester);
    await _scrollTo(tester, find.text('Admin'));
    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();

    // Tap by icon, not text: 'Providers' is both the bottom-nav label and
    // the screen's own title, and both are mounted at once (IndexedStack
    // keeps every tab's body built, not just the visible one).
    await tester.tap(find.byIcon(LucideIcons.users));
    await tester.pumpAndSettle();

    expect(find.text("Couldn't load providers."), findsOneWidget);
  });

  testWidgets('Admin renders the desktop sidebar shell (not the mobile bottom nav) at a wide viewport', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const AtYourServiceApp());
    await _skipToChooser(tester);
    await _scrollTo(tester, find.text('Admin'));
    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();

    // The sidebar's own header is a marker unique to the desktop shell — the
    // mobile RoleNavShell has no equivalent.
    expect(find.text('At Your Service'), findsOneWidget);
    expect(find.text('Operational snapshot · updated just now'), findsOneWidget);
    // All 8 sidebar sections from the Admin Dashboard design handoff.
    expect(find.text('Team & Roles'), findsOneWidget);
    expect(find.text('Catalog'), findsOneWidget);
    // Real pending-applicants data still renders (same fallback-to-mock
    // behavior as the mobile dashboard test above, no live Firebase app).
    expect(find.text('John M.'), findsOneWidget);

    // Sidebar nav swaps content, same as the mobile bottom nav — tap by
    // icon since the sidebar label and the page's own heading are both
    // 'Providers' and both are mounted at once (IndexedStack). `.first`
    // because the Overview page's "Active Providers" KPI card (also
    // mounted, also LucideIcons.users) matches too — the sidebar item is
    // built first in the widget tree.
    await tester.tap(find.byIcon(LucideIcons.users).first);
    await tester.pumpAndSettle();
    expect(find.text("Couldn't load providers."), findsOneWidget);
  });

  testWidgets('desktop Customers tab loads (or falls back gracefully without a live Firebase app)', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const AtYourServiceApp());
    await _skipToChooser(tester);
    await _scrollTo(tester, find.text('Admin'));
    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();

    // Now real data (users where role == customer, joined against
    // bookings) — no live Firebase app in tests, so this should surface the
    // same honest error state as every other real-data admin screen.
    await tester.tap(find.byIcon(LucideIcons.user).first);
    await tester.pumpAndSettle();
    expect(find.text("Couldn't load customers."), findsOneWidget);
  });

  testWidgets('desktop Catalog tab loads (or falls back gracefully without a live Firebase app)', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const AtYourServiceApp());
    await _skipToChooser(tester);
    await _scrollTo(tester, find.text('Admin'));
    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();

    // Category cards are now real (serviceCategories/services/providers) —
    // same honest error state as every other real-data admin screen without
    // a live Firebase app. The discounts table below stays mock regardless.
    await tester.tap(find.byIcon(LucideIcons.tag).first);
    await tester.pumpAndSettle();
    expect(find.text("Couldn't load the service catalog."), findsOneWidget);
    expect(find.text('Active discounts'), findsOneWidget);
    expect(find.text('CLEAN20'), findsOneWidget);
  });

  testWidgets('desktop Team & Roles tab loads (or falls back gracefully without a live Firebase app), with no fabricated columns', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const AtYourServiceApp());
    await _skipToChooser(tester);
    await _scrollTo(tester, find.text('Admin'));
    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();

    // Now real data (users where role == admin) — name/email only, no
    // fabricated Role/Last Active/Status columns. No live Firebase app in
    // tests, so this should surface the same honest error state as every
    // other real-data admin screen.
    await tester.tap(find.byIcon(LucideIcons.shieldCheck).first);
    await tester.pumpAndSettle();
    expect(find.text("Couldn't load admin users."), findsOneWidget);
    // These columns/fields were dropped, not shown blank — confirm they're
    // genuinely gone, not just hidden behind the error state.
    expect(find.text('Super Admin'), findsNothing);
    expect(find.text('Invited'), findsNothing);
  });

  testWidgets('desktop Disputes & Support tab loads (or falls back gracefully without a live Firebase app)', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const AtYourServiceApp());
    await _skipToChooser(tester);
    await _scrollTo(tester, find.text('Admin'));
    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();

    // Now real data (`disputes`, filed by customers/providers on real
    // bookings) — no live Firebase app in tests, so this should surface the
    // same honest error state as every other real-data admin screen.
    // `.first` because Overview's "Open Disputes" KPI card (also mounted,
    // also LucideIcons.lifeBuoy) matches too — the sidebar item is built
    // first in the widget tree.
    await tester.tap(find.byIcon(LucideIcons.lifeBuoy).first);
    await tester.pumpAndSettle();
    expect(find.text("Couldn't load disputes."), findsOneWidget);
    // Overview's "Open Disputes" KPI is real now too — with no live
    // Firebase app it should show the honest '—', not a fabricated count.
    await tester.tap(find.byIcon(LucideIcons.layoutDashboard).first);
    await tester.pumpAndSettle();
    expect(find.text('Open Disputes'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('resizing below the desktop breakpoint while Admin is open falls back to the mobile bottom nav', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const AtYourServiceApp());
    await _skipToChooser(tester);
    await _scrollTo(tester, find.text('Admin'));
    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();
    expect(find.text('At Your Service'), findsOneWidget);

    await tester.binding.setSurfaceSize(const Size(400, 800));
    await tester.pumpAndSettle();

    expect(find.text('At Your Service'), findsNothing);
    expect(find.text('Dashboard'), findsOneWidget);
  });

  testWidgets('the desktop sidebar theme toggle flips the app-wide theme', (tester) async {
    addTearDown(() => ThemeModeController.mode.value = ThemeMode.dark);
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const AtYourServiceApp());
    await _skipToChooser(tester);
    await _scrollTo(tester, find.text('Admin'));
    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();

    // App ships dark-by-default (see app.dart) — the sidebar toggle's own
    // label always names the mode you'd switch *to*.
    expect(find.text('Light mode'), findsOneWidget);
    expect(ThemeModeController.mode.value, ThemeMode.dark);

    await tester.tap(find.text('Light mode'));
    await tester.pumpAndSettle();

    expect(ThemeModeController.mode.value, ThemeMode.light);
    expect(find.text('Dark mode'), findsOneWidget);
  });
}
