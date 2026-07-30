import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// One conversation per booking — the doc ID is the booking's own ID, so
/// there's no separate lookup step to find "the conversation for this
/// booking" (see [conversationRef]).
class ConversationSummary {
  const ConversationSummary({
    required this.bookingId,
    required this.customerId,
    required this.providerId,
    required this.serviceName,
    required this.lastMessageText,
    required this.lastMessageAt,
    required this.lastSenderId,
    required this.customerReadAt,
    required this.providerReadAt,
  });

  final String bookingId;
  final String customerId;
  final String providerId;
  final String serviceName;
  final String? lastMessageText;
  final DateTime? lastMessageAt;
  final String? lastSenderId;
  final DateTime? customerReadAt;
  final DateTime? providerReadAt;

  bool isUnreadFor(String uid) {
    final sentAt = lastMessageAt;
    if (sentAt == null || lastSenderId == null || lastSenderId == uid) {
      return false;
    }
    final readAt = uid == customerId ? customerReadAt : providerReadAt;
    return readAt == null || sentAt.isAfter(readAt);
  }
}

class ChatMessage {
  const ChatMessage({
    required this.senderId,
    required this.text,
    required this.createdAt,
  });

  final String senderId;
  final String text;
  final DateTime? createdAt;
}

DocumentReference<Map<String, dynamic>> conversationRef(String bookingId) {
  return FirebaseFirestore.instance.collection('conversations').doc(bookingId);
}

/// Ensures a conversation doc exists for this booking (lazy-created on
/// first message, no Cloud Function seeds these) and appends a message.
/// `.set(merge: true)` on the conversation doc means this is a `create`
/// under the deployed rules the first time, and an `update` every time
/// after — both are allowed for either participant.
Future<void> sendMessage({
  required String bookingId,
  required String customerId,
  required String providerId,
  required String serviceName,
  required String text,
}) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final ref = conversationRef(bookingId);
  await ref.set({
    'bookingId': bookingId,
    'customerId': customerId,
    'providerId': providerId,
    'serviceName': serviceName,
    'lastMessageText': text,
    'lastMessageAt': FieldValue.serverTimestamp(),
    'lastSenderId': uid,
    if (uid == customerId) 'customerReadAt': FieldValue.serverTimestamp(),
    if (uid == providerId) 'providerReadAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
  await ref.collection('messages').add({
    'senderId': uid,
    'text': text,
    'createdAt': FieldValue.serverTimestamp(),
  });
}

/// Records the signed-in participant's read position at conversation level.
/// A single timestamp is enough to drive unread badges without rewriting every
/// immutable message document.
Future<void> markConversationRead(String bookingId) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;
  final ref = conversationRef(bookingId);
  final snapshot = await ref.get();
  if (!snapshot.exists) return;
  final data = snapshot.data()!;
  final field = switch (uid) {
    final value when value == data['customerId'] => 'customerReadAt',
    final value when value == data['providerId'] => 'providerReadAt',
    _ => null,
  };
  if (field == null) return;
  await ref.update({field: FieldValue.serverTimestamp()});
}

/// Live stream of messages in a conversation, oldest first.
Stream<List<ChatMessage>> watchMessages(String bookingId) {
  return conversationRef(bookingId)
      .collection('messages')
      .orderBy('createdAt')
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) {
              final data = doc.data();
              final createdAt = data['createdAt'];
              return ChatMessage(
                senderId: data['senderId'] as String? ?? '',
                text: data['text'] as String? ?? '',
                createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
              );
            }).toList(),
      );
}

/// Live stream of the signed-in customer's conversations, most recent
/// activity first.
Stream<List<ConversationSummary>> watchMyConversationsAsCustomer() {
  // Guarded like the fetches elsewhere in this codebase — accessing
  // FirebaseAuth.instance throws synchronously with no live Firebase app
  // (e.g. widget tests), and this is called directly from a StreamBuilder's
  // `stream:` field, not from inside an async function that would convert
  // the throw into a stream error on its own.
  final String? uid;
  try {
    uid = FirebaseAuth.instance.currentUser?.uid;
  } catch (_) {
    return Stream.value(const []);
  }
  if (uid == null) return Stream.value(const []);
  return FirebaseFirestore.instance
      .collection('conversations')
      .where('customerId', isEqualTo: uid)
      .snapshots()
      .map(_toSummariesSortedByRecency);
}

/// Live stream of the signed-in provider's conversation inbox.
Stream<List<ConversationSummary>> watchMyConversationsAsProvider() {
  final String? uid;
  try {
    uid = FirebaseAuth.instance.currentUser?.uid;
  } catch (_) {
    return Stream.value(const []);
  }
  if (uid == null) return Stream.value(const []);
  return FirebaseFirestore.instance
      .collection('conversations')
      .where('providerId', isEqualTo: uid)
      .snapshots()
      .map(_toSummariesSortedByRecency);
}

Stream<bool> watchHasUnreadCustomerConversations() {
  return _watchHasUnread(watchMyConversationsAsCustomer());
}

Stream<bool> watchHasUnreadProviderConversations() {
  return _watchHasUnread(watchMyConversationsAsProvider());
}

Stream<bool> _watchHasUnread(Stream<List<ConversationSummary>> conversations) {
  return conversations.map((items) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid != null && items.any((item) => item.isUnreadFor(uid));
  });
}

List<ConversationSummary> _toSummariesSortedByRecency(
  QuerySnapshot<Map<String, dynamic>> snapshot,
) {
  final summaries =
      snapshot.docs.map((doc) {
        final data = doc.data();
        final lastMessageAt = data['lastMessageAt'];
        final customerReadAt = data['customerReadAt'];
        final providerReadAt = data['providerReadAt'];
        return ConversationSummary(
          bookingId: data['bookingId'] as String? ?? doc.id,
          customerId: data['customerId'] as String? ?? '',
          providerId: data['providerId'] as String? ?? '',
          serviceName: data['serviceName'] as String? ?? 'Service',
          lastMessageText: data['lastMessageText'] as String?,
          lastMessageAt:
              lastMessageAt is Timestamp ? lastMessageAt.toDate() : null,
          lastSenderId: data['lastSenderId'] as String?,
          customerReadAt:
              customerReadAt is Timestamp ? customerReadAt.toDate() : null,
          providerReadAt:
              providerReadAt is Timestamp ? providerReadAt.toDate() : null,
        );
      }).toList();
  summaries.sort((a, b) {
    final aTime = a.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final bTime = b.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    return bTime.compareTo(aTime);
  });
  return summaries;
}
