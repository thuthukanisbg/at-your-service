import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/primary_cta_button.dart';

class _VerifyStepDef {
  const _VerifyStepDef(this.title, this.description, this.icon, {this.selfAttestable = false});
  final String title;
  final String description;
  final IconData icon;

  /// True for steps the provider submits themselves (their own info/
  /// documents) — false for steps only an external check can resolve (ID
  /// scan, background screening), which have no tappable action here.
  final bool selfAttestable;
}

const _steps = [
  _VerifyStepDef('ID Verification', 'Secure identity check', LucideIcons.scanFace),
  _VerifyStepDef('Selfie Match', 'Face verification for safety', LucideIcons.smile),
  _VerifyStepDef('Proof of Address', 'Verify residential address', LucideIcons.home),
  _VerifyStepDef('Background Check', 'Criminal record screening', LucideIcons.fileSearch),
  _VerifyStepDef('Skills & Experience', 'Certifications & qualifications', LucideIcons.award, selfAttestable: true),
  _VerifyStepDef('References', 'Customer & employer references', LucideIcons.users, selfAttestable: true),
  _VerifyStepDef('Approved', 'Verified & ready to work', LucideIcons.badgeCheck),
];

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  int _verifyStep = 4; // matches the handoff's initial demo state

  bool get _isDone => _verifyStep >= _steps.length;

  void _advance() {
    setState(() {
      var next = _verifyStep + 1;
      // 'Approved' (the last row) isn't provider-submitted — it's granted
      // once everything before it is done, so reaching it completes the
      // flow immediately rather than sitting as its own interactive step.
      if (next == _steps.length - 1 && !_steps[next].selfAttestable) {
        next = _steps.length;
      }
      _verifyStep = next.clamp(0, _steps.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final doneCount = _verifyStep.clamp(0, _steps.length);
    final percent = doneCount / _steps.length;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
          children: [
            Text(
              'Provider Verification',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: tokens.tx),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 3, bottom: 16),
              child: Text(
                'A safe & trusted community for everyone.',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: tokens.mut),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: tokens.card,
                  border: Border.all(color: tokens.line),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: FractionallySizedBox(
                  widthFactor: percent,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [AppColors.primary, AppColors.accent],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 18),
              child: Text(
                '$doneCount of ${_steps.length} complete',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: tokens.mut),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: tokens.card,
                border: Border.all(color: tokens.line),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < _steps.length; i++)
                    _VerifyStepRow(
                      step: _steps[i],
                      done: i < _verifyStep,
                      active: i == _verifyStep,
                      isLast: i == _steps.length - 1,
                    ),
                ],
              ),
            ),
            if (_isDone)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withValues(alpha: 0.6),
                            blurRadius: 28,
                            offset: const Offset(0, 12),
                            spreadRadius: -8,
                          ),
                        ],
                      ),
                      child: const Icon(LucideIcons.check, size: 32, color: Colors.white),
                    ),
                    Text(
                      'Verified & ready to work! 🎉',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: tokens.tx),
                    ),
                  ],
                ),
              )
            else if (_steps[_verifyStep].selfAttestable)
              PrimaryCtaButton(
                label: 'Submit: ${_steps[_verifyStep].title}',
                onPressed: _advance,
              )
            else
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: tokens.card,
                  border: Border.all(color: tokens.line),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.clock, size: 16, color: tokens.mut),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${_steps[_verifyStep].title} is checked by our team — we\'ll notify you once it\'s done.',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: tokens.mut),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _VerifyStepRow extends StatelessWidget {
  const _VerifyStepRow({required this.step, required this.done, required this.active, required this.isLast});

  final _VerifyStepDef step;
  final bool done;
  final bool active;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final Color dotColor = done ? AppColors.success : (active ? AppColors.primary : tokens.chip);
    final Color dotIconColor = done || active ? Colors.white : tokens.mut;
    final Color lineColor = done ? AppColors.success : tokens.line;
    final Color titleColor = done || active ? tokens.tx : tokens.mut;
    final Color badgeColor = done ? AppColors.success : (active ? AppColors.primary : tokens.mut);
    final Color badgeBg = done ? const Color(0x1F2ECC71) : (active ? const Color(0x1F2E7DFF) : tokens.chip);
    final String status = done
        ? (step.selfAttestable ? 'Submitted' : 'Verified')
        : (active
            ? (step.selfAttestable ? 'Action needed' : 'In review')
            : 'Pending');

    final dot = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
      child: Icon(done ? LucideIcons.check : step.icon, size: 15, color: dotIconColor),
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              dot,
              if (!isLast)
                Expanded(
                  child: Container(width: 2, constraints: const BoxConstraints(minHeight: 18), color: lineColor),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(step.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: titleColor)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(999)),
                        child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: badgeColor)),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      step.description,
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, height: 1.4, color: tokens.mut),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
