import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/widgets/mobile_frame.dart';
import '../../core/widgets/role_nav_shell.dart';
import 'admin_bookings_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_desktop_shell.dart';
import 'admin_more_screen.dart';
import 'admin_providers_screen.dart';

/// Admin is the one role with real operations-desk usage on a desktop
/// browser, not just a phone — see `AdminDesktopShell` for the wide layout.
/// This widget picks between that and the same mobile phone-frame
/// experience the other two roles get, based on the real (unclamped)
/// viewport width, by opting `MobileFrame` out of its phone-frame clamp
/// above `MobileFrame.desktopBreakpoint`.
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  static const routeName = '/admin';

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  @override
  void initState() {
    super.initState();
    // Deferred: MobileFrame's ValueListenableBuilder is still mid-build the
    // moment AdminShell first mounts (it's an ancestor building its way down
    // to this widget), so flipping the notifier synchronously here throws
    // "setState() called during build". Post-frame is safe and still lands
    // before the user sees anything, since pumpAndSettle/the next frame
    // picks it up immediately.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MobileFrame.requestWideLayout();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MobileFrame.releaseWideLayout();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= MobileFrame.desktopBreakpoint) {
          return const AdminDesktopShell();
        }
        return const RoleNavShell(
          tabs: [
            NavTab(
              icon: LucideIcons.layoutDashboard,
              selectedIcon: LucideIcons.layoutDashboard,
              label: 'Overview',
              body: AdminDashboardScreen(),
            ),
            NavTab(
              icon: LucideIcons.calendar,
              selectedIcon: LucideIcons.calendar,
              label: 'Bookings',
              body: AdminBookingsScreen(),
            ),
            NavTab(
              icon: LucideIcons.users,
              selectedIcon: LucideIcons.users,
              label: 'Providers',
              body: AdminProvidersScreen(),
            ),
            NavTab(
              icon: LucideIcons.moreHorizontal,
              selectedIcon: LucideIcons.moreHorizontal,
              label: 'More',
              body: AdminMoreScreen(),
            ),
          ],
        );
      },
    );
  }
}
