import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/primary_cta_button.dart';
import 'provider_mock_data.dart';

class ProviderInProgressScreen extends StatefulWidget {
  const ProviderInProgressScreen({super.key});

  @override
  State<ProviderInProgressScreen> createState() => _ProviderInProgressScreenState();
}

class _ProviderInProgressScreenState extends State<ProviderInProgressScreen> {
  // Matches the handoff's initial demo state: first two tasks already done.
  final List<bool> _done = [true, true, false, false];

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
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Job in Progress',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: tokens.tx),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0x1F2E7DFF), // rgba(46,125,255,.12)
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.clock, size: 13, color: AppColors.primary),
                        SizedBox(width: 6),
                        Text('00:45:30', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.primary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: tokens.card,
                border: Border.all(color: tokens.line),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < providerTaskLabels.length; i++)
                    _TaskRow(
                      label: providerTaskLabels[i],
                      done: _done[i],
                      onTap: () => setState(() => _done[i] = !_done[i]),
                    ),
                ],
              ),
            ),
            Text('Add photos', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: tokens.tx)),
            const SizedBox(height: 11),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                children: [
                  Expanded(child: _PhotoSlot(label: 'Before', onTap: () => _comingSoon(context, 'Photo upload'))),
                  const SizedBox(width: 10),
                  Expanded(child: _PhotoSlot(label: 'After', onTap: () => _comingSoon(context, 'Photo upload'))),
                ],
              ),
            ),
            PrimaryCtaButton(
              label: 'Complete Job',
              icon: LucideIcons.checkCheck,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                textStyle: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800),
              ),
              shadowColor: AppColors.success,
              shadowAlpha: 0.6,
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.label, required this.done, required this.onTap});

  final String label;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: tokens.line))),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: done ? AppColors.success : Colors.transparent,
                border: Border.all(color: done ? AppColors.success : tokens.mut, width: 2),
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Icon(LucideIcons.check, size: 14, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: done ? tokens.mut : tokens.tx,
                  decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: done ? const Color(0x1F2ECC71) : const Color(0x1F2E7DFF),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                done ? 'Completed' : 'In progress',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: done ? AppColors.success : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  const _PhotoSlot({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      // Flutter has no built-in dashed Border (BorderStyle is solid-or-none
      // only); a solid 1.5px line is a reasonable stand-in for this
      // decorative upload slot rather than a custom dash painter.
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(color: tokens.line, width: 1.5),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.camera, size: 20, color: tokens.mut),
            const SizedBox(height: 5),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: tokens.mut)),
          ],
        ),
      ),
    );
  }
}
