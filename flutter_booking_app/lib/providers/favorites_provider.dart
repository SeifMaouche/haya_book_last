import 'package:flutter/material.dart';
import '../models/provider_model.dart';

class FavoritesProvider extends ChangeNotifier {
  final List<ServiceProvider> _favorites = [];

  List<ServiceProvider> get favorites => List.unmodifiable(_favorites);

  bool isFavorite(String providerId) =>
      _favorites.any((p) => p.id == providerId);

  void toggleFavorite(ServiceProvider provider) {
    final idx = _favorites.indexWhere((p) => p.id == provider.id);
    if (idx >= 0) {
      _favorites.removeAt(idx);
    } else {
      _favorites.add(provider);
    }
    notifyListeners();
  }

  List<ServiceProvider> getByCategory(String? category) {
    if (category == null || category == 'All') return _favorites;
    return _favorites.where((p) => p.category == category).toList();
  }
}