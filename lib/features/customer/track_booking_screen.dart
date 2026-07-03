import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/diagonal_stripes_painter.dart';
import 'rate_review_screen.dart';

enum _StepState { done, active, idle }

class _TrackStep {
  const _TrackStep(this.title, this.time, this.state);
  final String title;
  final String time;
  final _StepState state;

  IconData get icon => switch (state) {
        _StepState.done => LucideIcons.check,
        _StepState.active => LucideIcons.navigation,
        _StepState.idle => LucideIcons.clock,
      };
}

const _trackSteps = [
  _TrackStep('Booking confirmed', '10:02 AM', _StepState.done),
  _TrackStep('Pro assigned · Sipho M.', '10:05 AM', _StepState.done),
  _TrackStep('On the way', 'Now · 12 min', _StepState.active),
  _TrackStep('Service in progress', 'Pending', _StepState.idle),
];

class TrackBookingScreen extends StatelessWidget {
  const TrackBookingScreen({super.key});

  static const routeName = '/customer/track';

  void _comingSoon(BuildContext context, String what) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$what arrives in the next milestone.')),
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
              'My Booking',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.4, color: tokens.tx),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 150,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(painter: DiagonalStripesPainter(chip: tokens.chip, elev: tokens.elev)),
                    ),
                    Center(
                      child: Text(
                        '[ live map ]',
                        style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: tokens.mut),
                      ),
                    ),
                    Positioned(
                      top: 14,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                        decoration: BoxDecoration(
                          color: tokens.surface,
                          border: Border.all(color: tokens.line),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _PulsingOpacity(
                              duration: const Duration(milliseconds: 1400),
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                              ),
                            ),
                            const SizedBox(width: 7),
                            Text(
                              'Pro on the way · 12 min',
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: tokens.tx),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: tokens.card,
                border: Border.all(color: tokens.line),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: const Text('SM', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sipho M.', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: tokens.tx)),
                        Text(
                          'Cleaning Specialist · ⭐ 4.9',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: tokens.mut),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _CircleIconButton(icon: LucideIcons.phone, onTap: () => _comingSoon(context, 'Calling')),
                  const SizedBox(width: 12),
                  _CircleIconButton(icon: LucideIcons.messageCircle, onTap: () => _comingSoon(context, 'Chat')),
                ],
              ),
            ),
            Text('Booking status', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: tokens.tx)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 10),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: tokens.card,
                border: Border.all(color: tokens.line),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < _trackSteps.length; i++)
                    _TrackStepRow(step: _trackSteps[i], isLast: i == _trackSteps.length - 1),
                ],
              ),
            ),
            InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RateReviewScreen()),
              ),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tokens.card,
                  border: Border.all(color: tokens.line),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'Mark as complete & rate',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: tokens.tx),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: const Color(0x242E7DFF), borderRadius: BorderRadius.circular(11)),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
    );
  }
}

class _TrackStepRow extends StatelessWidget {
  const _TrackStepRow({required this.step, required this.isLast});

  final _TrackStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final Color dotColor = switch (step.state) {
      _StepState.done => AppColors.success,
      _StepState.active => AppColors.primary,
      _StepState.idle => tokens.chip,
    };
    final Color iconColor = step.state == _StepState.idle ? tokens.mut : Colors.white;
    final Color lineColor = step.state == _StepState.done ? AppColors.success : tokens.line;
    final Color titleColor = step.state == _StepState.idle ? tokens.mut : tokens.tx;

    final dot = Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
      child: Icon(step.icon, size: 13, color: iconColor),
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              step.state == _StepState.active
                  ? _PulsingOpacity(duration: const Duration(milliseconds: 1600), child: dot)
                  : dot,
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    constraints: const BoxConstraints(minHeight: 14),
                    color: lineColor,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.title, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: titleColor)),
                  Text(step.time, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: tokens.mut)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fades a child 1 ↔ .35 forever — the handoff's `pulseDot` keyframe, used
/// for the live-tracking badge dot and the active timeline step.
class _PulsingOpacity extends StatefulWidget {
  const _PulsingOpacity({required this.duration, required this.child});

  final Duration duration;
  final Widget child;

  @override
  State<_PulsingOpacity> createState() => _PulsingOpacityState();
}

class _PulsingOpacityState extends State<_PulsingOpacity> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0.35).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: widget.child,
    );
  }
}
