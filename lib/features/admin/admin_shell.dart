import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/widgets/coming_soon_tab.dart';
import '../../core/widgets/role_nav_shell.dart';
import 'admin_dashboard_screen.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({super.key});

  static const routeName = '/admin';

  @override
  Widget build(BuildContext context) {
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
          body: ComingSoonTab(title: 'Bookings', icon: LucideIcons.calendar),
        ),
        NavTab(
          icon: LucideIcons.users,
          selectedIcon: LucideIcons.users,
          label: 'Providers',
          body: ComingSoonTab(title: 'Providers', icon: LucideIcons.users),
        ),
        NavTab(
          icon: LucideIcons.moreHorizontal,
          selectedIcon: LucideIcons.moreHorizontal,
          label: 'More',
          body: ComingSoonTab(title: 'More', icon: LucideIcons.moreHorizontal),
        ),
      ],
    );
  }
}
