import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../models/user_role.dart';
import '../admin/admin_shell.dart';
import '../customer/customer_shell.dart';
import '../provider/provider_shell.dart';

/// Entry screen for the local-first rebuild ("chooser" in the design
/// handoff). Stands in for real authentication until Firebase Auth is
/// reconnected: picking a role drops straight into that role's home.
class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  static const routeName = '/chooser';

  void _selectRole(BuildContext context, UserRole role) {
    final routeName = switch (role) {
      UserRole.customer => CustomerShell.routeName,
      UserRole.provider => ProviderShell.routeName,
      UserRole.admin => AdminShell.routeName,
    };
    Navigator.of(context).pushNamed(routeName);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 34),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(19),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.35),
                            blurRadius: 28,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Icon(LucideIcons.home, size: 34, color: AppColors.accentOnAccent),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'At Your Service',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                        color: tokens.tx,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Choose your experience to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: tokens.mut),
                    ),
                    const SizedBox(height: 24),
                    for (final role in UserRole.values) ...[
                      _RoleCard(role: role, onTap: () => _selectRole(context, role)),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        children: const [
                          Expanded(child: _TrustBadge(icon: LucideIcons.creditCard, label: 'Secure Payments')),
                          Expanded(child: _TrustBadge(icon: LucideIcons.shieldCheck, label: 'Verified Pros')),
                          Expanded(child: _TrustBadge(icon: LucideIcons.headphones, label: '24/7 Support')),
                          Expanded(child: _TrustBadge(icon: LucideIcons.checkCircle2, label: 'Satisfaction')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.role, required this.onTap});

  final UserRole role;
  final VoidCallback onTap;

  bool get _primary => role == UserRole.customer;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final tagColor = _primary ? Colors.white.withValues(alpha: 0.85) : AppColors.primary;
    final titleColor = _primary ? Colors.white : tokens.tx;
    final descColor = _primary ? Colors.white.withValues(alpha: 0.8) : tokens.mut;
    final iconBg = _primary
        ? Colors.white.withValues(alpha: 0.16)
        : (role == UserRole.provider
            ? AppColors.accent.withValues(alpha: 0.16)
            : AppColors.primary.withValues(alpha: 0.14));
    final iconColor = _primary ? Colors.white : (role == UserRole.provider ? AppColors.accent : AppColors.primary);

    return Material(
      color: _primary ? null : tokens.card,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: _primary ? null : Border.all(color: tokens.line),
            gradient: _primary
                ? const LinearGradient(
                    begin: AppColors.heroGradientBegin,
                    end: AppColors.heroGradientEnd,
                    colors: AppColors.heroGradient,
                  )
                : null,
            boxShadow: _primary
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.7),
                      blurRadius: 30,
                      offset: const Offset(0, 14),
                      spreadRadius: -14,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(14)),
                child: Icon(role.icon, size: 23, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.intro,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.2, color: titleColor),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Text(
                        role.label,
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: tagColor),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        role.tagline,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: descColor, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight, size: 20, color: tagColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  const _TrustBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: tokens.card,
            border: Border.all(color: tokens.line),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, size: 19, color: AppColors.primary),
        ),
        const SizedBox(height: 7),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: tokens.mut, height: 1.25),
        ),
      ],
    );
  }
}
