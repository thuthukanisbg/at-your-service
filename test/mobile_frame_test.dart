import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:at_your_service/core/widgets/mobile_frame.dart';

void main() {
  testWidgets('MobileFrame renders its child at exactly the handoff\'s 392px phone width on wide viewports', (tester) async {
    // The default test surface (800x600) already exceeds MobileFrame's
    // framing breakpoint (560), so no explicit resize is needed to exercise
    // the framed (desktop-preview) branch.
    await tester.pumpWidget(
      MaterialApp(
        home: MobileFrame(
          child: Container(key: const Key('content'), color: Colors.red),
        ),
      ),
    );

    // Measure the actual rendered child, not the SizedBox's declared width
    // property — this is what would expose any padding/margin stacking
    // between the constraint and the visible content.
    final renderedSize = tester.getSize(find.byKey(const Key('content')));
    expect(renderedSize.width, 392);
  });

  testWidgets('MobileFrame is a no-op below the framing breakpoint', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: MobileFrame(
          child: Container(key: const Key('content'), color: Colors.red),
        ),
      ),
    );

    final renderedSize = tester.getSize(find.byKey(const Key('content')));
    expect(renderedSize.width, 400);
  });

  testWidgets('a screen requesting wide layout (e.g. AdminShell) skips the phone frame once the viewport reaches desktopBreakpoint', (tester) async {
    MobileFrame.requestWideLayout();
    addTearDown(MobileFrame.releaseWideLayout);

    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: MobileFrame(
          child: Container(key: const Key('content'), color: Colors.red),
        ),
      ),
    );

    final renderedSize = tester.getSize(find.byKey(const Key('content')));
    expect(renderedSize.width, 1200);
  });

  testWidgets('a screen requesting wide layout still gets the phone frame below desktopBreakpoint', (tester) async {
    MobileFrame.requestWideLayout();
    addTearDown(MobileFrame.releaseWideLayout);

    await tester.binding.setSurfaceSize(const Size(700, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: MobileFrame(
          child: Container(key: const Key('content'), color: Colors.red),
        ),
      ),
    );

    final renderedSize = tester.getSize(find.byKey(const Key('content')));
    expect(renderedSize.width, 392);
  });

  testWidgets('requestWideLayout is reference-counted — an overlapping mount/dispose does not drop wide layout early', (tester) async {
    // Regression test for a real bug: AdminLoginScreen pushReplacement-ing
    // into AdminShell mounts the new screen (requests wide layout) before
    // the old one disposes (releases its own request) — with a plain
    // boolean flag, the old screen's "release" (set false) landing after
    // the new screen's "request" (set true) would stomp it back to false,
    // flashing the desktop layout then reverting to the phone frame. A
    // request count must stay net-positive across that overlap.
    // Belt-and-braces reset in case this test fails mid-way and leaves the
    // shared counter non-zero for later tests in this file.
    addTearDown(MobileFrame.resetWideLayoutForTest);

    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: MobileFrame(child: Container(key: const Key('content'), color: Colors.red)),
      ),
    );

    // Screen A (e.g. AdminLoginScreen) mounts and requests wide layout.
    MobileFrame.requestWideLayout();
    await tester.pump();
    expect(tester.getSize(find.byKey(const Key('content'))).width, 1200);

    // Screen B (e.g. AdminShell) mounts on top before A disposes.
    MobileFrame.requestWideLayout();
    await tester.pump();
    expect(tester.getSize(find.byKey(const Key('content'))).width, 1200);

    // Screen A now disposes — with a plain boolean this would have reset
    // it to false even though B still wants it. It must stay wide.
    MobileFrame.releaseWideLayout();
    await tester.pump();
    expect(tester.getSize(find.byKey(const Key('content'))).width, 1200);

    // Screen B eventually disposes too — now it should actually revert.
    MobileFrame.releaseWideLayout();
    await tester.pump();
    expect(tester.getSize(find.byKey(const Key('content'))).width, 392);
  });
}
