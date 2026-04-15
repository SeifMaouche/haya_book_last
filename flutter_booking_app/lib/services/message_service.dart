// lib/services/message_service.dart
import 'package:dio/dio.dart';
import './api_client.dart';

class MessageService {
  final Dio _dio = apiClient.dio;

  /// Fetches all conversations for the current logged-in user.
  /// Returns a list of the latest message for each distinct conversation.
  Future<List<dynamic>> getMyConversations() async {
    try {
      final response = await _dio.get('/messages/my-conversations');
      return response.data as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches the full message history between current user and specified second user.
  Future<List<dynamic>> getConversationHistory(String secondUserId) async {
    try {
      final response = await _dio.get('/messages/conversation/$secondUserId');
      return response.data as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Sends a new message via REST API (which also triggers a Socket.io event on the backend).
  Future<Map<String, dynamic>> sendMessage(String receiverId, String content) async {
    try {
      final response = await _dio.post('/messages/send', data: {
        'receiverId': receiverId,
        'content':    content,
      });
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}
