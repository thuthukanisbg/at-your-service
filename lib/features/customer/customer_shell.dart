import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/widgets/role_nav_shell.dart';
import 'customer_bookings_screen.dart';
import 'customer_home_screen.dart';
import 'customer_messages_screen.dart';
import 'customer_profile_screen.dart';

class CustomerShell extends StatelessWidget {
  const CustomerShell({super.key});

  static const routeName = '/customer';

  @override
  Widget build(BuildContext context) {
    return const RoleNavShell(
      tabs: [
        NavTab(
          icon: LucideIcons.home,
          selectedIcon: LucideIcons.home,
          label: 'Home',
          body: CustomerHomeScreen(),
        ),
        NavTab(
          icon: LucideIcons.calendarCheck,
          selectedIcon: LucideIcons.calendarCheck,
          label: 'Bookings',
          body: CustomerBookingsScreen(),
        ),
        NavTab(
          icon: LucideIcons.messageCircle,
          selectedIcon: LucideIcons.messageCircle,
          label: 'Messages',
          body: CustomerMessagesScreen(),
          // No unread-tracking on messages yet (would need a per-participant
          // read receipt on each conversation) — was hardcoded on before,
          // now honestly off rather than a permanent fake badge.
        ),
        NavTab(
          icon: LucideIcons.user,
          selectedIcon: LucideIcons.user,
          label: 'Profile',
          body: CustomerProfileScreen(),
        ),
      ],
    );
  }
}
