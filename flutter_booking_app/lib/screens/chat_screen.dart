// lib/screens/chat_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';
import '../config/app_config.dart';
import '../widgets/haya_avatar.dart';
import '../config/theme.dart';
import '../widgets/glass_kit.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String receiverName;
  final String receiverId;
  final String receiverAvatar;
  final bool isProvider;

  const ChatScreen({
    Key? key,
    required this.receiverName,
    required this.receiverId,
    this.receiverAvatar = '',
    this.isProvider = false,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false)
          .enterConversation(widget.receiverId);
    });
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    
    final chat = Provider.of<ChatProvider>(context, listen: false);
    chat.sendMessage(widget.receiverId, text);
    
    _msgCtrl.clear();
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = Provider.of<ChatProvider>(context);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final messages = chat.activeMessages;

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return PopScope(
      onPopInvoked: (_) => chat.leaveConversation(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFBFBFF),
        body: Column(
          children: [
            // ── Premium Header ──────────────────────────────────
            _ChatHeader(
              name: widget.receiverName,
              avatar: widget.receiverAvatar,
              isProvider: widget.isProvider,
              onBack: () => Navigator.pop(context),
            ),
      
            // ── Messages Area ───────────────────────────────────
            Expanded(
              child: chat.isLoading && messages.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : ListView.builder(
                      controller: _scroll,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                      itemCount: messages.length + 1,
                      itemBuilder: (_, i) {
                        if (i == 0) return const _DateSeparator(label: 'TODAY');
                        
                        final msg = messages[i - 1];
                        final isMe = msg.senderId == auth.userId;
                        
                        return _PremiumMessageBubble(
                          text: msg.text,
                          time: DateFormat('HH:mm').format(msg.sentAt),
                          isSent: isMe,
                          avatar: widget.receiverAvatar,
                          isProvider: widget.isProvider,
                        );
                      },
                    ),
            ),
      
            // ── Floating Input Bar ───────────────────────────────
            _FloatingInputBar(
              controller: _msgCtrl,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  final String name;
  final String avatar;
  final bool isProvider;
  final VoidCallback onBack;

  const _ChatHeader({
    required this.name,
    required this.avatar,
    required this.isProvider,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return GlassHeader(
      title: name,
      subtitle: 'Online',
      leading: GlassButton(
        onTap: onBack,
        child: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 24),
      ),
      actions: [
        Stack(
          children: [
            HayaAvatar(
              avatarUrl:    avatar,
              size:         44,
              borderRadius: 99,
              isProvider:   isProvider, 
            ),
            Positioned(
              bottom: 1, right: 1,
              child: Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DateSeparator extends StatelessWidget {
  final String label;
  const _DateSeparator({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 24),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.08),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(label,
            style: const TextStyle(
                fontFamily: 'Inter', fontSize: 10,
                fontWeight: FontWeight.w800, color: AppColors.textMuted,
                letterSpacing: 1.0)),
      ),
    );
  }
}

class _PremiumMessageBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool   isSent;
  final String avatar;
  final bool   isProvider;

  const _PremiumMessageBubble({
    required this.text,
    required this.time,
    required this.isSent,
    required this.avatar,
    this.isProvider = false,
  });

  @override
  Widget build(BuildContext context) {
    return FadeSlide(
      dy: 10,
      duration: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isSent) ...[
              HayaAvatar(
                avatarUrl:    avatar,
                size:         32,
                borderRadius: 99,
                isProvider:   isProvider,
              ),
              const SizedBox(width: 8),
            ],
            
            Flexible(
              child: Column(
                crossAxisAlignment: isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: isSent 
                          ? const LinearGradient(
                              colors: [Color(0xFF9F67FF), Color(0xFF7C3AED)],
                              begin: Alignment.topLeft, end: Alignment.bottomRight)
                          : null,
                      color: isSent ? null : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(24),
                        topRight: const Radius.circular(24),
                        bottomLeft: isSent ? const Radius.circular(24) : Radius.zero,
                        bottomRight: isSent ? Radius.zero : const Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isSent ? AppColors.primary : Colors.black).withOpacity(0.08),
                          blurRadius: 10, offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Text(text,
                        style: TextStyle(
                            fontFamily: 'Inter', fontSize: 14, height: 1.4,
                            color: isSent ? Colors.white : AppColors.textDark)),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(time,
                          style: const TextStyle(fontFamily: 'Inter', fontSize: 10, color: AppColors.textMuted)),
                      if (isSent) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.done_all_rounded, size: 14, color: AppColors.primary),
                      ],
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

class _FloatingInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _FloatingInputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, bottom > 0 ? bottom + 8 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          ScaleTap(
            onTap: () {},
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), shape: BoxShape.circle),
              child: const Icon(Icons.add_rounded, color: AppColors.primary, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2F5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Message...',
                        hintStyle: TextStyle(color: Color(0xFFABB5BE), fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onSubmitted: (_) => onSend(),
                    ),
                  ),
                  const Icon(Icons.emoji_emotions_outlined, color: AppColors.textMuted, size: 20),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          ScaleTap(
            onTap: onSend,
            child: Container(
              width: 46, height: 46,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF9F67FF), Color(0xFF7C3AED)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Color(0x407C3AED), blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}