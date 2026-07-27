import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/detail_screen_header.dart';
import '../../core/widgets/primary_cta_button.dart';
import 'review_pay_screen.dart';

class _BookingDate {
  const _BookingDate(this.value);

  final DateTime value;

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String get dow => _weekdays[value.weekday - 1];
  String get day => value.day.toString();
  String get mon => _months[value.month - 1];
}

const _times = [
  TimeOfDay(hour: 8, minute: 0),
  TimeOfDay(hour: 10, minute: 0),
  TimeOfDay(hour: 14, minute: 0),
  TimeOfDay(hour: 16, minute: 0),
];

class BookScheduleScreen extends StatefulWidget {
  const BookScheduleScreen({
    super.key,
    required this.serviceName,
    required this.price,
    this.serviceId,
    this.now,
  });

  static const routeName = '/customer/book';

  final String serviceName;
  final num price;

  /// Null when ServiceDetailsScreen's fetch errored/found nothing and fell
  /// back to mock display data — there's no real services doc to reference.
  final String? serviceId;

  /// A deterministic clock hook for widget tests. Production always uses the
  /// current local date.
  final DateTime? now;

  @override
  State<BookScheduleScreen> createState() => _BookScheduleScreenState();
}

class _BookScheduleScreenState extends State<BookScheduleScreen> {
  late final List<_BookingDate> _dates;
  int _dateIndex = 0;
  int _timeIndex = 1; // '10:00 AM'
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final today = DateUtils.dateOnly(widget.now ?? DateTime.now());
    _dates = List.generate(
      4,
      (index) => _BookingDate(today.add(Duration(days: index + 1))),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _continueToReview() {
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the service address.')),
      );
      return;
    }
    final date = _dates[_dateIndex].value;
    final time = _times[_timeIndex];
    final scheduledFor = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReviewPayScreen(
          scheduledFor: scheduledFor,
          address: address,
          serviceId: widget.serviceId,
          serviceName: widget.serviceName,
          price: widget.price,
          notes: _notesController.text.trim(),
        ),
      ),
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
            const Padding(
              padding: EdgeInsets.only(bottom: 18),
              child: DetailScreenHeader(title: 'Book & Schedule'),
            ),
            Text(
              'Select Date',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: tokens.tx,
              ),
            ),
            const SizedBox(height: 11),
            Row(
              children: [
                for (var i = 0; i < _dates.length; i++) ...[
                  Expanded(
                    child: _DateTile(
                      date: _dates[i],
                      selected: i == _dateIndex,
                      onTap: () => setState(() => _dateIndex = i),
                    ),
                  ),
                  if (i != _dates.length - 1) const SizedBox(width: 9),
                ],
              ],
            ),
            const SizedBox(height: 22),
            Text(
              'Select Time',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: tokens.tx,
              ),
            ),
            const SizedBox(height: 11),
            Row(
              children: [
                for (var i = 0; i < 2; i++) ...[
                  Expanded(
                    child: _TimeTile(
                      label: _times[i].format(context),
                      selected: i == _timeIndex,
                      onTap: () => setState(() => _timeIndex = i),
                    ),
                  ),
                  if (i != 1) const SizedBox(width: 9),
                ],
              ],
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                for (var i = 2; i < 4; i++) ...[
                  Expanded(
                    child: _TimeTile(
                      label: _times[i].format(context),
                      selected: i == _timeIndex,
                      onTap: () => setState(() => _timeIndex = i),
                    ),
                  ),
                  if (i != 3) const SizedBox(width: 9),
                ],
              ],
            ),
            const SizedBox(height: 22),
            Text(
              'Service Address',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: tokens.tx,
              ),
            ),
            const SizedBox(height: 11),
            TextField(
              controller: _addressController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.streetAddress,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: tokens.tx,
              ),
              decoration: const InputDecoration(
                hintText: 'Street address, suburb, city',
              ),
            ),
            const SizedBox(height: 22),
            Text.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: tokens.tx,
                ),
                children: [
                  const TextSpan(text: 'Special instructions '),
                  TextSpan(
                    text: '(optional)',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: tokens.mut,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 11),
            Container(
              constraints: const BoxConstraints(minHeight: 84),
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: tokens.card,
                border: Border.all(color: tokens.line),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _notesController,
                maxLines: null,
                minLines: 2,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: tokens.tx,
                ),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText:
                      'e.g. Focus on the kitchen and bathrooms, pets at home…',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: tokens.mut,
                  ),
                ),
              ),
            ),
            PrimaryCtaButton(label: 'Continue', onPressed: _continueToReview),
          ],
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.date,
    required this.selected,
    required this.onTap,
  });

  final _BookingDate date;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final fg = selected ? Colors.white : tokens.tx;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : tokens.card,
          border: selected ? null : Border.all(color: tokens.line),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              date.dow,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: fg.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              date.day,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              date.mon,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: fg.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeTile extends StatelessWidget {
  const _TimeTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : tokens.card,
          border: selected ? null : Border.all(color: tokens.line),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : tokens.tx,
          ),
        ),
      ),
    );
  }
}
