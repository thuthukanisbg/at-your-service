import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';

/// One status→color mapping shared by every table in the desktop Admin
/// Dashboard — matches the design handoff's own single `badge()` function
/// exactly, so "Completed"/"Verified"/"Active"/"Resolved"/"Success" are
/// always green, "In Progress"/"Confirmed" always primary blue, etc.,
/// regardless of which table renders them.
Color adminStatusColor(String status, BuildContext context) {
  const green = AppColors.success;
  const blue = AppColors.primary;
  const amber = AppColors.accent;
  const red = AppColors.danger;
  return switch (status) {
    'Completed' || 'Verified' || 'Active' || 'Resolved' || 'Success' => green,
    'In Progress' || 'Confirmed' => blue,
    'Pending' || 'Open' || 'Invited' => amber,
    'Cancelled' || 'Suspended' || 'Escalated' || 'Failed' || 'Inactive' || 'Expired' => red,
    'Paused' => context.tokens.mut,
    _ => context.tokens.mut,
  };
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = adminStatusColor(status, context);
    final isNeutral = color == tokens.mut;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isNeutral ? tokens.elev : color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color)),
    );
  }
}
