// lib/providers/message_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/message_model.dart';
import '../services/message_service.dart';
import '../config/app_config.dart';
import '../providers/auth_provider.dart';
import 'package:intl/intl.dart';

class MessageProvider extends ChangeNotifier {
  final _messageService = MessageService();
  
  List<ChatConversation> _conversations = [];
  List<ChatMessage> _currentChatHistory = [];
  bool _isLoading = false;
  String? _error;
  bool _disposed = false;

  // 🔌 Socket.io 
  IO.Socket? _socket;
  String? _currentChatWithId;

  // ── Stored user id — set via updateAuth ──────────────────────
  String? _userId;

  @override
  void dispose() {
    _disposed = true;
    _socket?.disconnect();
    _socket?.dispose();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  // ── Getters ──────────────────────────────────────────────────
  List<ChatConversation> get conversations       => _conversations;
  List<ChatMessage>      get currentChatHistory  => _currentChatHistory;
  bool                   get isLoading          => _isLoading;
  String?                get error              => _error;

  /// Groups messages by date for the "TODAY" / "YESTERDAY" sticky headers
  Map<String, List<ChatMessage>> get messagesByDate {
    final groups = <String, List<ChatMessage>>{};
    for (var msg in _currentChatHistory) {
      final date = DateFormat('yyyy-MM-dd').format(msg.createdAt);
      if (!groups.containsKey(date)) groups[date] = [];
      groups[date]!.add(msg);
    }
    return groups;
  }

  // ── Socket Management ────────────────────────────────────────

  void initSocket(String token, String userId) {
    // Reconnect if userId changed (e.g. after logout/login)
    if (_socket != null && _userId == userId) return;

    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;

    final rootUrl = AppConfig.baseUrl.replaceAll('/api', '');

    // ✅ FIX: Pass BOTH token AND userId in socket auth
    // The backend uses token for authentication, userId for room management
    _socket = IO.io(rootUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .setAuth({'token': token, 'userId': userId})
      .enableAutoConnect()
      .build());

    _socket!.onConnect((_) {
      print('🔌 [Socket.io] Connected as user: $userId');
      // Re-join any active chat room after reconnect
      if (_currentChatWithId != null) {
        joinChat(_currentChatWithId!);
      }
    });
    _socket!.onDisconnect((_) => print('🔌 [Socket.io] Disconnected'));
    _socket!.onConnectError((err) => print('🔌 [Socket.io] Connect error: $err'));

    // Handle incoming messages
    _socket!.on('new_message', (data) {
      final msg = ChatMessage.fromJson(data as Map<String, dynamic>);
      
      // 1. Update current chat history if active
      if (_currentChatWithId != null) {
        final parts = msg.conversationId.split('_');
        if (parts.contains(_currentChatWithId)) {
          _currentChatHistory.add(msg);
          notifyListeners();
        }
      }

      // 2. Refresh conversation list to show latest message preview
      fetchConversations();
    });
  }

  void joinChat(String otherUserId) {
    _currentChatWithId = otherUserId;
    // ✅ FIX: Use stored _userId (set from updateAuth) — NOT socket.auth['userId']
    // socket.auth is an opaque object on the Flutter client side
    if (_userId == null || _userId!.isEmpty) {
      print('⚠️ [Socket.io] Cannot join chat — userId not set yet');
      return;
    }
    final conversationId = _generateConversationId(_userId!, otherUserId);
    print('🔌 [Socket.io] Joining room: $conversationId');
    _socket?.emit('join_conversation', conversationId);
  }

  void leaveChat() {
    if (_currentChatWithId != null && _userId != null) {
      final conversationId = _generateConversationId(_userId!, _currentChatWithId!);
      _socket?.emit('leave_conversation', conversationId);
    }
    _currentChatWithId = null;
    _currentChatHistory = [];
    notifyListeners();
  }

  String _generateConversationId(String id1, String id2) {
    final ids = [id1, id2]..sort();
    return ids.join('_');
  }

  // ── API Actions ─────────────────────────────────────────────

  void updateAuth(AuthProvider auth) {
    final newUserId = auth.userId;
    _userId = newUserId;

    if (auth.isAuthenticated && auth.token != null && newUserId != null) {
      initSocket(auth.token!, newUserId);
    } else {
      _socket?.disconnect();
      _socket = null;
    }
  }

  Future<void> fetchConversations() async {
    if (_userId == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      _conversations = await _messageService.getMyConversations(_userId!);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchChatHistory(String otherUserId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentChatHistory = await _messageService.getChatHistory(otherUserId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String otherUserId, String content) async {
    // 🚀 Optimistic Update (Immediate Feedback)
    final tempMsg = ChatMessage(
      id:             'temp-${DateTime.now().millisecondsSinceEpoch}',
      senderId:       _userId ?? 'me',
      conversationId: _generateConversationId(_userId ?? '', otherUserId),
      content:        content,
      createdAt:      DateTime.now(),
    );
    _currentChatHistory.add(tempMsg);
    notifyListeners();

    try {
      final realMsg = await _messageService.sendMessage(otherUserId, content);
      // Replace temp with real
      final idx = _currentChatHistory.indexWhere((m) => m.id == tempMsg.id);
      if (idx != -1) _currentChatHistory[idx] = realMsg;
      notifyListeners();
      fetchConversations();
    } catch (e) {
      _currentChatHistory.removeWhere((m) => m.id == tempMsg.id);
      notifyListeners();
      rethrow;
    }
  }

  void clearCurrentChat() {
    leaveChat();
  }
}
