// lib/providers/provider_profile_provider.dart
//
// Single source of truth for the provider's public-facing profile.
// Both the provider's edit screens and the client's detail screen
// read from / write to this provider, so whatever the provider saves
// is exactly what the client sees — ready to swap for a real API later.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class ProviderProfileProvider extends ChangeNotifier {

  // ── Core profile fields ──────────────────────────────────────
  String  businessName = 'Lumina Wellness Spa';
  String  category     = 'Health & Wellness';
  String  bio          =
      'At Lumina Wellness, we believe in a holistic approach to '
      'relaxation and recovery. Our certified practitioners offer a '
      'range of luxury treatments designed to rejuvenate your body '
      'and soul.';

  // ── Location ─────────────────────────────────────────────────
  LatLng  location     = const LatLng(36.7372, 3.0865);
  String  locationText = 'Algiers, DZ';

  // ── Images ───────────────────────────────────────────────────
  /// The provider's logo / avatar (picked from device).
  File?   logoFile;

  /// Portfolio / gallery photos uploaded by the provider.
  /// Each entry is a [File] picked from the device.
  final List<File> portfolioPhotos = [];

  // ── Rating / review stats (set by backend later) ─────────────
  double  rating       = 4.8;
  int     reviewCount  = 127;

  // ── Services (managed by provider_services_screen) ───────────
  // Kept minimal here — detailed management lives in provider_state.dart.
  // These are the public-facing service names shown on the detail page.
  List<String> serviceNames = [
    'Consultation',
    'Deep Tissue Massage',
    'Aromatherapy Facial',
  ];

  // ════════════════════════════════════════════════════════════
  // UPDATE METHODS  (called from edit/complete profile screens)
  // ════════════════════════════════════════════════════════════

  void updateBasicInfo({
    required String name,
    required String cat,
    required String about,
  }) {
    businessName = name.trim().isEmpty ? businessName : name.trim();
    category     = cat;
    bio          = about.trim().isEmpty ? bio : about.trim();
    notifyListeners();
  }

  void updateLocation(LatLng latLng, String text) {
    location     = latLng;
    locationText = text;
    notifyListeners();
  }

  void setLogo(File file) {
    logoFile = file;
    notifyListeners();
  }

  void addPortfolioPhoto(File file) {
    portfolioPhotos.add(file);
    notifyListeners();
  }

  void removePortfolioPhoto(int index) {
    if (index >= 0 && index < portfolioPhotos.length) {
      portfolioPhotos.removeAt(index);
      notifyListeners();
    }
  }

  /// Bulk-replace all portfolio photos (used by edit profile screen).
  void setPortfolioPhotos(List<File> photos) {
    portfolioPhotos
      ..clear()
      ..addAll(photos);
    notifyListeners();
  }

  /// Full profile save — called when provider taps "Save Changes".
  void saveProfile({
    required String name,
    required String cat,
    required String about,
    required LatLng latLng,
    required String locText,
    File?            logo,
    List<File>?      gallery,
  }) {
    businessName = name.trim().isEmpty ? businessName : name.trim();
    category     = cat;
    bio          = about.trim().isEmpty ? bio : about.trim();
    location     = latLng;
    locationText = locText;
    if (logo != null) logoFile = logo;
    if (gallery != null) setPortfolioPhotos(gallery);
    notifyListeners();
  }

  // ── Helpers ──────────────────────────────────────────────────

  /// True when the provider has uploaded at least one portfolio photo.
  bool get hasPortfolio => portfolioPhotos.isNotEmpty;

  /// True when the provider has a logo/avatar set.
  bool get hasLogo => logoFile != null;
}