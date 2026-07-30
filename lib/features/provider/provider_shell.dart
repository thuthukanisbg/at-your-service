import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/widgets/role_nav_shell.dart';
import 'provider_earnings_screen.dart';
import 'provider_jobs_screen.dart';
import 'provider_messages_screen.dart';
import 'provider_profile_screen.dart';
import 'provider_schedule_screen.dart';
import '../messaging/messaging_service.dart';

class ProviderShell extends StatelessWidget {
  const ProviderShell({super.key});

  static const routeName = '/provider';

  @override
  Widget build(BuildContext context) {
    return RoleNavShell(
      tabs: [
        const NavTab(
          icon: LucideIcons.briefcase,
          selectedIcon: LucideIcons.briefcase,
          label: 'Jobs',
          body: ProviderJobsScreen(),
        ),
        const NavTab(
          icon: LucideIcons.calendar,
          selectedIcon: LucideIcons.calendar,
          label: 'Schedule',
          body: ProviderScheduleScreen(),
        ),
        NavTab(
          icon: LucideIcons.messageCircle,
          selectedIcon: LucideIcons.messageCircle,
          label: 'Messages',
          body: const ProviderMessagesScreen(),
          badgeStream: watchHasUnreadProviderConversations(),
        ),
        const NavTab(
          icon: LucideIcons.wallet,
          selectedIcon: LucideIcons.wallet,
          label: 'Earnings',
          body: ProviderEarningsScreen(),
        ),
        const NavTab(
          icon: LucideIcons.user,
          selectedIcon: LucideIcons.user,
          label: 'Profile',
          body: ProviderProfileScreen(),
        ),
      ],
    );
  }
}
