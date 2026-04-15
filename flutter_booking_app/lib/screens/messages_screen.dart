// lib/screens/messages_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';
import '../config/app_config.dart';
import '../widgets/haya_avatar.dart';
import '../config/theme.dart';
import '../widgets/glass_kit.dart';
import '../widgets/bottom_nav_bar.dart';
import 'chat_screen.dart';
import 'package:intl/intl.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).fetchMyConversations();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = Provider.of<ChatProvider>(context);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFF),
      body: Column(
        children: [
          // ── Premium Header ──────────────────────────────────
          GlassHeader(
            title: 'Messages',
            subtitle: chat.conversations.isEmpty 
                ? 'No active chats' 
                : '${chat.conversations.length} active conversations',
            bottom: _SearchBar(controller: _searchCtrl),
          ),

          // ── List ────────────────────────────────────────────
          Expanded(
            child: chat.isLoading && chat.conversations.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : chat.conversations.isEmpty
                    ? _EmptyState()
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                        itemCount: chat.conversations.length,
                        itemBuilder: (_, i) {
                          final conv = chat.conversations[i];
                          return FadeSlide(
                            delay: Duration(milliseconds: 50 * i),
                            child: _ConversationTile(
                              conversation: conv,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                      receiverName: conv.otherUserName,
                                      receiverId:   conv.otherUserId,
                                      receiverAvatar: conv.otherUserImage ?? '',
                                      isProvider:     conv.otherUserRole == 'provider',
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 3,
        onTap: (i) => navigateToTab(context, i),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlassBox(
            blur: 10,
            tintOpacity: 0.1,
            radius: 30,
            padding: const EdgeInsets.all(24),
            child: Icon(Icons.forum_rounded, size: 54, color: AppColors.primary.withOpacity(0.3)),
          ),
          const SizedBox(height: 24),
          const Text('Inbox is empty',
              style: TextStyle(
                fontFamily: 'Inter', fontSize: 18,
                fontWeight: FontWeight.w800, color: AppColors.textDark,
                letterSpacing: -0.5,
              )),
          const SizedBox(height: 8),
          const Text('Connect with providers to start a conversation',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter', fontSize: 13,
                color: AppColors.textMuted,
              )),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GlassBox(
      radius: 99,
      blur: 15,
      tintOpacity: 0.2,
      borderOpacity: 0.3,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.white),
        decoration: InputDecoration(
          filled: false,
          hintText: 'Search chats...',
          hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.white.withOpacity(0.7)),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          icon: const Icon(Icons.search_rounded, color: Colors.white, size: 20),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const _ConversationTile({Key? key, required this.conversation, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final myId = auth.userId ?? '';

    final name     = conversation.otherUserName;
    final avatar   = conversation.otherUserImage ?? '';
    final lastMsg  = conversation.lastMessage.text;
    final sentAt   = conversation.lastMessage.sentAt;
    final time     = DateFormat('HH:mm').format(sentAt);
    
    final isUnread = !conversation.lastMessage.isRead && 
                     conversation.lastMessage.receiverId == myId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ScaleTap(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF0F2F5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10, offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              HayaAvatar(
                avatarUrl:    avatar,
                size:         58,
                borderRadius: 99,
                isProvider:   conversation.otherUserRole == 'provider',
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(name,
                            style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                                letterSpacing: -0.4)),
                        Text(time,
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isUnread ? AppColors.primary : AppColors.textMuted)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(lastMsg,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: isUnread ? FontWeight.w700 : FontWeight.w400,
                                  color: isUnread ? AppColors.textDark : AppColors.textMuted)),
                        ),
                        if (isUnread)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            width: 10, height: 10,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}