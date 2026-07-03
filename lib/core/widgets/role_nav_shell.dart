import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

class NavTab {
  const NavTab({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.body,
    this.showBadge = false,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Widget body;
  final bool showBadge;
}

/// Persistent bottom-nav shell shared by all three roles. Each role passes
/// its own [NavTab]s — only the first tab needs to be a real screen.
///
/// This is a flat custom bar, not Material 3's [NavigationBar] — that widget
/// always reserves space for a pill-shaped selection indicator (even with
/// `indicatorColor: Colors.transparent`), which reads noticeably softer/more
/// padded than the handoff's minimal icon+label bar with no indicator at
/// all. Matches the handoff's literal `padding:9px 12px 24px` + 1px
/// top-border bar exactly instead.
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
    // The handoff hardcodes 24px as its emulated device's home-indicator
    // safe area. On a real device, use whichever is larger — the actual
    // inset (bigger on notched phones), or 24 (so it still matches the
    // handoff exactly on devices/browsers with no inset of their own).
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [for (final tab in widget.tabs) tab.body],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.surface,
          border: Border(top: BorderSide(color: tokens.line)),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, 9, 12, bottomInset > 24 ? bottomInset : 24),
          child: Row(
            children: [
              for (var i = 0; i < widget.tabs.length; i++)
                Expanded(
                  child: _NavItem(
                    tab: widget.tabs[i],
                    selected: i == _index,
                    onTap: () => setState(() => _index = i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.tab, required this.selected, required this.onTap});

  final NavTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = selected ? AppColors.primary : tokens.mut;
    final icon = Icon(selected ? tab.selectedIcon : tab.icon, size: 21, color: color);
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          tab.showBadge ? Badge(backgroundColor: AppColors.danger, child: icon) : icon,
          const SizedBox(height: 4),
          Text(tab.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}
