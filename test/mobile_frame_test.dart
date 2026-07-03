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
}
