// lib/screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _kPrimary = Color(0xFF7C3AED);
const _kPrimaryLight = Color(0xFF9F67FF);
const _kBg = Color(0xFFF5F3FF);
const _kTextDark = Color(0xFF1F2937);
const _kTextMuted = Color(0xFF6B7280);
const _kBubbleSent = Color(0xFF7C3AED);

class ChatScreen extends StatefulWidget {
  final String providerName;
  final String providerAvatar;
  final bool isProvider; // true if this is provider-side chat

  const ChatScreen({
    Key? key,
    required this.providerName,
    this.providerAvatar = '',
    this.isProvider = false,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scroll = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hello! How are you feeling today after starting your new medication?',
      'isSent': false,
      'time': '10:30 AM',
    },
    {
      'text': "I'm feeling much better, thank you doctor. The headache has completely subsided.",
      'isSent': true,
      'time': '10:32 AM',
    },
    {
      'text': "That's great news. Any side effects like dizziness or nausea?",
      'isSent': false,
      'time': '10:35 AM',
    },
    {
      'text': 'None at all. Should I continue the same dosage for the rest of the week?',
      'isSent': true,
      'time': '10:38 AM',
    },
  ];

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_msgCtrl.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'text': _msgCtrl.text.trim(),
        'isSent': true,
        'time': TimeOfDay.now().format(context),
      });
      _msgCtrl.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          // ── Purple Header ─────────────────────────────────
          _ChatHeader(
            name: widget.providerName,
            avatar: widget.providerAvatar,
            onBack: () => Navigator.pop(context),
          ),

          // ── Messages Area ─────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              itemCount: _messages.length + 1, // +1 for "TODAY" label
              itemBuilder: (_, i) {
                if (i == 0) {
                  return const _TodayLabel();
                }
                final msg = _messages[i - 1];
                return _MessageBubble(
                  text: msg['text'] as String,
                  time: msg['time'] as String,
                  isSent: msg['isSent'] as bool,
                  avatar: widget.providerAvatar,
                );
              },
            ),
          ),

          // ── Input Bar ─────────────────────────────────────
          _ChatInputBar(
            controller: _msgCtrl,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// CHAT HEADER — Purple gradient with avatar, name, online status
// ══════════════════════════════════════════════════════════════
class _ChatHeader extends StatelessWidget {
  final String name;
  final String avatar;
  final VoidCallback onBack;

  const _ChatHeader({
    required this.name,
    required this.avatar,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(12, topPad + 8, 12, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9F67FF), Color(0xFF7C3AED)],
        ),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.30),
                  width: 1,
                ),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 12),

          // Avatar with green dot
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: avatar.isNotEmpty
                    ? AssetImage(avatar)
                    : const AssetImage('assets/images/doc.png'),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    border: Border.all(color: _kPrimary, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Name + Online
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Online',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Video call button
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.30),
                  width: 1,
                ),
              ),
              child: const Icon(Icons.videocam_rounded,
                  color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 8),

          // Phone call button
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.30),
                  width: 1,
                ),
              ),
              child: const Icon(Icons.phone_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// TODAY LABEL
// ══════════════════════════════════════════════════════════════
class _TodayLabel extends StatelessWidget {
  const _TodayLabel();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 20, top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(99),
        ),
        child: const Text(
          'TODAY',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// MESSAGE BUBBLE
// ══════════════════════════════════════════════════════════════
class _MessageBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isSent;
  final String avatar;

  const _MessageBubble({
    required this.text,
    required this.time,
    required this.isSent,
    required this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
        isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // Avatar for received messages
          if (!isSent) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: avatar.isNotEmpty
                  ? AssetImage(avatar)
                  : const AssetImage('assets/images/doc.png'),
            ),
            const SizedBox(width: 8),
          ],

          // Bubble
          Flexible(
            child: Column(
              crossAxisAlignment:
              isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSent ? _kBubbleSent : const Color(0xFFEFEFEF),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft:
                      isSent ? const Radius.circular(20) : Radius.zero,
                      bottomRight:
                      isSent ? Radius.zero : const Radius.circular(20),
                    ),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      height: 1.4,
                      color: isSent ? Colors.white : _kTextDark,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Time + checkmarks
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: _kTextMuted,
                      ),
                    ),
                    if (isSent) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.done_all_rounded,
                          size: 14, color: _kPrimary),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// CHAT INPUT BAR
// ══════════════════════════════════════════════════════════════
class _ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _ChatInputBar({
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPad > 0 ? bottomPad : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Attachment button
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded,
                  color: _kTextMuted, size: 24),
            ),
          ),
          const SizedBox(width: 10),

          // Text field
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        color: _kTextDark,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Message...',
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          color: Color(0xFFBBBBBB),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onSubmitted: (_) => onSend(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.emoji_emotions_outlined,
                      color: _kTextMuted, size: 22),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Send button
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF9F67FF), Color(0xFF7C3AED)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x407C3AED),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}