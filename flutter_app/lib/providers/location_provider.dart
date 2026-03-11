import 'package:flutter/material.dart';
import '../models/location.dart';

class LocationProvider extends ChangeNotifier {
  String _selectedLocation = 'Algiers, Algeria';

  String get selectedLocation => _selectedLocation;

  final List<Location> popularLocations = [
    Location(name: 'Algiers', country: 'Algeria', isPopular: true),
    Location(name: 'Oran', country: 'Algeria', isPopular: true),
    Location(name: 'Constantine', country: 'Algeria', isPopular: true),
    Location(name: 'Sétif', country: 'Algeria', isPopular: true),
    Location(name: 'Annaba', country: 'Algeria', isPopular: true),
    Location(name: 'Blida', country: 'Algeria', isPopular: true),
    Location(name: 'Tlemcen', country: 'Algeria', isPopular: true),
    Location(name: 'Batna', country: 'Algeria', isPopular: true),
  ];

  void setLocation(String location) {
    _selectedLocation = location;
    notifyListeners();
  }
}
