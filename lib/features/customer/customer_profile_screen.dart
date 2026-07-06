import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../onboarding/splash_screen.dart';

/// Plain, functional profile tab — no design-handoff spec exists for this
/// (same situation as Admin's Providers tab), so this follows the app's
/// existing tokens/card visual pattern rather than a pixel-perfect match.
class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  late final Future<Map<String, dynamic>?> _profileFuture = _fetchProfile();

  Future<Map<String, dynamic>?> _fetchProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data();
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
    // Guarded like the fetch below — accessing FirebaseAuth.instance throws
    // synchronously with no live Firebase app (e.g. widget tests).
    String? authEmail;
    try {
      authEmail = FirebaseAuth.instance.currentUser?.email;
    } catch (_) {
      authEmail = null;
    }
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
          children: [
            Text(
              'Profile',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: tokens.tx),
            ),
            const SizedBox(height: 18),
            FutureBuilder<Map<String, dynamic>?>(
              future: _profileFuture,
              builder: (context, snapshot) {
                final data = snapshot.data;
                // Real user docs use `displayName`; ones created via this
                // app's own sign-up flow use `name` — check both.
                final displayName = data?['displayName'] as String?;
                final legacyName = data?['name'] as String?;
                final name = (displayName != null && displayName.isNotEmpty) ? displayName : (legacyName ?? 'Your account');
                final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: tokens.card,
                    border: Border.all(color: tokens.line),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: Text(initial, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: tokens.tx),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              authEmail ?? '—',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: tokens.mut),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _signOut,
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
