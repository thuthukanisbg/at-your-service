import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/primary_cta_button.dart';
import '../role_select/role_select_screen.dart';

class _AuthField {
  const _AuthField(this.label, this.icon, this.hint);
  final String label;
  final IconData icon;
  final String hint;
}

const _signInFields = [
  _AuthField('Email', LucideIcons.mail, 'you@email.co.za'),
  _AuthField('Password', LucideIcons.lock, '••••••••'),
];

const _signUpFields = [
  _AuthField('Full name', LucideIcons.user, 'Thandi Nkosi'),
  _AuthField('Email', LucideIcons.mail, 'you@email.co.za'),
  _AuthField('Password', LucideIcons.lock, '••••••••'),
];

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  static const routeName = '/auth';

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _signIn = true;

  void _goToChooser() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const RoleSelectScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final fields = _signIn ? _signInFields : _signUpFields;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 28),
          children: [
            Center(
              child: Container(
                width: 58,
                height: 58,
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(17)),
                child: const Icon(LucideIcons.home, size: 30, color: AppColors.accentOnAccent),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 4),
              child: Text(
                _signIn ? 'Welcome back' : 'Create account',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: tokens.tx),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Text(
                _signIn ? 'Sign in to continue' : 'Join thousands of happy customers',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: tokens.mut),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(5),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: tokens.card,
                border: Border.all(color: tokens.line),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                children: [
                  Expanded(child: _AuthTab(label: 'Sign In', selected: _signIn, onTap: () => setState(() => _signIn = true))),
                  const SizedBox(width: 8),
                  Expanded(child: _AuthTab(label: 'Sign Up', selected: !_signIn, onTap: () => setState(() => _signIn = false))),
                ],
              ),
            ),
            for (final field in fields) _AuthFieldDisplay(field: field),
            const SizedBox(height: 8),
            PrimaryCtaButton(
              label: _signIn ? 'Sign In' : 'Create Account',
              onPressed: _goToChooser,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: Divider(color: tokens.line, height: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or continue with', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: tokens.mut)),
                ),
                Expanded(child: Divider(color: tokens.line, height: 1)),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: _SocialButton(icon: LucideIcons.mail, label: 'Google', onTap: _goToChooser)),
                const SizedBox(width: 11),
                Expanded(child: _SocialButton(icon: LucideIcons.smartphone, label: 'Phone', onTap: _goToChooser)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthTab extends StatelessWidget {
  const _AuthTab({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : tokens.mut,
          ),
        ),
      ),
    );
  }
}

class _AuthFieldDisplay extends StatelessWidget {
  const _AuthFieldDisplay({required this.field});

  final _AuthField field;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(field.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: tokens.mut)),
          const SizedBox(height: 7),
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: tokens.card,
              border: Border.all(color: tokens.line),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                Icon(field.icon, size: 18, color: tokens.mut),
                const SizedBox(width: 10),
                Text(field.hint, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: tokens.mut)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: tokens.card,
          border: Border.all(color: tokens.line),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: tokens.tx),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: tokens.tx)),
          ],
        ),
      ),
    );
  }
}
