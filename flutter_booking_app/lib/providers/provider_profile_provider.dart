// lib/providers/provider_profile_provider.dart
//
// Single source of truth for the provider's public-facing profile.
// Both the provider's edit screens and the client's detail screen
// read from / write to this provider, so whatever the provider saves
// is exactly what the client sees — ready to swap for a real API later.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../services/provider_service.dart';
import '../models/provider_model.dart'; // Add this import

class ProviderProfileProvider extends ChangeNotifier {
  final _service = ProviderService();

  // ── Core profile fields ──────────────────────────────────────
  String  id           = '';
  String  businessName = 'Lumina Wellness Spa';
  String  category     = 'Health & Wellness';
  String  bio          = '';
  LatLng  location     = const LatLng(36.7372, 3.0865);
  String  locationText = 'Algiers, DZ';
  double  rating       = 4.8;
  int     reviewCount  = 127;
  bool    isVerified   = false;

  // ── Images ───────────────────────────────────────────────────
  File?   logoFile;
  String? logoUrl;
  final List<File> portfolioPhotos = [];
  final List<PortfolioImage> portfolio = []; // Renamed from portfolioUrls

  // ── Services ─────────────────────────────────────────────────
  List<String> serviceNames = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ════════════════════════════════════════════════════════════
  // BACKEND SYNC
  // ════════════════════════════════════════════════════════════

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      final p = await _service.getCurrentProviderProfile();
      id           = p.id;
      businessName = p.name;
      category     = p.category;
      bio          = p.bio;
      location     = p.locationLatLng ?? const LatLng(36.7372, 3.0865);
      locationText = p.location;
      rating       = p.rating;
      reviewCount  = p.reviewCount;
      isVerified   = p.isVerified;
      
      logoUrl      = p.imageUrl;
      portfolio.clear();
      portfolio.addAll(p.portfolio);
      
      serviceNames = p.services.map((s) => s.name).toList();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading provider profile: $e');
    }
  }

  Future<bool> saveProfile({
    required String name,
    required String cat,
    required String about,
    required LatLng latLng,
    required String locText,
    File?            logo,
    List<File>?      newPortfolioFiles,
    List<String>?    portfolioIdsToDelete,
    bool             removeLogo = false,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      // 1. Update basic info & logo
      await _service.updateProviderProfile(
        businessName: name,
        category:     cat,
        description:  about,
        address:      locText,
        latitude:     latLng.latitude,
        longitude:    latLng.longitude,
        bio:          about,
        profileImageFile: logo,
        removePhoto:      removeLogo,
      );

      // 2. Handle portfolio deletions
      if (portfolioIdsToDelete != null && portfolioIdsToDelete.isNotEmpty) {
        for (final id in portfolioIdsToDelete) {
          await _service.deletePortfolioImage(id);
        }
      }

      // 3. Handle portfolio additions
      if (newPortfolioFiles != null && newPortfolioFiles.isNotEmpty) {
        await _service.uploadPortfolioImages(newPortfolioFiles);
      }

      // 4. Refresh local state
      await loadProfile(); 
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Save Profile Failed: $e');
      return false;
    }
  }

  // ════════════════════════════════════════════════════════════
  // LOCAL HELPERS
  // ════════════════════════════════════════════════════════════

  void setPortfolioPhotos(List<File> photos) {
    portfolioPhotos
      ..clear()
      ..addAll(photos);
    notifyListeners();
  }

  bool get hasPortfolio => portfolioPhotos.isNotEmpty || portfolio.isNotEmpty;
  bool get hasLogo      => logoFile != null || (logoUrl != null && logoUrl!.isNotEmpty);
}