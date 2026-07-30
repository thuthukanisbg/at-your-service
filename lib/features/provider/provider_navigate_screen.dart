import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/detail_screen_header.dart';
import '../../core/widgets/diagonal_stripes_painter.dart';
import '../../core/widgets/primary_cta_button.dart';
import '../../models/provider_job.dart';
import 'provider_in_progress_screen.dart';
import 'provider_jobs_service.dart';

class ProviderNavigateScreen extends StatefulWidget {
  const ProviderNavigateScreen({super.key, this.job});

  /// Null only for the design preview and widget tests. Live navigation
  /// always carries the booking that was accepted.
  final ProviderJob? job;

  @override
  State<ProviderNavigateScreen> createState() => _ProviderNavigateScreenState();
}

class _ProviderNavigateScreenState extends State<ProviderNavigateScreen> {
  bool _starting = false;

  Future<void> _startJob() async {
    final job = widget.job;
    if (job?.id == null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ProviderInProgressScreen()),
      );
      return;
    }
    setState(() => _starting = true);
    try {
      await ProviderJobLifecycleService.instance.updateStatus(
        job!.id!,
        'in_progress',
      );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (_) => ProviderInProgressScreen(
                job: job.copyWith(status: 'in_progress'),
              ),
        ),
      );
    } on JobStatusException catch (error) {
      if (!mounted) return;
      setState(() => _starting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final address =
        widget.job?.address?.trim().isNotEmpty == true
            ? widget.job!.address!
            : 'Customer service address';
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 14),
              child: DetailScreenHeader(title: 'Navigate'),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: DiagonalStripesPainter(
                            chip: tokens.chip,
                            elev: tokens.elev,
                            stripeWidth: 18,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          '[ navigation handoff ]',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: tokens.mut,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: tokens.surface,
                            border: Border.all(color: tokens.line),
                            borderRadius: BorderRadius.circular(13),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x66000000),
                                blurRadius: 24,
                                offset: Offset(0, 8),
                                spreadRadius: -10,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  LucideIcons.navigation,
                                  size: 19,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      address,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: tokens.tx,
                                      ),
                                    ),
                                    Text(
                                      'Status shared with customer and admin',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: tokens.mut,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: const Alignment(0, 0.08),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.danger,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x66000000),
                                blurRadius: 16,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            LucideIcons.mapPin,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
              child: PrimaryCtaButton(
                label:
                    _starting
                        ? 'Starting job…'
                        : widget.job == null
                        ? 'Start Navigation'
                        : 'Arrived · Start Job',
                shadowColor: AppColors.accent,
                shadowAlpha: 0.6,
                onPressed: _starting ? null : _startJob,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
