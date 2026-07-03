import 'package:flutter_test/flutter_test.dart';

import 'package:at_your_service/app.dart';

void main() {
  testWidgets('role select screen lists all three roles', (tester) async {
    await tester.pumpWidget(const AtYourServiceApp());

    expect(find.text('At Your Service'), findsOneWidget);
    expect(find.text('Customer'), findsOneWidget);
    expect(find.text('Provider'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
  });

  testWidgets('selecting Customer navigates to the customer home screen', (tester) async {
    await tester.pumpWidget(const AtYourServiceApp());

    await tester.tap(find.text('Customer'));
    await tester.pumpAndSettle();

    expect(find.text('Hello, Thandi 👋'), findsOneWidget);
  });

  testWidgets('selecting Provider navigates to the provider home screen', (tester) async {
    await tester.pumpWidget(const AtYourServiceApp());

    await tester.tap(find.text('Provider'));
    await tester.pumpAndSettle();

    expect(find.text('My Jobs'), findsOneWidget);
  });

  testWidgets('selecting Admin navigates to the admin home screen', (tester) async {
    await tester.pumpWidget(const AtYourServiceApp());

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
