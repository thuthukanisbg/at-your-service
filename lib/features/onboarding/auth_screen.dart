import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/primary_cta_button.dart';
import '../../models/user_role.dart';
import '../admin/admin_login_screen.dart';
import '../admin/admin_shell.dart';
import '../customer/customer_shell.dart';
import '../provider/provider_shell.dart';
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

  void _openPhoneSignIn(BuildContext context) {
    final tokens = context.tokens;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: tokens.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => _PhoneSignInSheet(
        onVerified: () async {
          Navigator.of(sheetContext).pop();
          final savedRole = await AuthService.instance.fetchSavedRole();
          if (!context.mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => _screenFor(savedRole)),
          );
        },
      ),
    );
  }

  Widget _screenFor(UserRole? role) {
    return switch (role) {
      UserRole.customer => const CustomerShell(),
      UserRole.provider => const ProviderShell(),
      UserRole.admin => const AdminShell(),
      null => const RoleSelectScreen(),
    };
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
      // A returning user who already picked a role in an earlier session
      // skips RoleSelectScreen entirely; a brand-new one (role still null)
      // falls through to it exactly as before.
      final savedRole = await AuthService.instance.fetchSavedRole();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => _screenFor(savedRole)),
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
                Expanded(child: _SocialButton(icon: LucideIcons.smartphone, label: 'Phone', onTap: () => _openPhoneSignIn(context))),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 22),
              child: Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                  ),
                  child: Text(
                    'Admin? Sign in here',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: tokens.mut),
                  ),
                ),
              ),
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

/// Two-step phone sign-in: enter a number, then the SMS code sent to it.
/// On web (this app's only tested platform) FirebaseAuth shows its own
/// invisible reCAPTCHA challenge automatically before sending the code.
class _PhoneSignInSheet extends StatefulWidget {
  const _PhoneSignInSheet({required this.onVerified});

  final Future<void> Function() onVerified;

  @override
  State<_PhoneSignInSheet> createState() => _PhoneSignInSheetState();
}

class _PhoneSignInSheetState extends State<_PhoneSignInSheet> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  ConfirmationResult? _confirmation;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() => _error = 'Enter a phone number.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final confirmation = await AuthService.instance.sendPhoneVerificationCode(phone);
      if (!mounted) return;
      setState(() {
        _confirmation = confirmation;
        _submitting = false;
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = 'Something went wrong. Please try again.';
      });
    }
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Enter the code you received.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await AuthService.instance.confirmPhoneCode(confirmation: _confirmation!, smsCode: code);
      await widget.onVerified();
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final codeStep = _confirmation != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            codeStep ? 'Enter verification code' : 'Sign in with phone',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: tokens.tx),
          ),
          const SizedBox(height: 4),
          Text(
            codeStep ? 'Sent to ${_phoneController.text.trim()}.' : "We'll text you a one-time code.",
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: tokens.mut),
          ),
          const SizedBox(height: 16),
          TextField(
            key: ValueKey(codeStep),
            controller: codeStep ? _codeController : _phoneController,
            keyboardType: codeStep ? TextInputType.number : TextInputType.phone,
            autofocus: true,
            decoration: InputDecoration(
              hintText: codeStep ? '123456' : '+27 82 123 4567',
              border: const OutlineInputBorder(),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(_error!, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.danger)),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _submitting ? null : (codeStep ? _verifyCode : _sendCode),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              child: Text(_submitting ? 'Please wait…' : (codeStep ? 'Verify' : 'Send Code')),
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
