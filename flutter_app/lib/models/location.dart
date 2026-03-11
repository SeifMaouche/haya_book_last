class Location {
  final String name;
  final String country;
  final bool isPopular;

  Location({
    required this.name,
    required this.country,
    this.isPopular = false,
  });
}

class Booking {
  final String id;
  final String provider;
  final String service;
  final String date;
  final String time;
  final String avatar;
  final String status; // upcoming, past, cancelled
  final String? fee;

  Booking({
    required this.id,
    required this.provider,
    required this.service,
    required this.date,
    required this.time,
    required this.avatar,
    required this.status,
    this.fee,
  });

  Booking copyWith({
    String? id,
    String? provider,
    String? service,
    String? date,
    String? time,
    String? avatar,
    String? status,
    String? fee,
  }) {
    return Booking(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      service: service ?? this.service,
      date: date ?? this.date,
      time: time ?? this.time,
      avatar: avatar ?? this.avatar,
      status: status ?? this.status,
      fee: fee ?? this.fee,
    );
  }
}
