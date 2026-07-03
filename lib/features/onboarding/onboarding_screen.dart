import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/primary_cta_button.dart';
import 'auth_screen.dart';

class _OnboardingSlide {
  const _OnboardingSlide(this.icon, this.title, this.description, this.bg, this.fg);
  final IconData icon;
  final String title;
  final String description;
  final Color bg;
  final Color fg;
}

const _slides = [
  _OnboardingSlide(
    LucideIcons.search,
    'Find trusted pros',
    'Browse verified professionals for every home service you need.',
    Color(0x1F2E7DFF), // rgba(46,125,255,.12)
    AppColors.primary,
  ),
  _OnboardingSlide(
    LucideIcons.calendarCheck,
    'Book in seconds',
    'Pick a time that works, pay securely, and relax — we handle the rest.',
    Color(0x24FFC107), // rgba(255,193,7,.14)
    AppColors.accent,
  ),
  _OnboardingSlide(
    LucideIcons.shieldCheck,
    'Safe & guaranteed',
    'Every pro is background-checked. Your satisfaction is guaranteed.',
    Color(0x1F2ECC71), // rgba(46,204,113,.12)
    AppColors.success,
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const routeName = '/onboarding';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;

  void _goToAuth() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AuthScreen()));
  }

  void _next() {
    if (_step == _slides.length - 1) {
      _goToAuth();
    } else {
      setState(() => _step += 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final slide = _slides[_step];
    final isLast = _step == _slides.length - 1;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _goToAuth,
                child: Text('Skip', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: tokens.mut)),
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Container(
                width: 196,
                height: 196,
                decoration: BoxDecoration(color: slide.bg, borderRadius: BorderRadius.circular(30)),
                child: Icon(slide.icon, size: 84, color: slide.fg),
              ),
            ),
            const SizedBox(height: 34),
            Text(
              slide.title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: tokens.tx),
            ),
            const SizedBox(height: 11),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 284),
                child: Text(
                  slide.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500, height: 1.55, color: tokens.mut),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _slides.length; i++) ...[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: i == _step ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _step ? AppColors.primary : tokens.line,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  if (i != _slides.length - 1) const SizedBox(width: 8),
                ],
              ],
            ),
            const SizedBox(height: 24),
            PrimaryCtaButton(
              label: isLast ? 'Get Started' : 'Next',
              onPressed: _next,
            ),
          ],
        ),
      ),
    );
  }
}
