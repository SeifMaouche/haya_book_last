// lib/providers/chat_provider.dart
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../services/message_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/socket_service.dart';

// ── Message model — Sync with Backend ────────────────────────────
class ChatMessage {
  final String   id;
  final String   conversationId;
  final String   senderId;
  final String   receiverId;
  final String   text;
  final DateTime sentAt;
  final bool     isRead;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.sentAt,
    this.isRead = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id:             json['id']?.toString() ?? '',
      conversationId: json['conversationId'] ?? '',
      senderId:       json['senderId'] ?? '',
      receiverId:     json['receiverId'] ?? '',
      text:           json['content'] ?? '',
      sentAt:         DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      isRead:         json['isRead'] ?? false,
    );
  }

  ChatMessage copyWith({bool? isRead}) => ChatMessage(
    id:             id,
    conversationId: conversationId,
    senderId:       senderId,
    receiverId:     receiverId,
    text:           text,
    sentAt:         sentAt,
    isRead:         isRead ?? this.isRead,
  );
}

// ── Conversation model — Simplified ─────────────────────────────
class Conversation {
  final String      id;         // room ID
  final String      otherUserId;
  final String      otherUserName;
  final String?     otherUserImage;
  final String      otherUserRole;
  final ChatMessage lastMessage;

  const Conversation({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserImage,
    required this.otherUserRole,
    required this.lastMessage,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final other = json['otherUser'] ?? {};
    return Conversation(
      id:             json['conversationId']?.toString() ?? '',
      otherUserId:    other['id']?.toString() ?? '',
      otherUserName:  other['providerProfile']?['businessName'] ?? "${other['firstName'] ?? ''} ${other['lastName'] ?? ''}".trim(),
      otherUserImage: other['profileImage'],
      otherUserRole:  other['role'] ?? '',
      lastMessage:    ChatMessage.fromJson(json),
    );
  }
}

// ── ChatProvider ────────────────────────────────────────────────
class ChatProvider extends ChangeNotifier {
  final MessageService _msgService = MessageService();
  IO.Socket?           _socket;
  
  List<Conversation> _conversations = [];
  List<ChatMessage>  _activeMessages = [];
  String?            _activeConversationId;
  bool               _isLoading = false;
  bool               _hasUnreadMessages = false;

  List<Conversation> get conversations   => _conversations;
  List<ChatMessage>  get activeMessages  => _activeMessages;
  bool               get isLoading       => _isLoading;
  bool               get hasUnreadMessages => _hasUnreadMessages;

  // ── Connection logic ───────────────────────────────────────────

  void initSocket() async {
    socketService.init();
    final socket = socketService.socket;
    if (socket == null) return;

    // Listeners (safe to add multiple times if handled, but better to check if already added)
    socket.off('new_message');
    socket.on('new_message', (data) {
      final msg = ChatMessage.fromJson(data);
      _handleNewIncomingMessage(msg);
    });

    socket.off('booking_update');
    socket.on('booking_update', (data) {
      debugPrint('--- [Socket.io] ChatProvider: Booking Update Received ---');
      // No explicit action needed in ChatProvider, but good to have for future sync
    });
  }

  void disposeSocket() {
    // We don't necessarily want to disconnect the global service here
    // as other providers might be using it.
  }

  // ── Conversation list ──────────────────────────────────────────

  Future<void> fetchMyConversations() async {
    _isLoading = true;
    notifyListeners();
    try {
      final raw = await _msgService.getMyConversations();
      _conversations = raw.map((c) => Conversation.fromJson(c)).toList();
      
      // Calculate global unread status
      String? myId;
      try {
        const secureStorage = FlutterSecureStorage();
        myId = await secureStorage.read(key: 'userId');
      } catch (e) {
        debugPrint('userId read error: $e');
      }

      if (myId != null) {
        _hasUnreadMessages = _conversations.any((c) => 
          !c.lastMessage.isRead && c.lastMessage.receiverId == myId);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Active Chat flow ───────────────────────────────────────────

  Future<void> enterConversation(String otherUserId) async {
    _activeMessages = [];
    _isLoading = true;
    notifyListeners();

    try {
      String myId = '';
      try {
        const secureStorage = FlutterSecureStorage();
        myId = await secureStorage.read(key: 'userId') ?? '';
      } catch (e) {
        debugPrint('--- [ChatProvider] userId read error: $e ---');
      }
      
      final roomIds = [myId, otherUserId]..sort();
      _activeConversationId = roomIds.join('_');
      
      // Join room FIRST (even if empty)
      socketService.socket?.emit('join_conversation', _activeConversationId);

      final raw = await _msgService.getConversationHistory(otherUserId);
      _activeMessages = raw.map((m) => ChatMessage.fromJson(m)).toList();
      
      // If we entered a conversation, the "global" badge might need re-calculating
      // but simpler to just refresh list soon
      await fetchMyConversations(); 

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  void leaveConversation() {
    if (_activeConversationId != null) {
      socketService.socket?.emit('leave_conversation', _activeConversationId);
      _activeConversationId = null;
    }
    _activeMessages = [];
    notifyListeners();
  }

  Future<void> sendMessage(String receiverId, String content) async {
    try {
      // Sent via REST first to ensure persistence
      final raw = await _msgService.sendMessage(receiverId, content);
      final msg = ChatMessage.fromJson(raw);
      
      // Update local state immediately for fast feel
      if (_activeMessages.isEmpty || _activeMessages.first.conversationId == msg.conversationId) {
        _activeMessages.add(msg);
        _activeConversationId = msg.conversationId;
        socketService.socket?.emit('join_conversation', msg.conversationId); // insurance
        notifyListeners();
      }
      
      // Refresh list in background
      fetchMyConversations();
    } catch (e) {
      print('Send message error: $e');
    }
  }

  // ── Background helpers ─────────────────────────────────────────

  void _handleNewIncomingMessage(ChatMessage msg) {
    // If it's for the active chat, add it
    if (_activeConversationId == msg.conversationId) {
      // Check if message already exists (we might have sent it ourselves via REST)
      if (!_activeMessages.any((m) => m.id == msg.id)) {
        _activeMessages.add(msg);
        notifyListeners();
      }
    }
    
    // Always refresh the conversation list to show latest snippet
    fetchMyConversations();

    // If not in this specific conversation, set unread badge
    if (_activeConversationId != msg.conversationId) {
      _hasUnreadMessages = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    _hasUnreadMessages = false;
    notifyListeners();
  }

  // Compatibility overrides for original UI call-sites
  void sendChatMessage({required String conversationId, required String senderId, required String text}) {
     // This old method used names as IDs. We need the actual receiverId.
     // For now, mapping this correctly requires passing the receiverId.
     print('Legacy sendChatMessage called — redirect to new flow');
  }
}