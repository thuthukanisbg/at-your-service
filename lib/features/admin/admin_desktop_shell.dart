import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/theme_mode_controller.dart';
import '../../core/utils/user_display_name.dart';
import '../onboarding/splash_screen.dart';
import 'admin_desktop_bookings.dart';
import 'admin_desktop_catalog.dart';
import 'admin_desktop_customers.dart';
import 'admin_desktop_disputes.dart';
import 'admin_desktop_overview.dart';
import 'admin_desktop_payments.dart';
import 'admin_desktop_providers.dart';
import 'admin_desktop_team.dart';

class _DesktopNavEntry {
  const _DesktopNavEntry({required this.icon, required this.label, required this.pageLabel, required this.body});
  final IconData icon;
  final String label;
  final String pageLabel;
  final Widget body;
}

final _entries = [
  const _DesktopNavEntry(icon: LucideIcons.layoutDashboard, label: 'Overview', pageLabel: 'Overview', body: AdminDesktopOverview()),
  const _DesktopNavEntry(icon: LucideIcons.calendarCheck, label: 'Bookings', pageLabel: 'Bookings', body: AdminDesktopBookings()),
  const _DesktopNavEntry(icon: LucideIcons.users, label: 'Providers', pageLabel: 'Providers', body: AdminDesktopProviders()),
  const _DesktopNavEntry(icon: LucideIcons.user, label: 'Customers', pageLabel: 'Customers', body: AdminDesktopCustomers()),
  const _DesktopNavEntry(icon: LucideIcons.wallet, label: 'Payments', pageLabel: 'Payments & Payouts', body: AdminDesktopPayments()),
  const _DesktopNavEntry(icon: LucideIcons.lifeBuoy, label: 'Disputes', pageLabel: 'Disputes & Support', body: AdminDesktopDisputes()),
  const _DesktopNavEntry(icon: LucideIcons.tag, label: 'Catalog', pageLabel: 'Service Catalog', body: AdminDesktopCatalog()),
  const _DesktopNavEntry(icon: LucideIcons.shieldCheck, label: 'Team & Roles', pageLabel: 'Team & Roles', body: AdminDesktopTeam()),
];

/// Persistent left-sidebar shell for Admin on a wide (desktop-browser)
/// viewport, matching the Admin Dashboard design handoff: 248px sidebar
/// (nav + theme toggle + account footer) and a 64px top bar (breadcrumb,
/// search, notifications, avatar).
class AdminDesktopShell extends StatefulWidget {
  const AdminDesktopShell({super.key});

  @override
  State<AdminDesktopShell> createState() => _AdminDesktopShellState();
}

class _AdminDesktopShellState extends State<AdminDesktopShell> {
  int _index = 0;
  late final Future<String?> _displayNameFuture = _loadDisplayName();

  Future<String?> _loadDisplayName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return fetchUserDisplayName(uid);
  }

  Future<void> _signOut() async {
    await AuthService.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SplashScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 248,
            decoration: BoxDecoration(color: tokens.surface, border: Border(right: BorderSide(color: tokens.line))),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 22),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(10)),
                          alignment: Alignment.center,
                          child: const Icon(LucideIcons.home, size: 18, color: Color(0xFF0B132B)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('At Your Service', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: tokens.tx, letterSpacing: -0.2)),
                              Text('Admin Console', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: tokens.mut)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  for (var i = 0; i < _entries.length; i++)
                    _SidebarItem(entry: _entries[i], selected: i == _index, onTap: () => setState(() => _index = i)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.only(top: 14),
                    decoration: BoxDecoration(border: Border(top: BorderSide(color: tokens.line))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ValueListenableBuilder<ThemeMode>(
                          valueListenable: ThemeModeController.mode,
                          builder: (context, mode, _) {
                            final isDark = mode == ThemeMode.dark;
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: ThemeModeController.toggle,
                                borderRadius: BorderRadius.circular(11),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                                  decoration: BoxDecoration(color: tokens.elev, border: Border.all(color: tokens.line), borderRadius: BorderRadius.circular(11)),
                                  child: Row(
                                    children: [
                                      Icon(isDark ? LucideIcons.sun : LucideIcons.moon, size: 15, color: tokens.tx),
                                      const SizedBox(width: 10),
                                      Text(isDark ? 'Light mode' : 'Dark mode', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: tokens.tx)),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        FutureBuilder<String?>(
                          future: _displayNameFuture,
                          builder: (context, snapshot) {
                            final name = snapshot.data ?? 'Admin';
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                    alignment: Alignment.center,
                                    child: Text(_initialsFor(name), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: tokens.tx)),
                                        Text('Administrator', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: tokens.mut)),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: _signOut,
                                    child: Icon(LucideIcons.logOut, size: 15, color: tokens.mut),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: tokens.line))),
                  child: Row(
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: 'Admin ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: tokens.mut)),
                            WidgetSpan(child: Icon(LucideIcons.chevronRight, size: 12, color: tokens.mut), alignment: PlaceholderAlignment.middle),
                            TextSpan(text: ' ${_entries[_index].pageLabel}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: tokens.tx)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: SizedBox(
                            height: 38,
                            child: TextField(
                              enabled: false,
                              decoration: InputDecoration(
                                isDense: true,
                                prefixIcon: Icon(LucideIcons.search, size: 15, color: tokens.mut),
                                hintText: 'Search bookings, providers, customers…',
                                filled: true,
                                fillColor: tokens.elev,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: tokens.line)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(color: tokens.elev, border: Border.all(color: tokens.line), borderRadius: BorderRadius.circular(10)),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(LucideIcons.bell, size: 16, color: tokens.tx),
                            const Positioned(top: 8, right: 9, child: _NotificationDot()),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      FutureBuilder<String?>(
                        future: _displayNameFuture,
                        builder: (context, snapshot) {
                          return Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            alignment: Alignment.center,
                            child: Text(_initialsFor(snapshot.data ?? 'Admin'), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ColoredBox(
                    color: tokens.bg,
                    child: IndexedStack(index: _index, children: [for (final entry in _entries) entry.body]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationDot extends StatelessWidget {
  const _NotificationDot();

  @override
  Widget build(BuildContext context) {
    return Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle));
  }
}

String _initialsFor(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({required this.entry, required this.selected, required this.onTap});

  final _DesktopNavEntry entry;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = selected ? AppColors.primary : tokens.mut;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: selected ? AppColors.primary.withValues(alpha: 0.14) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(entry.icon, size: 17, color: color),
                const SizedBox(width: 11),
                Expanded(child: Text(entry.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
