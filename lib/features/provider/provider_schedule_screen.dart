import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import 'provider_mock_data.dart';

class ProviderScheduleScreen extends StatelessWidget {
  const ProviderScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
          children: [
            Text(
              'Schedule',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: tokens.tx),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Row(
                children: [
                  for (var i = 0; i < providerWeek.length; i++) ...[
                    Expanded(child: _WeekDayTile(day: providerWeek[i])),
                    if (i != providerWeek.length - 1) const SizedBox(width: 7),
                  ],
                ],
              ),
            ),
            for (final event in providerSchedule) _ScheduleRow(event: event),
          ],
        ),
      ),
    );
  }
}

class _WeekDayTile extends StatelessWidget {
  const _WeekDayTile({required this.day});

  final WeekDay day;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final fg = day.selected ? Colors.white : tokens.tx;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        color: day.selected ? AppColors.primary : tokens.card,
        border: day.selected ? null : Border.all(color: tokens.line),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(day.dow, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg.withValues(alpha: 0.7))),
          const SizedBox(height: 2),
          Text(day.day, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: fg)),
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({required this.event});

  final ScheduleEvent event;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 54,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(event.time, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: tokens.tx)),
                Text(event.duration, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: tokens.mut)),
              ],
            ),
          ),
          const SizedBox(width: 13),
          // BoxDecoration can't combine a non-uniform Border (the accent
          // strip is 3px, the rest 1px) with a borderRadius, so the accent
          // strip is a separate rounded-left rectangle instead of a left
          // border on the card itself.
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  Container(width: 3, color: event.accent),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: tokens.card,
                        border: Border(
                          top: BorderSide(color: tokens.line),
                          right: BorderSide(color: tokens.line),
                          bottom: BorderSide(color: tokens.line),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event.title, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: tokens.tx)),
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(event.where, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: tokens.mut)),
                          ),
                        ],
                      ),
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
