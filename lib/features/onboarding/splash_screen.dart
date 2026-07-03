import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import 'auth_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const routeName = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _floatyController;

  @override
  void initState() {
    super.initState();
    _floatyController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.36, -1),
            end: Alignment(0.36, 1),
            colors: [Color(0xFF1E3ABA), Color(0xFF0B132B)],
            stops: [0.0, 0.72],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(40),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _floatyController,
                        builder: (context, child) => Transform.translate(
                          offset: Offset(0, -6 * _floatyController.value),
                          child: child,
                        ),
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(color: AppColors.accent.withValues(alpha: 0.4), blurRadius: 40, offset: const Offset(0, 18)),
                            ],
                          ),
                          child: const Icon(LucideIcons.home, size: 46, color: AppColors.accentOnAccent),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'At Your Service',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -0.8, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Trusted people. Quality service.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.75)),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Every time.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.accent),
                      ),
                      const SizedBox(height: 42),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.accentOnAccent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            textStyle: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800),
                          ),
                          child: const Text('Get Started'),
                        ),
                      ),
                      const SizedBox(height: 13),
                      TextButton(
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const AuthScreen()),
                        ),
                        child: Text(
                          'I already have an account',
                          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.8)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
