import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/detail_screen_header.dart';
import '../../core/widgets/diagonal_stripes_painter.dart';
import '../disputes/file_dispute_screen.dart';
import '../messaging/conversation_screen.dart';
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
  const TrackBookingScreen({
    super.key,
    this.bookingId,
    this.customerId,
    this.providerId,
    this.serviceName,
    this.otherPartyName,
  });

  static const routeName = '/customer/track';

  /// Only set when reached from a real booking (see `CustomerBookingsScreen`
  /// — tapping a booking with an assigned provider). The mock flow reached
  /// via ReviewPayScreen's "Confirm & Pay" never creates a real Firestore
  /// booking, so these stay null there and this screen behaves exactly as
  /// before: fully decorative demo, Chat still shows the coming-soon
  /// snackbar since there's no real booking to attach a conversation to.
  final String? bookingId;
  final String? customerId;
  final String? providerId;
  final String? serviceName;
  final String? otherPartyName;

  bool get _hasRealBooking => bookingId != null && customerId != null && providerId != null;

  /// True for any real booking (assigned or not) — as opposed to the pure
  /// demo entry point via ReviewPayScreen's mock "Confirm & Pay", where
  /// bookingId is null. Used to swap the fake live-map/4-step timeline for
  /// an honest 2-step one: there's no real live-location data behind this
  /// screen, so pretending a provider is "on the way" for a booking that
  /// might not even be assigned yet would be actively misleading.
  bool get _isRealBooking => bookingId != null;

  void _comingSoon(BuildContext context, String what) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$what arrives in the next milestone.')),
    );
  }

  Future<void> _callProvider(BuildContext context) async {
    if (!_hasRealBooking) {
      _comingSoon(context, 'Calling');
      return;
    }
    // No providers in the live data have a phone number on file yet (it's
    // never collected during onboarding) — fetched lazily on tap rather
    // than eagerly for every screen load, since it's only needed here.
    final doc = await FirebaseFirestore.instance.collection('users').doc(providerId).get();
    final phone = doc.data()?['phoneNumber'] as String?;
    if (!context.mounted) return;
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number on file for this provider yet.')),
      );
      return;
    }
    final launched = await launchUrl(Uri(scheme: 'tel', path: phone));
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't open the dialer.")),
      );
    }
  }

  void _reportProblem(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FileDisputeScreen(
          bookingId: bookingId!,
          customerId: customerId!,
          providerId: providerId,
          serviceName: serviceName ?? 'Service',
        ),
      ),
    );
  }

  void _openChat(BuildContext context) {
    if (!_hasRealBooking) {
      _comingSoon(context, 'Chat');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ConversationScreen(
          bookingId: bookingId!,
          customerId: customerId!,
          providerId: providerId!,
          serviceName: serviceName ?? 'Service',
          otherPartyName: otherPartyName ?? 'Your provider',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final displayName = otherPartyName ?? 'Sipho M.';
    final initials = displayName.trim().isEmpty
        ? '?'
        : displayName.trim().split(RegExp(r'\s+')).map((p) => p[0]).take(2).join().toUpperCase();
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
          children: [
            const DetailScreenHeader(title: 'My Booking'),
            const SizedBox(height: 16),
            if (!_isRealBooking) ...[
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
            ],
            if (!_isRealBooking || providerId != null)
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
                      child: Text(initials, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(displayName, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: tokens.tx)),
                          Text(
                            'Cleaning Specialist · ⭐ 4.9',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: tokens.mut),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _CircleIconButton(icon: LucideIcons.phone, onTap: () { _callProvider(context); }),
                    const SizedBox(width: 12),
                    _CircleIconButton(icon: LucideIcons.messageCircle, onTap: () => _openChat(context)),
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
                children: _isRealBooking
                    ? [
                        // Real bookings only ever have two known statuses
                        // ('pending'/'completed') and no live-location data —
                        // showing the demo's granular "on the way" steps here
                        // would be fabricated, so this is an honest 2-step
                        // version instead.
                        _TrackStepRow(
                          step: const _TrackStep('Booking confirmed', '', _StepState.done),
                          isLast: false,
                        ),
                        _TrackStepRow(
                          step: _TrackStep(
                            providerId != null ? 'Provider assigned · $displayName' : 'Waiting for a provider',
                            '',
                            providerId != null ? _StepState.done : _StepState.idle,
                          ),
                          isLast: true,
                        ),
                      ]
                    : [
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
            if (_hasRealBooking)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextButton.icon(
                  onPressed: () => _reportProblem(context),
                  style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                  icon: const Icon(LucideIcons.flag, size: 16),
                  label: const Text('Report a problem', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
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
