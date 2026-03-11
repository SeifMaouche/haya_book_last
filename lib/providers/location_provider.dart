import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location.dart';

final locationProvider = StateNotifierProvider<LocationNotifier, LocationModel?>((ref) {
  return LocationNotifier();
});

class LocationNotifier extends StateNotifier<LocationModel?> {
  LocationNotifier() : super(null) {
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCity = prefs.getString('selected_city');
    final savedArea = prefs.getString('selected_area');

    if (savedCity != null && savedArea != null) {
      state = LocationModel(city: savedCity, area: savedArea);
    } else {
      // Default location
      state = LocationModel(city: 'Algiers', area: 'Alger');
      await _saveLocation(state!);
    }
  }

  Future<void> setLocation(LocationModel location) async {
    state = location;
    await _saveLocation(location);
  }

  Future<void> _saveLocation(LocationModel location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_city', location.city);
    await prefs.setString('selected_area', location.area);
  }
}
