import 'package:flutter/material.dart';

/// At Your Service is a mobile marketplace app. On an actual phone this is
/// a no-op. On a wider viewport (running in a desktop browser during
/// development) it constrains content to a phone-width column on a neutral
/// backdrop, so the app reads as an app — not a browser tab stretched edge
/// to edge like a website.
class MobileFrame extends StatelessWidget {
  const MobileFrame({super.key, required this.child});

  final Widget child;

  static const double _phoneWidth = 392; // handoff's exact phone screen width
  static const double _framingBreakpoint = 560;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= _framingBreakpoint) {
          return child;
        }
        return ColoredBox(
          color: const Color(0xFFDDE2EC),
          child: Center(
            child: SizedBox(
              width: _phoneWidth,
              height: constraints.maxHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 40,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(42), // handoff's phone-screen radius
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
