// lib/models/notification_model.dart
import 'dart:convert';

class NotificationModel {
  final String  id;
  final String  userId;
  final String  type;   // BOOKING_CONFIRMED | BOOKING_CANCELLED | NEW_MESSAGE | BOOKING_COMPLETED | GENERAL
  final String  title;
  final String  body;
  final bool    isRead;
  final Map<String, dynamic>? data;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    this.data,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? parsedData;
    if (json['data'] != null) {
      try {
        parsedData = Map<String, dynamic>.from(jsonDecode(json['data'] as String));
      } catch (_) {}
    }
    return NotificationModel(
      id:        json['id']     as String,
      userId:    json['userId'] as String,
      type:      json['type']   as String,
      title:     json['title']  as String,
      body:      json['body']   as String,
      isRead:    json['isRead'] as bool? ?? false,
      data:      parsedData,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
    id:        id,
    userId:    userId,
    type:      type,
    title:     title,
    body:      body,
    isRead:    isRead ?? this.isRead,
    data:      data,
    createdAt: createdAt,
  );
}
