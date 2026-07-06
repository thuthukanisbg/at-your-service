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

  /// Width above which a screen that has opted out via [requestWideLayout]
  /// gets the real, unclamped viewport instead of the phone frame — i.e. a
  /// genuine desktop layout. Below this, that screen still renders inside
  /// the phone frame like every other role; only Admin opts in today (see
  /// `AdminShell`/`AdminLoginScreen`).
  static const double desktopBreakpoint = 900;

  /// Reference-counted, not a plain boolean — deliberately. Two screens
  /// that both want wide layout can be mounted at once mid-transition (e.g.
  /// `AdminLoginScreen` pushReplacement-ing into `AdminShell`): the new
  /// screen's `initState` requests wide layout before the old screen's
  /// `dispose` releases its own request. A plain boolean is order-dependent
  /// in that overlap — if the old screen's "release" (set false) runs after
  /// the new screen's "request" (set true), it stomps the new screen's
  /// request back to false, and the desktop layout flashes then reverts to
  /// the phone frame. A request count is commutative regardless of
  /// ordering: +1 then -1 (or -1 then +1) both net to the correct "still
  /// wanted" state as long as both calls land.
  static final ValueNotifier<int> _wideLayoutRequests = ValueNotifier(0);

  /// Call from a screen's `initState` (deferred — see [AdminShell]'s own
  /// comment on why this can't run synchronously during `initState`) when
  /// it wants a real desktop layout instead of being clamped into the phone
  /// frame. Only takes effect once the viewport is at least
  /// [desktopBreakpoint] wide — below that the frame still applies as
  /// normal, so the mobile experience for that screen is unaffected. Must
  /// be paired with [releaseWideLayout] in `dispose`.
  static void requestWideLayout() => _wideLayoutRequests.value++;

  /// Pairs with [requestWideLayout] — call from `dispose`.
  static void releaseWideLayout() => _wideLayoutRequests.value--;

  /// Test-only escape hatch for a safety-net teardown — resets the count
  /// straight to 0 regardless of how many outstanding requests exist, so a
  /// test doesn't need to know/guess that number (e.g. a screen's own
  /// `dispose`-deferred release may not get a chance to run if no further
  /// frame is pumped after the test body ends). Not for production use.
  @visibleForTesting
  static void resetWideLayoutForTest() => _wideLayoutRequests.value = 0;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _wideLayoutRequests,
      builder: (context, requests, _) {
        final wideLayoutOptedIn = requests > 0;
        return LayoutBuilder(
          builder: (context, constraints) {
            if (wideLayoutOptedIn &&
                constraints.maxWidth >= desktopBreakpoint) {
              return child;
            }
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
                      borderRadius: BorderRadius.circular(
                        42,
                      ), // handoff's phone-screen radius
                      child: child,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
