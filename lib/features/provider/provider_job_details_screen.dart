import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/currency.dart';
import '../../core/utils/user_display_name.dart';
import '../../core/widgets/detail_screen_header.dart';
import '../../core/widgets/primary_cta_button.dart';
import '../../models/provider_job.dart';
import '../disputes/file_dispute_screen.dart';
import '../messaging/conversation_screen.dart';
import 'provider_jobs_service.dart';
import 'provider_mock_data.dart';
import 'provider_navigate_screen.dart';

class ProviderJobDetailsScreen extends StatefulWidget {
  const ProviderJobDetailsScreen({super.key, required this.job, this.isAlreadyAccepted = false});

  final ProviderJob job;

  /// True when opened from the "Accepted" tab (already assigned to this
  /// provider) rather than "Available" — skips the claim write and swaps
  /// the CTA label, since there's nothing left to accept.
  final bool isAlreadyAccepted;

  @override
  State<ProviderJobDetailsScreen> createState() => _ProviderJobDetailsScreenState();
}

class _ProviderJobDetailsScreenState extends State<ProviderJobDetailsScreen> {
  bool _claiming = false;
  ProviderJob get job => widget.job;

  // Resolved once and reused by both the "Customer" info row and the
  // "Message Customer" button, rather than fetching the same doc twice.
  late final Future<String?> _customerNameFuture =
      job.customerId != null ? fetchUserDisplayName(job.customerId!) : Future.value(null);

  Future<void> _acceptJob() async {
    if (widget.isAlreadyAccepted || job.id == null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ProviderNavigateScreen()),
      );
      return;
    }
    setState(() => _claiming = true);
    try {
      await claimJob(job.id!);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ProviderNavigateScreen()),
      );
    } on ClaimException catch (e) {
      if (!mounted) return;
      setState(() => _claiming = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _claiming = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't accept this job — please try again.")),
      );
    }
  }

  Future<void> _openConversation() async {
    final bookingId = job.id;
    final customerId = job.customerId;
    final providerId = FirebaseAuth.instance.currentUser?.uid;
    if (bookingId == null || customerId == null || providerId == null) return;
    final otherPartyName = await _customerNameFuture ?? job.title;
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ConversationScreen(
          bookingId: bookingId,
          customerId: customerId,
          providerId: providerId,
          serviceName: job.title,
          otherPartyName: otherPartyName,
        ),
      ),
    );
  }

  void _reportIssue() {
    final bookingId = job.id;
    final customerId = job.customerId;
    // Guarded like _customerNameFuture's own fetch — accessing
    // FirebaseAuth.instance throws synchronously with no live Firebase app
    // (e.g. widget tests).
    String? providerId;
    try {
      providerId = FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      providerId = null;
    }
    if (bookingId == null || customerId == null || providerId == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FileDisputeScreen(
          bookingId: bookingId,
          customerId: customerId,
          providerId: providerId,
          serviceName: job.title,
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: tokens.line))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: tokens.chip, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: tokens.mut)),
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Text(
                    value,
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: tokens.tx),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    // job.customerId == null means this is the mock fallback job (no live
    // Firebase, or the fetch errored) — keeps the exact old mock name/
    // address in that case, since there's no real customer to look up.
    final address = job.address ?? providerJobAddress;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 18),
              child: DetailScreenHeader(title: 'Job Details'),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job.title, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: tokens.tx)),
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            job.timeLabel,
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: tokens.mut),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(formatRand(job.price), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary)),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: tokens.card,
                border: Border.all(color: tokens.line),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _infoRow(context, LucideIcons.mapPin, 'Address', address),
                  if (job.customerId == null)
                    _infoRow(context, LucideIcons.user, 'Customer', providerJobCustomer)
                  else
                    FutureBuilder<String?>(
                      future: _customerNameFuture,
                      builder: (context, snapshot) {
                        final customerName = snapshot.data ??
                            (snapshot.connectionState == ConnectionState.waiting ? 'Loading…' : 'Customer');
                        return _infoRow(context, LucideIcons.user, 'Customer', customerName);
                      },
                    ),
                  _infoRow(
                    context,
                    LucideIcons.banknote,
                    'Payout',
                    '${formatRand(job.price * 0.9)} (after 10% fee)',
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 22),
              decoration: BoxDecoration(
                color: const Color(0x1AFFC107), // rgba(255,193,7,.1)
                border: Border.all(color: const Color(0x4DFFC107)), // rgba(255,193,7,.3)
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.info, size: 14, color: AppColors.accent),
                        SizedBox(width: 6),
                        Text('CUSTOMER NOTES', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.accent)),
                      ],
                    ),
                  ),
                  Text(
                    providerJobCustomerNote,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.5, color: tokens.tx),
                  ),
                ],
              ),
            ),
            if (job.id != null && job.customerId != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _openConversation,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                    ),
                    icon: const Icon(LucideIcons.messageCircle, size: 17),
                    label: const Text('Message Customer', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            if (widget.isAlreadyAccepted && job.id != null && job.customerId != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: TextButton.icon(
                    onPressed: _reportIssue,
                    style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                    icon: const Icon(LucideIcons.flag, size: 16),
                    label: const Text('Report an issue', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            PrimaryCtaButton(
              label: widget.isAlreadyAccepted
                  ? 'Start Navigation'
                  : (_claiming ? 'Accepting…' : 'Accept Job'),
              style: AppTheme.amberAction,
              shadowColor: AppColors.accent,
              shadowAlpha: 0.6,
              onPressed: _claiming ? null : _acceptJob,
            ),
          ],
        ),
      ),
    );
  }
}
