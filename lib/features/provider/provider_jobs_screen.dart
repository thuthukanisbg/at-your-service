import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/currency.dart';
import '../../models/provider_job.dart';
import 'provider_job_details_screen.dart';
import 'provider_jobs_service.dart';
import 'provider_mock_data.dart';

class ProviderJobsScreen extends StatefulWidget {
  const ProviderJobsScreen({super.key});

  @override
  State<ProviderJobsScreen> createState() => _ProviderJobsScreenState();
}

enum _JobTab { available, accepted }

class _ProviderJobsScreenState extends State<ProviderJobsScreen> {
  late final Future<List<ProviderJob>> _availableFuture = fetchAvailableJobs();
  late final Future<List<ProviderJob>> _acceptedFuture = fetchAssignedJobs();
  _JobTab _tab = _JobTab.available;

  void _openJob(BuildContext context, ProviderJob job) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProviderJobDetailsScreen(job: job, isAlreadyAccepted: _tab == _JobTab.accepted),
      ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'My Jobs',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: tokens.tx),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0x1F2ECC71), // rgba(46,204,113,.12)
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 7,
                        height: 7,
                        child: DecoratedBox(decoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                      ),
                      SizedBox(width: 6),
                      Text('Online', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.success)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(5),
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: tokens.card,
                border: Border.all(color: tokens.line),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _tab = _JobTab.available),
                      borderRadius: BorderRadius.circular(9),
                      child: Container(
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _tab == _JobTab.available ? AppColors.primary : null,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Text(
                          'Available',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: _tab == _JobTab.available ? FontWeight.w800 : FontWeight.w700,
                            color: _tab == _JobTab.available ? Colors.white : tokens.mut,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _tab = _JobTab.accepted),
                      borderRadius: BorderRadius.circular(9),
                      child: Container(
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _tab == _JobTab.accepted ? AppColors.primary : null,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Text(
                          'Accepted',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: _tab == _JobTab.accepted ? FontWeight.w800 : FontWeight.w700,
                            color: _tab == _JobTab.accepted ? Colors.white : tokens.mut,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            FutureBuilder<List<ProviderJob>>(
              future: _tab == _JobTab.available ? _availableFuture : _acceptedFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData && !snapshot.hasError) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
                  );
                }
                // Error (e.g. no live Firebase app) falls back to mock jobs;
                // a real empty result (a provider genuinely has none right
                // now) gets its own honest empty state instead.
                if (snapshot.hasError) {
                  return Column(
                    children: [
                      for (final job in providerJobs)
                        _JobCard(job: job, isAccepted: _tab == _JobTab.accepted, onTap: () => _openJob(context, job)),
                    ],
                  );
                }
                final jobs = snapshot.data!;
                if (jobs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        _tab == _JobTab.available ? 'No open jobs right now.' : 'No jobs assigned yet.',
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: tokens.mut),
                      ),
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final job in jobs)
                      _JobCard(job: job, isAccepted: _tab == _JobTab.accepted, onTap: () => _openJob(context, job)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.job, required this.onTap, this.isAccepted = false});

  final ProviderJob job;
  final VoidCallback onTap;
  final bool isAccepted;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: tokens.card,
        border: Border.all(color: tokens.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    job.title,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: tokens.tx),
                  ),
                ),
                Text(formatRand(job.price), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 9, bottom: 13),
              child: Row(
                children: [
                  Icon(LucideIcons.clock, size: 13, color: tokens.mut),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      job.timeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: tokens.mut),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Icon(LucideIcons.mapPin, size: 13, color: tokens.mut),
                  const SizedBox(width: 5),
                  Text(job.distanceLabel, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: tokens.mut)),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.accentOnAccent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                  textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
                ),
                child: Text(isAccepted ? 'View Job' : 'Accept Job'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
