class LocationModel {
  final String city;
  final String area;

  LocationModel({
    required this.city,
    required this.area,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      city: json['city'] as String,
      area: json['area'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'area': area,
    };
  }

  @override
  String toString() => '$city, $area';
}

final popularCities = [
  LocationModel(city: 'Algiers', area: 'Alger'),
  LocationModel(city: 'Oran', area: 'Oran'),
  LocationModel(city: 'Constantine', area: 'Constantine'),
  LocationModel(city: 'Sétif', area: 'Sétif'),
  LocationModel(city: 'Annaba', area: 'Annaba'),
  LocationModel(city: 'Blida', area: 'Blida'),
  LocationModel(city: 'Tlemcen', area: 'Tlemcen'),
];
