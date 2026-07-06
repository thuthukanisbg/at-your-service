import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/utils/schedule_format.dart';

class CustomerNotification {
  const CustomerNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.read,
    required this.scheduleLabel,
  });

  final String id;
  final String title;
  final String body;
  final bool read;
  final String scheduleLabel;
}

/// Fetches the signed-in user's notifications.
///
/// No automated trigger writes these yet (no Cloud Functions in this
/// project — see the deployed rule's comment), so this will legitimately
/// return an empty list for every user until an admin/backend path starts
/// creating them. That's an honest empty state, not a bug.
Future<List<CustomerNotification>> fetchMyNotifications() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return [];

  final snapshot =
      await FirebaseFirestore.instance.collection('notifications').where('userId', isEqualTo: uid).get();

  return snapshot.docs.map((doc) {
    final data = doc.data();
    final createdAt = data['createdAt'];
    return CustomerNotification(
      id: doc.id,
      title: data['title'] as String? ?? 'Notification',
      body: data['body'] as String? ?? '',
      read: data['read'] as bool? ?? false,
      scheduleLabel: createdAt is Timestamp ? formatSchedule(createdAt.toDate()) : '—',
    );
  }).toList();
}

Future<void> markNotificationRead(String id) {
  return FirebaseFirestore.instance.collection('notifications').doc(id).update({'read': true});
}
