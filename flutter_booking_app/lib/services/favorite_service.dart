// lib/services/favorite_service.dart
import 'package:dio/dio.dart';
import './api_client.dart';

class FavoriteService {
  final Dio _dio = apiClient.dio;

  /// Returns the full provider objects for the current user's favorites list.
  Future<List<Map<String, dynamic>>> getMyFavorites() async {
    try {
      final response = await _dio.get('/favorites');
      return List<Map<String, dynamic>>.from(response.data as List);
    } catch (e) {
      return [];
    }
  }

  /// Returns only the list of providerProfileIds that the user has favorited.
  /// Used for fast local hydration on startup.
  Future<List<String>> getMyFavoriteIds() async {
    try {
      final response = await _dio.get('/favorites/ids');
      return List<String>.from(response.data as List);
    } catch (e) {
      return [];
    }
  }

  /// Toggles favorite status. Returns true if now favorited, false if removed.
  Future<bool> toggleFavorite(String providerProfileId) async {
    try {
      final response = await _dio.post('/favorites/toggle', data: {
        'providerProfileId': providerProfileId,
      });
      return response.data['isFavorite'] as bool? ?? false;
    } catch (e) {
      rethrow;
    }
  }

  /// Checks whether a single provider is currently favorited.
  Future<bool> isFavorite(String providerProfileId) async {
    try {
      final response = await _dio.get('/favorites/check/$providerProfileId');
      return response.data['isFavorite'] as bool? ?? false;
    } catch (e) {
      return false;
    }
  }
}

final favoriteService = FavoriteService();
