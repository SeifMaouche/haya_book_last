// lib/services/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ApiClient {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  final Dio _dio = Dio(BaseOptions(
    baseUrl:        AppConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept':        'application/json',
    },
  ));

  ApiClient() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          const secureStorage = FlutterSecureStorage();
          final token = await secureStorage.read(key: 'jwt_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (e) {
          debugPrint('--- [SecureStorage] Read Error on Request: $e ---');
          // Potential decryption error — clear all
          const secureStorage = FlutterSecureStorage();
          await secureStorage.deleteAll();
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        print('--- API ERROR: ${e.requestOptions.path} ---');
        print('Error Type   : ${e.type}');
        print('Error Message: ${e.message}');
        print('Response Code: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');

        if (e.response?.statusCode == 401) {
          // Token expired or invalid — use AuthProvider logout to sync UI
          final context = navigatorKey.currentContext;
          if (context != null) {
            try {
              // We need to use Provider to reach the AuthProvider
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            } catch (authError) {
              print('Failed to logout via AuthProvider: $authError');
              // Fallback: manual clear
              const secureStorage = FlutterSecureStorage();
              await secureStorage.deleteAll();
            }
          } else {
            // Context null — fallback manual clear
            const secureStorage = FlutterSecureStorage();
            await secureStorage.deleteAll();
          }
        }
        return handler.next(e);
      },
    ));
  }

  Dio get dio => _dio;
}

// Global singleton
final apiClient = ApiClient();
