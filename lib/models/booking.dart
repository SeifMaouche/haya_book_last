class Booking {
  final String id;
  final String doctorName;
  final String specialty;
  final String location;
  final DateTime dateTime;
  final String status; // upcoming, completed, cancelled
  final String? notes;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.location,
    required this.dateTime,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      doctorName: json['doctorName'] as String,
      specialty: json['specialty'] as String,
      location: json['location'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorName': doctorName,
      'specialty': specialty,
      'location': location,
      'dateTime': dateTime.toIso8601String(),
      'status': status,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Booking copyWith({
    String? id,
    String? doctorName,
    String? specialty,
    String? location,
    DateTime? dateTime,
    String? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return Booking(
      id: id ?? this.id,
      doctorName: doctorName ?? this.doctorName,
      specialty: specialty ?? this.specialty,
      location: location ?? this.location,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
