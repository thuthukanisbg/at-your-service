import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../onboarding/splash_screen.dart';

/// Plain, functional "More" tab — no design-handoff spec exists for this
/// (same situation as Providers/Bookings), so it's just account actions
/// for now rather than a pixel-perfect match to a nonexistent design.
class AdminMoreScreen extends StatelessWidget {
  const AdminMoreScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    await AuthService.instance.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SplashScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
          children: [
            Text(
              'More',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: tokens.tx),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => _signOut(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                ),
                icon: const Icon(LucideIcons.logOut, size: 18),
                label: const Text('Sign Out', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
