import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/schedule_format.dart';
import '../messaging/conversation_screen.dart';
import '../messaging/messaging_service.dart';

class CustomerMessagesScreen extends StatelessWidget {
  const CustomerMessagesScreen({super.key});

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
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: tokens.tx),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<ConversationSummary>>(
                stream: watchMyConversationsAsCustomer(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData && !snapshot.hasError) {
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2.4));
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Couldn't load messages.", style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: tokens.mut)),
                    );
                  }
                  final conversations = snapshot.data!;
                  if (conversations.isEmpty) {
                    return Center(
                      child: Text(
                        'No conversations yet.',
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: tokens.mut),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: conversations.length,
                    itemBuilder: (context, index) => _ConversationTile(conversation: conversations[index]),
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

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation});

  final ConversationSummary conversation;

  Future<String> _providerName() async {
    final doc = await FirebaseFirestore.instance.collection('providers').doc(conversation.providerId).get();
    return doc.data()?['displayName'] as String? ?? 'Your provider';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return FutureBuilder<String>(
      future: _providerName(),
      builder: (context, snapshot) {
        final providerName = snapshot.data ?? conversation.serviceName;
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ConversationScreen(
                bookingId: conversation.bookingId,
                customerId: conversation.customerId,
                providerId: conversation.providerId,
                serviceName: conversation.serviceName,
                otherPartyName: providerName,
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
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.14), shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: const Icon(LucideIcons.user, size: 19, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(providerName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: tokens.tx)),
                      const SizedBox(height: 2),
                      Text(
                        conversation.lastMessageText ?? conversation.serviceName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: tokens.mut),
                      ),
                    ],
                  ),
                ),
                if (conversation.lastMessageAt != null)
                  Text(
                    formatSchedule(conversation.lastMessageAt!),
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: tokens.mut),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
