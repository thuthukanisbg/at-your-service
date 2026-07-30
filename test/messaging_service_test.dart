import 'package:flutter_test/flutter_test.dart';

import 'package:at_your_service/features/messaging/messaging_service.dart';

ConversationSummary _conversation({
  required String lastSenderId,
  required DateTime lastMessageAt,
  DateTime? customerReadAt,
  DateTime? providerReadAt,
}) {
  return ConversationSummary(
    bookingId: 'booking-1',
    customerId: 'customer-1',
    providerId: 'provider-1',
    serviceName: 'Cleaning',
    lastMessageText: 'Hello',
    lastMessageAt: lastMessageAt,
    lastSenderId: lastSenderId,
    customerReadAt: customerReadAt,
    providerReadAt: providerReadAt,
  );
}

void main() {
  final sentAt = DateTime(2026, 7, 30, 10);

  test('a receiver sees a new message as unread', () {
    final conversation = _conversation(
      lastSenderId: 'provider-1',
      lastMessageAt: sentAt,
    );

    expect(conversation.isUnreadFor('customer-1'), isTrue);
    expect(conversation.isUnreadFor('provider-1'), isFalse);
  });

  test('a read receipt clears unread state', () {
    final conversation = _conversation(
      lastSenderId: 'customer-1',
      lastMessageAt: sentAt,
      providerReadAt: sentAt.add(const Duration(seconds: 1)),
    );

    expect(conversation.isUnreadFor('provider-1'), isFalse);
  });

  test('an older receipt does not clear a newer message', () {
    final conversation = _conversation(
      lastSenderId: 'customer-1',
      lastMessageAt: sentAt,
      providerReadAt: sentAt.subtract(const Duration(seconds: 1)),
    );

    expect(conversation.isUnreadFor('provider-1'), isTrue);
  });
}
