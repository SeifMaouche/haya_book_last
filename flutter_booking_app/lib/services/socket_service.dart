import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  final _secureStorage = const FlutterSecureStorage();

  IO.Socket? get socket => _socket;

  void init() async {
    if (_socket != null && _socket!.connected) return;

    final token = await _secureStorage.read(key: 'jwt_token');
    final userId = await _secureStorage.read(key: 'userId');
    if (token == null) return;

    _socket = IO.io(AppConfig.socketUrl, 
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .setExtraHeaders({'Authorization': 'Bearer $token'})
        .enableAutoConnect()
        .build()
    );

    _socket!.onConnect((_) {
      debugPrint('--- [Socket.io] Connected ---');
      if (userId != null) {
        _socket!.emit('join_user', userId);
      }
    });

    _socket!.onDisconnect((_) => debugPrint('--- [Socket.io] Disconnected ---'));
    _socket!.onConnectError((err) => debugPrint('--- [Socket.io] Connection Error: $err ---'));
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}

final socketService = SocketService();
