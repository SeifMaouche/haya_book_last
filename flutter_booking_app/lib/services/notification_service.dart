import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dio/dio.dart';
import './api_client.dart';
import '../models/notification_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit     = DarwinInitializationSettings();
    const initSetting = InitializationSettings(android: androidInit, iOS: iosInit);
    
    await _notifications.initialize(initSetting);
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'haya_booking_channel',
      'Haya Bookings',
      channelDescription: 'Notifications for new bookings and updates',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(id, title, body, notificationDetails);
  }

  // ── Backend API ──────────────────────────────────────────────────
  final Dio _dio = apiClient.dio;

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _dio.get('/notifications');
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> markAsRead(String id) async {
    try {
      final response = await _dio.patch('/notifications/$id/read');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      final response = await _dio.post('/notifications/read-all');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

final notificationService = NotificationService();
