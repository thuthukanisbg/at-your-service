import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/schedule_format.dart';
import '../messaging/conversation_screen.dart';
import '../messaging/messaging_service.dart';

class ProviderMessagesScreen extends StatelessWidget {
  const ProviderMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Messages',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: tokens.tx,
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<ConversationSummary>>(
                stream: watchMyConversationsAsProvider(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData && !snapshot.hasError) {
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Couldn't load messages.",
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: tokens.mut,
                        ),
                      ),
                    );
                  }
                  final conversations = snapshot.data!;
                  if (conversations.isEmpty) {
                    return Center(
                      child: Text(
                        'No conversations yet.',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: tokens.mut,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: conversations.length,
                    itemBuilder:
                        (context, index) => _ProviderConversationTile(
                          conversation: conversations[index],
                        ),
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

class _ProviderConversationTile extends StatelessWidget {
  const _ProviderConversationTile({required this.conversation});

  final ConversationSummary conversation;

  Future<String> _customerName() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(conversation.customerId)
            .get();
    return doc.data()?['name'] as String? ?? 'Customer';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final unread = uid != null && conversation.isUnreadFor(uid);
    return FutureBuilder<String>(
      future: _customerName(),
      builder: (context, snapshot) {
        final customerName = snapshot.data ?? 'Customer';
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap:
              () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (_) => ConversationScreen(
                        bookingId: conversation.bookingId,
                        customerId: conversation.customerId,
                        providerId: conversation.providerId,
                        serviceName: conversation.serviceName,
                        otherPartyName: customerName,
                      ),
                ),
              ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: tokens.card,
              border: Border.all(color: tokens.line),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    LucideIcons.user,
                    size: 19,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: tokens.tx,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        conversation.lastMessageText ??
                            conversation.serviceName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight:
                              unread ? FontWeight.w800 : FontWeight.w500,
                          color: unread ? tokens.tx : tokens.mut,
                        ),
                      ),
                    ],
                  ),
                ),
                if (conversation.lastMessageAt != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatSchedule(conversation.lastMessageAt!),
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: tokens.mut,
                          ),
                        ),
                        if (unread) ...[
                          const SizedBox(height: 7),
                          const SizedBox(
                            width: 8,
                            height: 8,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: AppColors.danger,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
