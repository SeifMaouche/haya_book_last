// lib/services/auth_service.dart
import 'package:dio/dio.dart';
import './api_client.dart';

class AuthService {
  final Dio _dio = apiClient.dio;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Login failed');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register({
    String? email,
    String? phone,
    required String password,
    String? firstName,
    String? lastName,
    String? role,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'email': email,
        'phone': phone,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'role': role,
      });

      if (response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Registration failed');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String identifier, String code) async {
    try {
      final response = await _dio.post('/auth/verify-otp', data: {
        'identifier': identifier,
        'code': code,
      });

      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Verification failed');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> resendOtp(String identifier) async {
    try {
      final response = await _dio.post('/auth/resend-otp', data: {
        'identifier': identifier,
      });
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> sendOtp(String identifier) async {
    try {
      final response = await _dio.post('/auth/send-otp', data: {
        'identifier': identifier,
      });
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/users/me');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getProviderProfile() async {
    try {
      final response = await _dio.get('/providers/profile');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? bio,
    String? phone,
    String? password,
    String? photoPath,
    bool removePhoto = false,
  }) async {
    try {
      final Map<String, dynamic> body = {
        if (firstName != null) 'firstName': firstName,
        if (lastName  != null) 'lastName':  lastName,
        if (email     != null) 'email':     email,
        if (bio       != null) 'bio':       bio,
        if (phone     != null) 'phone':     phone,
        if (password  != null) 'password':  password,
        if (removePhoto)      'removePhoto': 'true',
      };

      if (photoPath != null) {
        final formData = FormData.fromMap({
          ...body,
          'profileImage': await MultipartFile.fromFile(
            photoPath,
            filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        });
        final response = await _dio.put('/auth/update-profile', data: formData);
        return response.data['user'];
      } else {
        final response = await _dio.put('/auth/update-profile', data: body);
        return response.data['user'];
      }
    } catch (e) {
      rethrow;
    }
  }
}
