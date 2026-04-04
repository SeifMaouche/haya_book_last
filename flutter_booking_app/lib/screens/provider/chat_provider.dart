// lib/providers/chat_provider.dart
//
// Shared messaging state. Both client and provider sides read from
// and write to the same ChatProvider instance (registered at app root).
//
// Conversation ID convention: 'client_id__provider_id__booking_id'
// For the demo we use provider names as IDs.
// ─────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';

// ── Message model ─────────────────────────────────────────────
class ChatMessage {
  final String  id;
  final String  conversationId;
  final String  senderId;    // 'client' | 'provider'
  final String  text;
  final DateTime sentAt;
  final bool    isRead;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.sentAt,
    this.isRead = false,
  });

  ChatMessage copyWith({bool? isRead}) => ChatMessage(
    id:             id,
    conversationId: conversationId,
    senderId:       senderId,
    text:           text,
    sentAt:         sentAt,
    isRead:         isRead ?? this.isRead,
  );
}

// ── Conversation model ────────────────────────────────────────
class Conversation {
  final String id;            // unique conversation ID
  final String clientName;
  final String providerName;
  final String providerCategory;
  final String? bookingId;    // optional — links to a booking
  final List<ChatMessage> messages;

  const Conversation({
    required this.id,
    required this.clientName,
    required this.providerName,
    required this.providerCategory,
    this.bookingId,
    this.messages = const [],
  });

  ChatMessage? get lastMessage =>
      messages.isNotEmpty ? messages.last : null;

  int unreadCount(String viewerRole) =>
      messages.where((m) => !m.isRead && m.senderId != viewerRole).length;

  Conversation copyWith({List<ChatMessage>? messages}) => Conversation(
    id:               id,
    clientName:       clientName,
    providerName:     providerName,
    providerCategory: providerCategory,
    bookingId:        bookingId,
    messages:         messages ?? this.messages,
  );
}

// ── ChatProvider ──────────────────────────────────────────────
class ChatProvider extends ChangeNotifier {

  // ── Demo conversations seeded with some messages ──────────
  final List<Conversation> _conversations = [
    Conversation(
      id:               'conv_1',
      clientName:       'Ahmed Benali',
      providerName:     "Bella's Beauty Salon",
      providerCategory: 'Salon',
      bookingId:        'BK2024001',
      messages: [
        ChatMessage(
          id:             'm1', conversationId: 'conv_1',
          senderId:       'provider',
          text:           'Hello Ahmed! Your appointment for Hair Cut & Style is confirmed for tomorrow at 10:00 AM. See you then! 💜',
          sentAt:         DateTime.now().subtract(const Duration(hours: 2)),
          isRead:         true,
        ),
        ChatMessage(
          id:             'm2', conversationId: 'conv_1',
          senderId:       'client',
          text:           'Great, thank you! Should I arrive a few minutes early?',
          sentAt:         DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
          isRead:         true,
        ),
        ChatMessage(
          id:             'm3', conversationId: 'conv_1',
          senderId:       'provider',
          text:           'Yes please! Come 5 minutes early so we can get started right away 😊',
          sentAt:         DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
          isRead:         false,
        ),
      ],
    ),
    Conversation(
      id:               'conv_2',
      clientName:       'Ahmed Benali',
      providerName:     'Dr. Jhon Johnson',
      providerCategory: 'Clinic',
      bookingId:        'BK2024002',
      messages: [
        ChatMessage(
          id:             'm4', conversationId: 'conv_2',
          senderId:       'provider',
          text:           'Hi Ahmed, please bring your previous medical records to the consultation.',
          sentAt:         DateTime.now().subtract(const Duration(days: 1)),
          isRead:         true,
        ),
        ChatMessage(
          id:             'm5', conversationId: 'conv_2',
          senderId:       'client',
          text:           'Will do, thank you Doctor.',
          sentAt:         DateTime.now().subtract(const Duration(hours: 20)),
          isRead:         true,
        ),
      ],
    ),
    Conversation(
      id:               'conv_3',
      clientName:       'Ahmed Benali',
      providerName:     'Prof. James Tutoring',
      providerCategory: 'Tutor',
      messages: [
        ChatMessage(
          id:             'm6', conversationId: 'conv_3',
          senderId:       'provider',
          text:           'Welcome! Ready for your first Math session? Let me know if you have any questions.',
          sentAt:         DateTime.now().subtract(const Duration(days: 2)),
          isRead:         false,
        ),
      ],
    ),
  ];

  // ── Getters ───────────────────────────────────────────────

  List<Conversation> get conversations =>
      List.unmodifiable(_conversations);

  /// All conversations sorted by latest message first.
  List<Conversation> get sortedConversations {
    final sorted = List<Conversation>.from(_conversations);
    sorted.sort((a, b) {
      final aTime = a.lastMessage?.sentAt ?? DateTime(2000);
      final bTime = b.lastMessage?.sentAt ?? DateTime(2000);
      return bTime.compareTo(aTime);
    });
    return sorted;
  }

  /// Conversations for a specific provider (by name).
  List<Conversation> conversationsForProvider(String providerName) =>
      _conversations
          .where((c) => c.providerName == providerName)
          .toList();

  /// Get or create a conversation between client and provider.
  Conversation getOrCreate({
    required String providerName,
    required String providerCategory,
    required String clientName,
    String?         bookingId,
  }) {
    final existing = _conversations.firstWhere(
          (c) => c.providerName == providerName && c.clientName == clientName,
      orElse: () {
        final newConv = Conversation(
          id:               'conv_${DateTime.now().millisecondsSinceEpoch}',
          clientName:       clientName,
          providerName:     providerName,
          providerCategory: providerCategory,
          bookingId:        bookingId,
          messages:         const [],
        );
        _conversations.add(newConv);
        notifyListeners();
        return newConv;
      },
    );
    return existing;
  }

  /// Get a conversation by ID.
  Conversation? getById(String id) {
    try {
      return _conversations.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Send message ──────────────────────────────────────────

  void sendMessage({
    required String conversationId,
    required String senderId, // 'client' or 'provider'
    required String text,
  }) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx == -1) return;

    final msg = ChatMessage(
      id:             'msg_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId:       senderId,
      text:           trimmed,
      sentAt:         DateTime.now(),
      isRead:         false,
    );

    final updated = _conversations[idx].copyWith(
      messages: [..._conversations[idx].messages, msg],
    );
    _conversations[idx] = updated;
    notifyListeners();
  }

  // ── Mark messages as read ─────────────────────────────────
  void markAsRead(String conversationId, String viewerRole) {
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx == -1) return;

    final updatedMsgs = _conversations[idx].messages.map((m) {
      // Mark messages sent by the OTHER side as read
      if (!m.isRead && m.senderId != viewerRole) {
        return m.copyWith(isRead: true);
      }
      return m;
    }).toList();

    _conversations[idx] = _conversations[idx].copyWith(messages: updatedMsgs);
    notifyListeners();
  }

  // ── Total unread for a role ───────────────────────────────
  int totalUnread(String viewerRole) =>
      _conversations.fold(0, (sum, c) => sum + c.unreadCount(viewerRole));
}