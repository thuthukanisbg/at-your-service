import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/mobile_frame.dart';
import '../../core/widgets/primary_cta_button.dart';
import '../../models/user_role.dart';
import 'admin_shell.dart';

/// A dedicated, desktop-styled sign-in for Admin — deliberately separate
/// from the shared Splash/Onboarding/Auth carousel the customer/provider
/// roles use (that flow is phone-frame styled by design; this one never is,
/// via the same `MobileFrame.requestWideLayout`/`releaseWideLayout` opt-out
/// `AdminShell` uses). Reachable at its own route ([routeName]) independent
/// of the rest of the entry flow, and also linked from the regular Auth
/// screen.
///
/// Sign-in only, deliberately — no self-service admin account creation here.
/// On success, only an account already provisioned with the `admin` role can
/// enter the dashboard. New and non-admin accounts are signed back out.
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  static const routeName = '/admin-login';

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Deferred: see AdminShell's own identical comment — MobileFrame's
    // ValueListenableBuilder is still mid-build the moment this screen
    // first mounts, so flipping the notifier synchronously here throws
    // "setState() called during build".
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MobileFrame.requestWideLayout();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MobileFrame.releaseWideLayout();
    });
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter both email and password.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await AuthService.instance.signIn(email: email, password: password);
      final savedRole = await AuthService.instance.fetchSavedRole();
      if (savedRole != UserRole.admin) {
        await AuthService.instance.signOut();
        throw const AuthException("This account isn't an admin account.");
      }
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const AdminShell()));
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
    return Scaffold(
      backgroundColor: tokens.bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: tokens.card,
                border: Border.all(color: tokens.line),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          LucideIcons.home,
                          size: 20,
                          color: Color(0xFF0B132B),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'At Your Service',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: tokens.tx,
                            ),
                          ),
                          Text(
                            'Admin Console',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: tokens.mut,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Admin sign in',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: tokens.tx,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Operations & management access only.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: tokens.mut,
                    ),
                  ),
                  const SizedBox(height: 26),
                  _DesktopField(
                    controller: _emailController,
                    label: 'Email',
                    icon: LucideIcons.mail,
                    hint: 'you@atyourservice.co.za',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _DesktopField(
                    controller: _passwordController,
                    label: 'Password',
                    icon: LucideIcons.lock,
                    hint: '••••••••',
                    obscure: true,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      _error!,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  PrimaryCtaButton(
                    label: _submitting ? 'Signing In…' : 'Sign In',
                    onPressed: _submitting ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopField extends StatelessWidget {
  const _DesktopField({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: tokens.mut,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: tokens.elev,
            border: Border.all(color: tokens.line),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            children: [
              Icon(icon, size: 17, color: tokens.mut),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscure,
                  keyboardType: keyboardType,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: tokens.tx,
                  ),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: tokens.mut,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
