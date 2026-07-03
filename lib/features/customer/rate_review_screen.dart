import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/detail_screen_header.dart';
import '../../core/widgets/primary_cta_button.dart';

const _tags = ['Professional', 'On time', 'Friendly', 'Great result'];

class RateReviewScreen extends StatefulWidget {
  const RateReviewScreen({super.key});

  static const routeName = '/customer/rate';

  @override
  State<RateReviewScreen> createState() => _RateReviewScreenState();
}

class _RateReviewScreenState extends State<RateReviewScreen> {
  int _rating = 4; // matches the handoff's initial state
  final Set<String> _selectedTags = {};

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: DetailScreenHeader(title: 'Rate & Review'),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 8),
              child: Column(
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: const Text('SM', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 13),
                    child: Text('Sipho M.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: tokens.tx)),
                  ),
                  Text('Cleaning Specialist', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: tokens.mut)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 18, bottom: 12),
              child: Text(
                'How was your experience?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: tokens.mut),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var n = 1; n <= 5; n++) ...[
                    _StarButton(filled: n <= _rating, onTap: () => setState(() => _rating = n)),
                    if (n != 5) const SizedBox(width: 10),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tag in _tags)
                    _TagChip(
                      label: tag,
                      selected: _selectedTags.contains(tag),
                      onTap: () => setState(() {
                        if (!_selectedTags.remove(tag)) _selectedTags.add(tag);
                      }),
                    ),
                ],
              ),
            ),
            Container(
              constraints: const BoxConstraints(minHeight: 74),
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 22),
              decoration: BoxDecoration(
                color: tokens.card,
                border: Border.all(color: tokens.line),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                maxLines: null,
                minLines: 2,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: tokens.tx),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: 'Tell us about your experience…',
                  hintStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: tokens.mut),
                ),
              ),
            ),
            PrimaryCtaButton(
              label: 'Submit Review',
              style: AppTheme.amberAction,
              shadowColor: AppColors.accent,
              shadowAlpha: 0.6,
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : tokens.card,
          border: selected ? null : Border.all(color: tokens.line),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : tokens.tx,
          ),
        ),
      ),
    );
  }
}

class _StarButton extends StatelessWidget {
  const _StarButton({required this.filled, required this.onTap});

  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Transform.scale(
          scale: filled ? 1.08 : 1.0,
          child: Icon(
            LucideIcons.star,
            size: 36,
            color: filled ? AppColors.accent : AppColors.accent.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }
}
