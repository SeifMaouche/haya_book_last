import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../widgets/bottom_nav_bar.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final List<_Convo> _convos = [
    _Convo(
      id: '1',
      name: 'Dr. Ahmed Hassan',
      lastMsg: 'Your appointment is confirmed for tomorrow at 3PM',
      time: '2h ago',
      unread: 1,
      isOnline: true,
      category: 'Clinic',
    ),
    _Convo(
      id: '2',
      name: 'Salon Beauty Plus',
      lastMsg: 'We have an opening this Saturday, would you like to book?',
      time: '5h ago',
      unread: 0,
      isOnline: false,
      category: 'Salon',
    ),
    _Convo(
      id: '3',
      name: 'Mr. Hassan Tutor',
      lastMsg: 'See you on Friday at 3 PM for your math session',
      time: '1d ago',
      unread: 2,
      isOnline: true,
      category: 'Tutor',
    ),
  ];

  _Convo? _selected;

  @override
  Widget build(BuildContext context) {
    if (_selected != null) {
      return _ChatScreen(
        convo: _selected!,
        onBack: () => setState(() => _selected = null),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Messages'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined,
                color: AppColors.textDark),
            onPressed: () {},
          ),
        ],
      ),
      body: _convos.isEmpty
          ? _buildEmpty(context)
          : ListView.separated(
        itemCount: _convos.length,
        separatorBuilder: (_, __) =>
        const Divider(height: 1, color: AppColors.cardBorder),
        itemBuilder: (context, i) =>
            _buildConvoTile(context, _convos[i]),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 3,
        onTap: (i) => navigateToTab(context, i),
      ),
    );
  }

  Widget _buildConvoTile(BuildContext context, _Convo convo) {
    return ListTile(
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      tileColor: Colors.white,
      leading: Stack(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: convo.category == 'Salon'
                  ? AppColors.secondaryLight
                  : convo.category == 'Tutor'
                  ? const Color(0x1A3B82F6)
                  : AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                convo.category == 'Clinic'
                    ? Icons.local_hospital_outlined
                    : convo.category == 'Salon'
                    ? Icons.content_cut
                    : Icons.school_outlined,
                color: convo.category == 'Salon'
                    ? AppColors.secondary
                    : convo.category == 'Tutor'
                    ? const Color(0xFF3B82F6)
                    : AppColors.primary,
                size: 22,
              ),
            ),
          ),
          if (convo.isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 13,
                height: 13,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        convo.name,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          convo.lastMsg,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: convo.unread > 0
                ? AppColors.textDark
                : AppColors.textMuted,
            fontWeight: convo.unread > 0
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            convo.time,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: AppColors.textLight,
            ),
          ),
          if (convo.unread > 0) ...[
            const SizedBox(height: 4),
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${convo.unread}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: () => setState(() => _selected = convo),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.chat_bubble_outline,
                size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Text(
            'No conversations yet',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Book a service to start chatting',
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/browse'),
            child: const Text('Browse Providers'),
          ),
        ],
      ),
    );
  }
}

class _Convo {
  final String id, name, lastMsg, time, category;
  final int unread;
  final bool isOnline;

  const _Convo({
    required this.id,
    required this.name,
    required this.lastMsg,
    required this.time,
    required this.unread,
    required this.isOnline,
    required this.category,
  });
}

// ─── Chat Screen ───────────────────────────────────────────────
class _ChatScreen extends StatefulWidget {
  final _Convo convo;
  final VoidCallback onBack;

  const _ChatScreen({required this.convo, required this.onBack});

  @override
  State<_ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<_ChatScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final List<_Msg> _messages = [
    _Msg(text: 'Hello! I would like to book an appointment.', isMe: true),
    _Msg(text: 'Hi! Sure, what time works best for you?', isMe: false),
    _Msg(text: 'How about tomorrow at 3 PM?', isMe: true),
    _Msg(
        text: 'Your appointment is confirmed for tomorrow at 3 PM',
        isMe: false),
  ];

  void _send() {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _messages.add(_Msg(text: t, isMe: true));
      _ctrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onBack,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.convo.name,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              widget.convo.isOnline ? 'Online' : 'Offline',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              reverse: true,
              itemBuilder: (context, i) =>
                  _buildBubble(_messages[_messages.length - 1 - i]),
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildBubble(_Msg msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
        msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!msg.isMe)
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person,
                  size: 16, color: AppColors.primary),
            ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.65,
            ),
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: msg.isMe ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: msg.isMe
                    ? const Radius.circular(16)
                    : Radius.zero,
                bottomRight: msg.isMe
                    ? Radius.zero
                    : const Radius.circular(16),
              ),
              border: msg.isMe
                  ? null
                  : Border.all(color: AppColors.cardBorder),
            ),
            child: Text(
              msg.text,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: msg.isMe ? Colors.white : AppColors.textDark,
              ),
            ),
          ),
          if (msg.isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: TextField(
                controller: _ctrl,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                      color: AppColors.textLight, fontSize: 14),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _Msg {
  final String text;
  final bool isMe;
  const _Msg({required this.text, required this.isMe});
}