import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../platform/platform_design.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

class NavTab {
  const NavTab({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.body,
    this.showBadge = false,
    this.badgeStream,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Widget body;
  final bool showBadge;
  final Stream<bool>? badgeStream;
}

/// Persistent role shell with shared state/content and native-feeling
/// navigation presentation: Cupertino tabs on iOS and a Material 3
/// NavigationBar on Android.
class RoleNavShell extends StatefulWidget {
  const RoleNavShell({super.key, required this.tabs});

  final List<NavTab> tabs;

  @override
  State<RoleNavShell> createState() => _RoleNavShellState();
}

class _RoleNavShellState extends State<RoleNavShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [for (final tab in widget.tabs) tab.body],
      ),
      bottomNavigationBar:
          context.usesCupertinoDesign
              ? CupertinoTabBar(
                currentIndex: _index,
                onTap: (index) => setState(() => _index = index),
                activeColor: AppColors.primary,
                inactiveColor: tokens.mut,
                backgroundColor: tokens.surface.withValues(alpha: 0.96),
                border: Border(top: BorderSide(color: tokens.line, width: 0.5)),
                iconSize: 22,
                height: 52,
                items: [
                  for (final tab in widget.tabs)
                    BottomNavigationBarItem(
                      icon: _TabIcon(tab: tab, selected: false),
                      activeIcon: _TabIcon(tab: tab, selected: true),
                      label: tab.label,
                    ),
                ],
              )
              : NavigationBar(
                selectedIndex: _index,
                onDestinationSelected:
                    (index) => setState(() => _index = index),
                destinations: [
                  for (final tab in widget.tabs)
                    NavigationDestination(
                      icon: _TabIcon(tab: tab, selected: false),
                      selectedIcon: _TabIcon(tab: tab, selected: true),
                      label: tab.label,
                    ),
                ],
              ),
    );
  }
}

class _TabIcon extends StatelessWidget {
  const _TabIcon({required this.tab, required this.selected});

  final NavTab tab;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(selected ? tab.selectedIcon : tab.icon, size: 22);
    if (tab.badgeStream != null) {
      return StreamBuilder<bool>(
        stream: tab.badgeStream,
        initialData: false,
        builder: (context, snapshot) {
          return snapshot.data ?? false
              ? Badge(backgroundColor: AppColors.danger, child: icon)
              : icon;
        },
      );
    }
    if (!tab.showBadge) return icon;
    return Badge(backgroundColor: AppColors.danger, child: icon);
  }
}
