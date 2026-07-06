import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/detail_screen_header.dart';
import 'customer_notifications_service.dart';

/// Plain, functional notifications list — no design-handoff spec exists
/// for this (same situation as Providers/Bookings/More), so this follows
/// the app's existing tokens/card visual pattern rather than a
/// pixel-perfect match. Legitimately empty for every user right now — no
/// automated trigger writes notifications yet.
class CustomerNotificationsScreen extends StatefulWidget {
  const CustomerNotificationsScreen({super.key});

  @override
  State<CustomerNotificationsScreen> createState() => _CustomerNotificationsScreenState();
}

class _CustomerNotificationsScreenState extends State<CustomerNotificationsScreen> {
  late Future<List<CustomerNotification>> _notificationsFuture = fetchMyNotifications();

  Future<void> _markRead(CustomerNotification notification) async {
    if (notification.read) return;
    try {
      await markNotificationRead(notification.id);
    } catch (_) {
      // Best-effort — no live Firebase app, or a permission edge case.
    }
    if (!mounted) return;
    setState(() => _notificationsFuture = fetchMyNotifications());
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
              child: const DetailScreenHeader(title: 'Notifications'),
            ),
            Expanded(
              child: FutureBuilder<List<CustomerNotification>>(
                future: _notificationsFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData && !snapshot.hasError) {
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2.4));
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Couldn't load notifications.", style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: tokens.mut)),
                    );
                  }
                  final notifications = snapshot.data!;
                  if (notifications.isEmpty) {
                    return Center(
                      child: Text('No notifications yet.', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: tokens.mut)),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _NotificationTile(notification: notification, onTap: () => _markRead(notification));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final CustomerNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: tokens.card,
          border: Border.all(color: notification.read ? tokens.line : AppColors.primary.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!notification.read)
              Padding(
                padding: const EdgeInsets.only(top: 5, right: 8),
                child: Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.title, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: tokens.tx)),
                  const SizedBox(height: 3),
                  Text(notification.body, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: tokens.mut)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(LucideIcons.clock, size: 11, color: tokens.mut),
                      const SizedBox(width: 4),
                      Text(notification.scheduleLabel, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: tokens.mut)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
