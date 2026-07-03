import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/widgets/role_nav_shell.dart';
import 'provider_earnings_screen.dart';
import 'provider_jobs_screen.dart';
import 'provider_profile_screen.dart';
import 'provider_schedule_screen.dart';

class ProviderShell extends StatelessWidget {
  const ProviderShell({super.key});

  static const routeName = '/provider';

  @override
  Widget build(BuildContext context) {
    return const RoleNavShell(
      tabs: [
        NavTab(
          icon: LucideIcons.briefcase,
          selectedIcon: LucideIcons.briefcase,
          label: 'Jobs',
          body: ProviderJobsScreen(),
        ),
        NavTab(
          icon: LucideIcons.calendar,
          selectedIcon: LucideIcons.calendar,
          label: 'Schedule',
          body: ProviderScheduleScreen(),
        ),
        NavTab(
          icon: LucideIcons.wallet,
          selectedIcon: LucideIcons.wallet,
          label: 'Earnings',
          body: ProviderEarningsScreen(),
        ),
        NavTab(
          icon: LucideIcons.user,
          selectedIcon: LucideIcons.user,
          label: 'Profile',
          body: ProviderProfileScreen(),
        ),
      ],
    );
  }
}
