// lib/models/message_model.dart

class ChatMessage {
  final String    id;
  final String    senderId;
  final String    conversationId;
  final String    content;
  final bool      isRead;
  final DateTime  createdAt;
  final String?   senderName;
  final String?   senderAvatar;
  final Map<String, dynamic>? otherUser;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.conversationId,
    required this.content,
    this.isRead = false,
    required this.createdAt,
    this.senderName,
    this.senderAvatar,
    this.otherUser,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'] as Map<String, dynamic>? ?? {};
    return ChatMessage(
      id:             json['id'] as String,
      senderId:       json['senderId'] as String,
      conversationId: json['conversationId'] as String,
      content:        json['content'] as String,
      isRead:         json['isRead'] as bool? ?? false,
      createdAt:      DateTime.parse(json['createdAt'] as String),
      senderName:     ChatConversation._buildName(sender) ?? 'User',
      senderAvatar:   sender['profileImage'] as String?,
      otherUser:      json['otherUser'] as Map<String, dynamic>?,
    );
  }

  bool isMine(String currentUserId) => senderId == currentUserId;
}

class ChatConversation {
  final String      id; // conversationId
  final String      otherUserId;
  final String      otherUserName;
  final String?     otherUserAvatar;
  final String      lastMessage;
  final DateTime    lastMessageTime;
  final int         unreadCount;

  ChatConversation({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });

  /// Build a conversation entry from the backend's enriched "latest message" object.
  /// The backend now always includes an `otherUser` field derived from receiverId/senderId
  /// so we no longer need to parse conversationId strings.
  factory ChatConversation.fromLatestMessage(
    Map<String, dynamic> json,
    String currentUserId,
  ) {
    // ✅ FIX: Use the backend-provided `otherUser` directly — no string parsing
    final otherUser = json['otherUser'] as Map<String, dynamic>? ?? {};

    // Graceful fallback: if otherUser is missing, try to derive from sender/receiver
    final sender   = json['sender']   as Map<String, dynamic>? ?? {};
    final receiver = json['receiver'] as Map<String, dynamic>? ?? {};

    // Figure out the other participant's ID
    String otherId = '';
    if (otherUser['id'] != null) {
      otherId = otherUser['id'] as String;
    } else {
      // Fallback: derive from conversationId
      final parts = (json['conversationId'] as String? ?? '').split('_');
      otherId = parts.firstWhere((p) => p != currentUserId, orElse: () => '');
    }

    // Build display name
    final otherName = _buildName(otherUser) ??
        (json['senderId'] == currentUserId
            ? _buildName(receiver) ?? 'User'
            : _buildName(sender) ?? 'User');

    // Avatar
    final otherAvatar = (otherUser['profileImage'] as String?)?.isNotEmpty == true
        ? otherUser['profileImage'] as String
        : (json['senderId'] == currentUserId
            ? receiver['profileImage'] as String?
            : sender['profileImage'] as String?);

    final isMe = json['senderId'] == currentUserId;

    return ChatConversation(
      id:              json['conversationId'] as String,
      otherUserId:     otherId,
      otherUserName:   otherName,
      otherUserAvatar: otherAvatar,
      lastMessage:     json['content'] as String,
      lastMessageTime: DateTime.parse(json['createdAt'] as String),
      unreadCount:     (json['isRead'] == false && !isMe) ? 1 : 0,
    );
  }

  static String? _buildName(Map<String, dynamic> user) {
    if (user['providerProfile'] != null && user['providerProfile']['businessName'] != null) {
      return user['providerProfile']['businessName'] as String;
    }
    final first = user['firstName'] as String?;
    final last  = user['lastName']  as String?;
    if (first == null && last == null) return null;
    return '${first ?? ''} ${last ?? ''}'.trim();
  }
}
