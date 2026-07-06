import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/detail_screen_header.dart';
import '../../core/widgets/primary_cta_button.dart';
import 'dispute_service.dart';

/// Shared by both the customer (from `TrackBookingScreen`) and provider
/// (from `ProviderJobDetailsScreen`) sides — same booking, same report
/// shape, just filed by whichever party owns it. Priority is picked by the
/// filer at submission time (Low/Medium/High, defaulting to Medium) — a
/// judgment call, since the design handoff's mock data has a priority field
/// but no spec for who sets it or when.
class FileDisputeScreen extends StatefulWidget {
  const FileDisputeScreen({
    super.key,
    required this.bookingId,
    required this.customerId,
    required this.providerId,
    required this.serviceName,
  });

  final String bookingId;
  final String customerId;
  final String? providerId;
  final String serviceName;

  @override
  State<FileDisputeScreen> createState() => _FileDisputeScreenState();
}

class _FileDisputeScreenState extends State<FileDisputeScreen> {
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _priority = 'Medium';
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final subject = _subjectController.text.trim();
    final description = _descriptionController.text.trim();
    if (subject.isEmpty || description.isEmpty) {
      setState(() => _error = 'Please fill in both a subject and a description.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await fileDispute(
        bookingId: widget.bookingId,
        customerId: widget.customerId,
        providerId: widget.providerId,
        serviceName: widget.serviceName,
        subject: subject,
        description: description,
        priority: _priority,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Report submitted — our team will follow up.")),
      );
      Navigator.of(context).pop();
    } on DisputeException catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = "Couldn't file your report — please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 18),
              child: DetailScreenHeader(title: 'Report a Problem'),
            ),
            Text(
              'Reporting an issue with',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: tokens.mut),
            ),
            const SizedBox(height: 2),
            Text(
              widget.serviceName,
              style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: tokens.tx),
            ),
            const SizedBox(height: 20),
            Text('Subject', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: tokens.tx)),
            const SizedBox(height: 8),
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(hintText: 'e.g. Provider no-show'),
            ),
            const SizedBox(height: 18),
            Text('Priority', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: tokens.tx)),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final p in disputePriorities) ...[
                  Expanded(child: _PriorityChip(label: p, selected: _priority == p, onTap: () => setState(() => _priority = p))),
                  if (p != disputePriorities.last) const SizedBox(width: 8),
                ],
              ],
            ),
            const SizedBox(height: 18),
            Text('What happened?', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: tokens.tx)),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              minLines: 4,
              maxLines: 6,
              decoration: const InputDecoration(hintText: 'Describe the issue in a few sentences…'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 14),
              Text(_error!, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.danger)),
            ],
            const SizedBox(height: 22),
            PrimaryCtaButton(
              label: _submitting ? 'Submitting…' : 'Submit Report',
              icon: LucideIcons.send,
              onPressed: _submitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Material(
      color: selected ? AppColors.primary : tokens.card,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: selected ? AppColors.primary : tokens.line),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: selected ? Colors.white : tokens.tx)),
        ),
      ),
    );
  }
}
