// lib/screens/provider/provider_messages_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_config.dart';
import '../../widgets/provider_bottom_nav_bar.dart';
import '../../widgets/glass_kit.dart';
import '../../widgets/haya_avatar.dart';
import '../chat_screen.dart';

const _kPrimary     = Color(0xFF6D28D9);
const _kPrimaryDark = Color(0xFF4C1D95);
const _kBg          = Color(0xFFF8FAFC);
const _kTextDark    = Color(0xFF0F172A);
const _kTextMuted   = Color(0xFF64748B);

class ProviderMessagesScreen extends StatefulWidget {
  const ProviderMessagesScreen({Key? key}) : super(key: key);

  @override
  State<ProviderMessagesScreen> createState() => _ProviderMessagesScreenState();
}

class _ProviderMessagesScreenState extends State<ProviderMessagesScreen> {
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
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Light status bar text to contrast with deep purple glass header
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:          Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: _kBg,
      extendBody: true,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: GlassHeader(
              title:    'Messages',
              subtitle: '${chat.conversations.length} client conversations',
              actions: [
                 ScaleTap(
                   onTap: () {
                     showMenu(
                       context: context,
                       position: const RelativeRect.fromLTRB(100, 80, 20, 0),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                       items: [
                         const PopupMenuItem(
                           value: 'read_all',
                           child: Row(children: [
                             Icon(Icons.done_all_rounded, size: 18, color: _kTextDark),
                             SizedBox(width: 10),
                             Text('Mark all as read', style: TextStyle(fontSize: 14)),
                           ]),
                         ),
                         const PopupMenuItem(
                           value: 'refresh',
                           child: Row(children: [
                             Icon(Icons.refresh_rounded, size: 18, color: _kTextDark),
                             SizedBox(width: 10),
                             Text('Refresh', style: TextStyle(fontSize: 14)),
                           ]),
                         ),
                       ],
                     ).then((value) {
                       if (value == 'read_all') {
                         Provider.of<ChatProvider>(context, listen: false).markAllAsRead();
                       } else if (value == 'refresh') {
                         Provider.of<ChatProvider>(context, listen: false).fetchMyConversations();
                       }
                     });
                   },
                   child: Container(
                     width: 44, height: 44,
                     decoration: BoxDecoration(
                       shape: BoxShape.circle,
                       color: Colors.white.withOpacity(0.15),
                       border: Border.all(color: Colors.white.withOpacity(0.3)),
                     ),
                     child: const Icon(Icons.more_horiz_rounded, color: Colors.white),
                   ),
                 ),
              ],
              bottom: _SearchBar(
                controller: _searchCtrl,
                onChanged: (v) => setState(() {}),
              ),
            ),
          ),
          
          if (chat.isLoading && chat.conversations.isEmpty)
             const SliverFillRemaining(
               child: Center(
                 child: CircularProgressIndicator(color: _kPrimary),
               ),
             )
          else if (chat.conversations.isEmpty)
             const SliverFillRemaining(
               child: _EmptyState(),
             )
          else
             SliverPadding(
               padding: EdgeInsets.fromLTRB(
                   16, 24, 16, MediaQuery.of(context).padding.bottom + 110),
               sliver: SliverList(
                 delegate: SliverChildBuilderDelegate(
                   (context, i) {
                     final filtered = chat.conversations.where((c) =>
                       c.otherUserName.toLowerCase().contains(_searchCtrl.text.toLowerCase())
                     ).toList();
                     
                     if (i >= filtered.length) return null;
                     
                     final conv = filtered[i];
                     return FadeSlide(
                       delay: Duration(milliseconds: 50 * i),
                       child: _ConversationTile(
                         conversation: conv,
                         currentUserId: auth.userId,
                         onTap: () {
                           Navigator.push(
                             context,
                             MaterialPageRoute(
                               builder: (_) => ChatScreen(
                                 receiverName:   conv.otherUserName,
                                 receiverId:     conv.otherUserId,
                                 receiverAvatar: conv.otherUserImage ?? '',
                                 isProvider:     true,
                               ),
                             ),
                           );
                         },
                       ),
                     );
                   },
                   childCount: chat.conversations.where((c) =>
                       c.otherUserName.toLowerCase().contains(_searchCtrl.text.toLowerCase())
                     ).length,
                 ),
               ),
             ),
        ],
      ),
      bottomNavigationBar: const ProviderBottomNavBar(currentIndex: 2),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// EMPTY STATE
// ══════════════════════════════════════════════════════════════
class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: _kPrimary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.chat_bubble_outline_rounded,
              size: 32, color: _kPrimary),
        ),
        const SizedBox(height: 20),
        const Text('No messages yet', style: TextStyle(
          fontFamily: 'Inter', fontSize: 18,
          fontWeight: FontWeight.w700, color: _kTextDark,
        )),
        const SizedBox(height: 8),
        const Text('Your client conversations will appear here.', style: TextStyle(
          fontFamily: 'Inter', fontSize: 14,
          fontWeight: FontWeight.w400, color: _kTextMuted,
        )),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SEARCH BAR
// ══════════════════════════════════════════════════════════════
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  const _SearchBar({required this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: SizedBox(
        width:  double.infinity,
        height: 52,
        child: GlassBox(
          radius: 16,
          tint: Colors.white,
          tintOpacity: 0.90,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: Colors.black.withOpacity(0.5), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 15,
                    color: Colors.black87, fontWeight: FontWeight.w500,
                  ),
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    hintText: 'Search clients...',
                    hintStyle: TextStyle(
                      fontFamily: 'Inter', fontSize: 15,
                      color: Colors.black.withOpacity(0.4),
                    ),
                    border: InputBorder.none,
                    suffixIcon: controller.text.isNotEmpty 
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            controller.clear();
                            if (onChanged != null) onChanged!('');
                          },
                        ) 
                      : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// CONVERSATION TILE  —  Matches client's premium card design
// ══════════════════════════════════════════════════════════════
class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final String?      currentUserId;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name   = conversation.otherUserName;
    final avatar = conversation.otherUserImage;
    final msg    = conversation.lastMessage;
    
    // Determine unread logic using current block
    final isUnread = !msg.isRead && (msg.receiverId == currentUserId);
    final time     = DateFormat('HH:mm').format(msg.sentAt);

    return ScaleTap(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF0F2F5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Premium Avatar
            Stack(
              clipBehavior: Clip.none,
              children: [
                HayaAvatar(
                  avatarUrl: avatar,
                  size: 58,
                  isProvider: false, // These are clients
                  borderRadius: 99,
                ),
                if (isUnread) ...[
                  Positioned(
                    top: 0, right: 0,
                    child: Container(
                      width: 14, height: 14,
                      decoration: BoxDecoration(
                        color: _kPrimary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontFamily: 'Inter', fontSize: 16,
                            fontWeight: isUnread ? FontWeight.w800 : FontWeight.w700,
                            color: _kTextDark,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          fontFamily: 'Inter', fontSize: 12,
                          fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
                          color: isUnread ? _kPrimary : _kTextMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          msg.text,
                          style: TextStyle(
                            fontFamily: 'Inter', fontSize: 14,
                            fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                            color: isUnread ? _kTextDark : _kTextMuted,
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(
                            color: _kPrimary,
                            shape: BoxShape.circle,
                          ),
                        ),
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