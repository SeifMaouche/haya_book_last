// lib/services/provider_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import './api_client.dart';
import '../models/provider_model.dart' as model;
import '../models/provider_models.dart';
import '../models/category_model.dart' as cat;
import '../models/global_search_result.dart';

class ProviderService {
  final Dio _dio = apiClient.dio;

  // ── Global Search ────────────────────────────────────────────────
  Future<List<GlobalSearchResult>> globalSearch({
    required String query,
    String? city,
    double? lat,
    double? lng,
    int? maxDistanceKm,
    int limit = 20,
  }) async {
    try {
      if (query.trim().length < 2) return [];

      final queryParams = <String, dynamic>{
        'q': query.trim(),
        'limit': limit,
      };

      if (city != null && city.trim().isNotEmpty) {
        queryParams['city'] = city.trim().split(',').first.trim();
      }
      if (lat != null) queryParams['lat'] = lat;
      if (lng != null) queryParams['lng'] = lng;
      if (maxDistanceKm != null) queryParams['maxDistanceKm'] = maxDistanceKm;

      final response = await _dio.get('/search', queryParameters: queryParams);
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((item) => GlobalSearchResult.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return []; // Return empty on error for seamless UI
    }
  }

  // ── Public provider listing ──────────────────────────────────────
  Future<List<model.ServiceProvider>> getAllProviders({
    String? category,
    double? minRating,
    double? maxPrice,
    String? sortBy,
    double? lat,
    double? lng,
    int? maxDistanceKm,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null && category != 'All') queryParams['category'] = category;
      if (minRating != null) queryParams['minRating'] = minRating;
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (lat != null) queryParams['lat'] = lat;
      if (lng != null) queryParams['lng'] = lng;
      if (maxDistanceKm != null) queryParams['maxDistanceKm'] = maxDistanceKm;

      final response = await _dio.get('/providers/all', queryParameters: queryParams);
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((item) => model.ServiceProvider.fromBackendJson(item)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<cat.Category>> getPublicCategories() async {
    try {
      final response = await _dio.get('/categories');
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((item) => cat.Category.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<model.ServiceProvider> getProviderDetails(String id) async {
    try {
      final response = await _dio.get('/providers/$id');
      return model.ServiceProvider.fromBackendJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // ── Own provider profile ─────────────────────────────────────────
  Future<model.ServiceProvider> getCurrentProviderProfile() async {
    try {
      final response = await _dio.get('/providers/profile');
      return model.ServiceProvider.fromBackendJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> becomeProvider({
    required String businessName,
    required String category,
    required String description,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.post('/providers/become', data: {
        'businessName': businessName,
        'category':     category,
        'description':  description,
        'address':      address,
        'latitude':     latitude,
        'longitude':    longitude,
      });
      return response.data['token'] as String?;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProviderProfile({
    String? businessName,
    String? category,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    String? bio,
    File? profileImageFile,
    String? firstName,
    String? lastName,
    bool removePhoto = false,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'businessName': businessName,
        'category':     category,
        'description':  description,
        'address':      address,
        'latitude':     latitude,
        'longitude':    longitude,
        'bio':          bio,
        'firstName':    firstName,
        'lastName':     lastName,
        if (removePhoto) 'removePhoto': 'true',
      };

      if (profileImageFile != null) {
        final formData = FormData.fromMap({
          ...data,
          'profileImage': await MultipartFile.fromFile(
            profileImageFile.path,
            filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        });
        await _dio.patch('/providers/profile', data: formData);
      } else {
        await _dio.patch('/providers/profile', data: data);
      }
    } catch (e) {
      rethrow;
    }
  }

  // ── Services ─────────────────────────────────────────────────────
  Future<void> addService({
    required String name,
    required String description,
    required double price,
    required int durationMinutes,
  }) async {
    try {
      await _dio.post('/services', data: {
        'name':            name,
        'description':     description,
        'price':           price,
        'durationMinutes': durationMinutes,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateService(String id, {
    required String name,
    required String description,
    required double price,
    required int durationMinutes,
  }) async {
    try {
      await _dio.patch('/services/$id', data: {
        'name':            name,
        'description':     description,
        'price':           price,
        'durationMinutes': durationMinutes,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteService(String id) async {
    try {
      await _dio.delete('/services/$id');
    } catch (e) {
      rethrow;
    }
  }

  // ── Provider Reviews ──────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getProviderReviews(String providerId) async {
    try {
      final response = await _dio.get('/reviews/provider/$providerId');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      // In case the endpoint fails or doesn't exist yet, return an empty array robustly
      return [];
    }
  }

  Future<void> submitReview({
    String? bookingId,
    String? providerProfileId,
    required double rating,
    required String comment,
  }) async {
    try {
      await _dio.post('/reviews', data: {
        if (bookingId != null) 'bookingId': bookingId,
        if (providerProfileId != null) 'providerProfileId': providerProfileId,
        'rating':    rating,
        'comment':   comment,
      });
    } catch (e) {
      rethrow;
    }
  }

  // ── Provider Stats  (today bookings, earnings, rating) ───────────
  Future<Map<String, dynamic>> getProviderStats() async {
    try {
      final response = await _dio.get('/providers/stats');
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      }
      return {'todayBookings': 0, 'totalEarnings': 0.0, 'rating': 0.0, 'reviewCount': 0};
    } catch (e) {
      // Return safe defaults on error — non-fatal
      return {'todayBookings': 0, 'totalEarnings': 0.0, 'rating': 0.0, 'reviewCount': 0};
    }
  }

  // ── Availability schedule ────────────────────────────────────────

  /// Load the provider's saved schedule from the backend.
  /// Returns null if no schedule has been saved yet (use defaults).
  Future<List<dynamic>?> getAvailability() async {
    try {
      final response = await _dio.get('/providers/availability');
      if (response.statusCode == 200) {
        return response.data['schedule'] as List<dynamic>?;
      }
      return null;
    } catch (e) {
      return null; // non-fatal
    }
  }

  Future<bool> saveAvailability(List<DaySchedule> schedule) async {
    try {
      final payload = schedule.map((day) => {
        'day':    day.day,
        'letter': day.letter,
        'isOpen': day.isOpen,
        'blocks': day.blocks.map((b) => {
          'startTime': b.startTime,
          'endTime':   b.endTime,
        }).toList(),
      }).toList();

      final response = await _dio.put('/providers/availability', data: {
        'schedule': payload,
      });
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  // ── Portfolio Upload ──────────────────────────────────────────
  Future<bool> uploadPortfolioImages(List<File> images) async {
    try {
      final formData = FormData();
      for (final img in images) {
        formData.files.add(MapEntry(
          'images', // Field name matches backend upload.array('images', 6)
          await MultipartFile.fromFile(img.path),
        ));
      }
      final response = await _dio.post('/providers/portfolio', data: formData);
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deletePortfolioImage(String imageId) async {
    try {
      final response = await _dio.delete('/providers/portfolio/$imageId');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
