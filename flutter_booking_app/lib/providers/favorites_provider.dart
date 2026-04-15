// lib/providers/favorites_provider.dart
import 'package:flutter/material.dart';
import '../models/provider_model.dart';
import '../services/favorite_service.dart';

class FavoritesProvider extends ChangeNotifier {
  // Set of favorited provider IDs — source of truth for quick lookup
  final Set<String> _favoriteIds = {};

  // Full provider objects for the favorites list screen
  List<ServiceProvider> _favorites = [];

  bool _isLoading = false;

  List<ServiceProvider> get favorites      => List.unmodifiable(_favorites);
  bool                  get isLoading      => _isLoading;
  Set<String>           get favoriteIds    => Set.unmodifiable(_favoriteIds);

  bool isFavorite(String providerId) => _favoriteIds.contains(providerId);

  // ── Load favorites from backend on startup ───────────────────────
  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();
    try {
      final ids = await favoriteService.getMyFavoriteIds();
      _favoriteIds
        ..clear()
        ..addAll(ids);
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  // ── Load full provider objects (for favorites screen) ───────────
  Future<void> loadFavoriteProviders() async {
    _isLoading = true;
    notifyListeners();
    try {
      final raw = await favoriteService.getMyFavorites();
      _favorites = raw.map((json) => ServiceProvider.fromBackendJson(json)).toList();
    } catch (_) {
      _favorites = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  // ── Toggle (optimistic local update + API sync) ─────────────────
  Future<void> toggleFavorite(ServiceProvider provider) async {
    final wasAdded = _favoriteIds.contains(provider.id);
    // Optimistic update
    if (wasAdded) {
      _favoriteIds.remove(provider.id);
      _favorites.removeWhere((p) => p.id == provider.id);
    } else {
      _favoriteIds.add(provider.id);
      _favorites.insert(0, provider);
    }
    notifyListeners();

    try {
      await favoriteService.toggleFavorite(provider.id);
    } catch (_) {
      // Rollback on error
      if (wasAdded) {
        _favoriteIds.add(provider.id);
        _favorites.insert(0, provider);
      } else {
        _favoriteIds.remove(provider.id);
        _favorites.removeWhere((p) => p.id == provider.id);
      }
      notifyListeners();
    }
  }

  // ── Clear on logout ─────────────────────────────────────────────
  void clear() {
    _favoriteIds.clear();
    _favorites.clear();
    notifyListeners();
  }

  List<ServiceProvider> getByCategory(String? category) {
    if (category == null || category == 'All') return _favorites;
    return _favorites.where((p) => p.category == category).toList();
  }
}