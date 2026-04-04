// lib/screens/provider/provider_messages_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/provider_bottom_nav_bar.dart';
import '../chat_screen.dart';

const _kPrimary = Color(0xFF7C3AED);
const _kBg = Color(0xFFF5F3FF);
const _kTextDark = Color(0xFF1F2937);
const _kTextMuted = Color(0xFF6B7280);

class ProviderMessagesScreen extends StatefulWidget {
  const ProviderMessagesScreen({Key? key}) : super(key: key);

  @override
  State<ProviderMessagesScreen> createState() => _ProviderMessagesScreenState();
}

class _ProviderMessagesScreenState extends State<ProviderMessagesScreen> {
  final _searchCtrl = TextEditingController();

  final List<Map<String, dynamic>> _conversations = [
    {
      'id': '1',
      'name': 'Sarah M.',
      'avatar': '',
      'initials': 'SM',
      'lastMessage': 'Thank you for the consultation!',
      'time': '1H AGO',
      'unread': 2,
      'isOnline': true,
    },
    {
      'id': '2',
      'name': 'Ahmed K.',
      'avatar': '',
      'initials': 'AK',
      'lastMessage': 'Can I reschedule my appointment?',
      'time': '3H AGO',
      'unread': 0,
      'isOnline': false,
    },
    {
      'id': '3',
      'name': 'Fatima B.',
      'avatar': '',
      'initials': 'FB',
      'lastMessage': 'What time should I arrive tomorrow?',
      'time': 'YESTERDAY',
      'unread': 1,
      'isOnline': false,
    },
    {
      'id': '4',
      'name': 'Omar T.',
      'avatar': '',
      'initials': 'OT',
      'lastMessage': 'Is the clinic open on weekends?',
      'time': 'MON',
      'unread': 0,
      'isOnline': false,
    },
    {
      'id': '5',
      'name': 'Leila Z.',
      'avatar': '',
      'initials': 'LZ',
      'lastMessage': 'Perfect! See you then.',
      'time': 'SUN',
      'unread': 0,
      'isOnline': false,
    },
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────
            _MessagesHeader(),
            const SizedBox(height: 16),

            // ── Search Bar ────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SearchBar(controller: _searchCtrl),
            ),
            const SizedBox(height: 20),

            // ── Conversations List ────────────────────────
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(
                    16, 0, 16, MediaQuery.of(context).padding.bottom + 90),
                itemCount: _conversations.length,
                itemBuilder: (_, i) => _ConversationTile(
                  conversation: _conversations[i],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          providerName: _conversations[i]['name'] as String,
                          providerAvatar: _conversations[i]['avatar'] as String,
                          isProvider: true,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const ProviderBottomNavBar(currentIndex: 2),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// MESSAGES HEADER
// ══════════════════════════════════════════════════════════════
class _MessagesHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          // HayaBook logo
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _kPrimary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_month_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Text(
            'HayaBook',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _kTextDark,
            ),
          ),
          const Spacer(),
          // Location chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.location_on, color: _kPrimary, size: 16),
                SizedBox(width: 4),
                Text(
                  'Algiers, Algeria',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _kTextDark,
                  ),
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
// SEARCH BAR
// ══════════════════════════════════════════════════════════════
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Messages',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: _kTextDark,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              color: _kTextDark,
            ),
            decoration: const InputDecoration(
              hintText: 'Search conversations...',
              hintStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                color: Color(0xFFBBBBBB),
              ),
              border: InputBorder.none,
              icon: Icon(Icons.search_rounded,
                  color: Color(0xFFBBBBBB), size: 22),
              contentPadding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// CONVERSATION TILE
// ══════════════════════════════════════════════════════════════
class _ConversationTile extends StatelessWidget {
  final Map<String, dynamic> conversation;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = conversation['name'] as String;
    final avatar = conversation['avatar'] as String;
    final initials = conversation['initials'] as String? ?? '';
    final lastMsg = conversation['lastMessage'] as String;
    final time = conversation['time'] as String;
    final unread = conversation['unread'] as int;
    final isOnline = conversation['isOnline'] as bool? ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            // Avatar with online dot
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFFE5E7EB),
                  backgroundImage: avatar.isNotEmpty
                      ? AssetImage(avatar)
                      : null,
                  child: avatar.isEmpty
                      ? Text(
                    initials.isNotEmpty
                        ? initials
                        : name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _kPrimary,
                    ),
                  )
                      : null,
                ),
                if (isOnline)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),

            // Name + message preview
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _kTextDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMsg,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: unread > 0
                          ? _kTextDark
                          : _kTextMuted,
                      fontWeight: unread > 0
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Time + unread badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: unread > 0 ? _kPrimary : _kTextMuted,
                  ),
                ),
                if (unread > 0) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: const BoxDecoration(
                      color: _kPrimary,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 22),
                    child: Text(
                      '$unread',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}