import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/utils/schedule_format.dart';
import '../../core/utils/user_display_name.dart';

/// Thrown by [fileDispute] with a message safe to show the user directly.
class DisputeException implements Exception {
  const DisputeException(this.message);
  final String message;
}

const disputePriorities = ['Low', 'Medium', 'High'];

/// Filed by either party on a real booking — the customer or the assigned
/// provider (see the `disputes` rule: `filedBy` must be the signed-in uid,
/// and must match the booking's own `customerId`/`providerId`). Starts
/// `status: 'Open'`; only an admin can move it to `Escalated`/`Resolved`
/// afterward (see [updateDisputeStatus]).
Future<void> fileDispute({
  required String bookingId,
  required String customerId,
  required String? providerId,
  required String serviceName,
  required String subject,
  required String description,
  required String priority,
}) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    throw const DisputeException('You need to be signed in to report a problem.');
  }
  try {
    await FirebaseFirestore.instance.collection('disputes').add({
      'bookingId': bookingId,
      'customerId': customerId,
      'providerId': providerId,
      'serviceName': serviceName,
      'subject': subject,
      'description': description,
      'priority': priority,
      'status': 'Open',
      'filedBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  } catch (_) {
    throw const DisputeException("Couldn't file your report — please try again.");
  }
}

class AdminDisputeSummary {
  const AdminDisputeSummary({
    required this.id,
    required this.subject,
    required this.description,
    required this.customerName,
    required this.providerName,
    required this.priority,
    required this.status,
    required this.dateLabel,
    required this.filedBy,
  });

  final String id;
  final String subject;
  final String description;
  final String customerName;
  final String providerName;
  final String priority;
  final String status;
  final String dateLabel;

  /// uid of whoever filed it — needed to address the resolution
  /// notification (see [updateDisputeStatus]), not shown in the UI.
  final String filedBy;
}

/// Every dispute on the platform — permitted by the `isAdmin()` clause in
/// the deployed `disputes` read rule. Same name-resolution join as
/// `fetchAllBookings` (customer via `fetchUserDisplayName`, provider via
/// `providers/{id}.displayName`) — not a per-row query.
Future<List<AdminDisputeSummary>> fetchAllDisputes() async {
  final snapshot = await FirebaseFirestore.instance.collection('disputes').get();
  final docs = snapshot.docs;

  final customerIds = docs.map((d) => d.data()['customerId'] as String?).whereType<String>().toSet();
  final providerIds = docs.map((d) => d.data()['providerId'] as String?).whereType<String>().toSet();

  final customerNames = Map.fromEntries(
    await Future.wait(customerIds.map((id) async => MapEntry(id, await fetchUserDisplayName(id) ?? '—'))),
  );
  final providerNames = Map.fromEntries(
    await Future.wait(providerIds.map((id) async {
      final doc = await FirebaseFirestore.instance.collection('providers').doc(id).get();
      return MapEntry(id, doc.data()?['displayName'] as String? ?? '—');
    })),
  );

  return docs.map((doc) {
    final data = doc.data();
    final customerId = data['customerId'] as String?;
    final providerId = data['providerId'] as String?;
    final createdAt = data['createdAt'];
    return AdminDisputeSummary(
      id: doc.id,
      subject: data['subject'] as String? ?? 'Report',
      description: data['description'] as String? ?? '',
      customerName: customerId != null ? (customerNames[customerId] ?? '—') : '—',
      providerName: providerId != null ? (providerNames[providerId] ?? '—') : '—',
      priority: data['priority'] as String? ?? 'Medium',
      status: data['status'] as String? ?? 'Open',
      dateLabel: createdAt is Timestamp ? formatSchedule(createdAt.toDate()) : '—',
      filedBy: data['filedBy'] as String? ?? '',
    );
  }).toList();
}

/// Just the count of currently-open disputes — Overview's KPI card.
Future<int> fetchOpenDisputeCount() async {
  final snapshot = await FirebaseFirestore.instance.collection('disputes').where('status', isEqualTo: 'Open').get();
  return snapshot.docs.length;
}

/// Admin triage action: moves a dispute to `Escalated` or `Resolved`, then
/// notifies whoever filed it. Notification creation is admin-only under
/// the deployed rules (no Cloud Functions in this project to do it any
/// other way — same constraint noted in `firestore.rules`'s own comment on
/// the `notifications` match), so this is the one direction that's
/// actually wireable: there's no rule-compliant way for a customer/
/// provider filing a dispute to notify admin the same way.
Future<void> updateDisputeStatus({
  required String disputeId,
  required String newStatus,
  required String filedBy,
  required String subject,
}) async {
  await FirebaseFirestore.instance.collection('disputes').doc(disputeId).update({
    'status': newStatus,
    'updatedAt': FieldValue.serverTimestamp(),
  });
  await FirebaseFirestore.instance.collection('notifications').add({
    'userId': filedBy,
    'title': 'Update on your report',
    'body': '"$subject" is now $newStatus.',
    'read': false,
    'createdAt': FieldValue.serverTimestamp(),
  });
}
