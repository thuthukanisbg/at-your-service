import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/provider_job.dart';

const providerJobs = [
  ProviderJob(title: 'Deep House Cleaning', price: 600, timeLabel: 'Today · 10:00 AM', distanceLabel: '2.3 km'),
  ProviderJob(title: 'Plumbing Repair', price: 750, timeLabel: 'Today · 01:00 PM', distanceLabel: '4.1 km'),
  ProviderJob(title: 'Electrical Installation', price: 1200, timeLabel: 'Tomorrow · 08:00 AM', distanceLabel: '6.0 km'),
];

/// (icon, label, value) rows for the Job Details info card. Address/customer
/// are fixed generic mock values (the handoff doesn't vary these per job);
/// payout is computed live from the tapped job's price (90%, after the
/// platform's 10% fee) rather than hardcoded, since that's the actual rule
/// the handoff's one example demonstrates (R600 job -> R540 payout).
const providerJobAddress = '23 Loop Street, Cape Town 8001';
const providerJobCustomer = 'Thandi N.';
const providerJobCustomerNote = 'Please focus on kitchen and bathrooms. Two cats at home — keep the front door closed.';

const providerTaskLabels = [
  'Kitchen cleaning',
  'Bathroom sanitisation',
  'Floor & surface cleaning',
  'Final dusting',
];

class ProviderStat {
  const ProviderStat({required this.value, required this.label, this.color});

  final String value;
  final String label;

  /// Null means "use the theme's default text color" (`tokens.tx`) — the
  /// handoff's "Jobs done" stat uses `var(--tx)`, which only resolves at
  /// build time against the active theme, not a fixed constant.
  final Color? color;
}

const providerStats = [
  ProviderStat(value: '128', label: 'Jobs done'),
  ProviderStat(value: '4.8', label: 'Rating', color: AppColors.accent),
  ProviderStat(value: '98%', label: 'Completion', color: AppColors.success),
];

class VerificationItem {
  const VerificationItem({required this.label, required this.verified});
  final String label;
  final bool verified;
}

const providerVerificationMini = [
  VerificationItem(label: 'ID document', verified: true),
  VerificationItem(label: 'Selfie match', verified: true),
  VerificationItem(label: 'Proof of address', verified: true),
  VerificationItem(label: 'Background check', verified: false),
];

class WeekDay {
  const WeekDay({required this.dow, required this.day, this.selected = false});
  final String dow;
  final String day;
  final bool selected;
}

const providerWeek = [
  WeekDay(dow: 'Mon', day: '19'),
  WeekDay(dow: 'Tue', day: '20'),
  WeekDay(dow: 'Wed', day: '21', selected: true),
  WeekDay(dow: 'Thu', day: '22'),
  WeekDay(dow: 'Fri', day: '23'),
];

class ScheduleEvent {
  const ScheduleEvent({
    required this.time,
    required this.duration,
    required this.title,
    required this.where,
    required this.accent,
  });
  final String time;
  final String duration;
  final String title;
  final String where;
  final Color accent;
}

const providerSchedule = [
  ScheduleEvent(time: '09:00', duration: '2h', title: 'Office Cleaning', where: 'Sea Point · R480', accent: AppColors.primary),
  ScheduleEvent(time: '13:00', duration: '3h', title: 'Deep House Cleaning', where: 'City Bowl · R600', accent: AppColors.accent),
  ScheduleEvent(time: '17:00', duration: '1h', title: 'Window Cleaning', where: 'Green Point · R320', accent: AppColors.success),
];

class Payout {
  const Payout({required this.title, required this.date, required this.amount});
  final String title;
  final String date;
  final String amount;
}

const providerPayouts = [
  Payout(title: 'Weekly payout', date: '24 May 2024', amount: 'R4,820'),
  Payout(title: 'Weekly payout', date: '17 May 2024', amount: 'R5,140'),
  Payout(title: 'Weekly payout', date: '10 May 2024', amount: 'R4,390'),
];
