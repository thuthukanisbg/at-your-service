import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/primary_cta_button.dart';
import '../role_select/role_select_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  static const routeName = '/auth';

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _signIn = true;
  bool _submitting = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _comingSoon(String what) {
    _showSnack('$what arrives in the next milestone.');
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty || (!_signIn && name.isEmpty)) {
      _showSnack('Please fill in all fields.');
      return;
    }
    setState(() => _submitting = true);
    try {
      if (_signIn) {
        await AuthService.instance.signIn(email: email, password: password);
      } else {
        await AuthService.instance.signUp(name: name, email: email, password: password);
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RoleSelectScreen()),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      _showSnack(e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      _showSnack('Something went wrong. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
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
            if (!_signIn)
              _AuthTextField(
                controller: _nameController,
                label: 'Full name',
                icon: LucideIcons.user,
                hint: 'Thandi Nkosi',
              ),
            _AuthTextField(
              controller: _emailController,
              label: 'Email',
              icon: LucideIcons.mail,
              hint: 'you@email.co.za',
              keyboardType: TextInputType.emailAddress,
            ),
            _AuthTextField(
              controller: _passwordController,
              label: 'Password',
              icon: LucideIcons.lock,
              hint: '••••••••',
              obscure: true,
            ),
            const SizedBox(height: 8),
            PrimaryCtaButton(
              label: _submitting
                  ? (_signIn ? 'Signing In…' : 'Creating Account…')
                  : (_signIn ? 'Sign In' : 'Create Account'),
              onPressed: _submitting ? null : _submit,
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
                Expanded(child: _SocialButton(icon: LucideIcons.mail, label: 'Google', onTap: () => _comingSoon('Google sign-in'))),
                const SizedBox(width: 11),
                Expanded(child: _SocialButton(icon: LucideIcons.smartphone, label: 'Phone', onTap: () => _comingSoon('Phone sign-in'))),
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

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: tokens.mut)),
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
                Icon(icon, size: 18, color: tokens.mut),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    obscureText: obscure,
                    keyboardType: keyboardType,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: tokens.tx),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: hint,
                      hintStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: tokens.mut),
                    ),
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
