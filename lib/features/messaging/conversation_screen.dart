import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/schedule_format.dart';
import '../../core/widgets/detail_screen_header.dart';
import 'messaging_service.dart';

/// Real-time chat thread for one booking's conversation — shared by both
/// the customer and provider side, since a conversation only has meaning
/// with both participants able to see and send into the same thread.
class ConversationScreen extends StatefulWidget {
  const ConversationScreen({
    super.key,
    required this.bookingId,
    required this.customerId,
    required this.providerId,
    required this.serviceName,
    required this.otherPartyName,
  });

  final String bookingId;
  final String customerId;
  final String providerId;
  final String serviceName;

  /// Display name of whoever isn't the signed-in user — resolved by the
  /// caller (customer screens show the provider's name, provider screens
  /// show the customer's), since neither side has an easy public directory
  /// lookup for the other role from within this shared screen.
  final String otherPartyName;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await sendMessage(
        bookingId: widget.bookingId,
        customerId: widget.customerId,
        providerId: widget.providerId,
        serviceName: widget.serviceName,
        text: text,
      );
      _textController.clear();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't send — please try again.")),
      );
    }
    if (!mounted) return;
    setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
              child: DetailScreenHeader(title: widget.otherPartyName),
            ),
            Expanded(
              child: StreamBuilder<List<ChatMessage>>(
                stream: watchMessages(widget.bookingId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData && !snapshot.hasError) {
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2.4));
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Couldn't load messages.", style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: tokens.mut)),
                    );
                  }
                  final messages = snapshot.data!;
                  if (messages.isEmpty) {
                    return Center(
                      child: Text(
                        'No messages yet — say hello.',
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: tokens.mut),
                      ),
                    );
                  }
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                    }
                  });
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) => _MessageBubble(message: messages[index], isMine: messages[index].senderId == myUid),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: tokens.card,
                        border: Border.all(color: tokens.line),
                        borderRadius: BorderRadius.circular(23),
                      ),
                      child: TextField(
                        controller: _textController,
                        onSubmitted: (_) => _send(),
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: tokens.tx),
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: 'Message…',
                          hintStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: tokens.mut),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: _sending ? null : _send,
                    borderRadius: BorderRadius.circular(23),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(LucideIcons.send, size: 18, color: Colors.white),
                    ),
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

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMine});

  final ChatMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: isMine ? AppColors.primary : tokens.card,
          border: isMine ? null : Border.all(color: tokens.line),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.text,
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: isMine ? Colors.white : tokens.tx),
            ),
            if (message.createdAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  formatSchedule(message.createdAt!),
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: isMine ? Colors.white.withValues(alpha: 0.7) : tokens.mut,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
