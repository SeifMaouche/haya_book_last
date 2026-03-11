class Booking {
  final String id;
  final String userId;
  final String providerId;
  final String providerName;
  final String serviceName;
  final DateTime bookingDate;
  final String timeSlot;
  final double price;
  final String status; // pending, confirmed, completed, cancelled
  final String notes;
  final DateTime createdAt;
  final DateTime? cancelledAt;

  Booking({
    required this.id,
    required this.userId,
    required this.providerId,
    required this.providerName,
    required this.serviceName,
    required this.bookingDate,
    required this.timeSlot,
    required this.price,
    required this.status,
    required this.notes,
    required this.createdAt,
    this.cancelledAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      userId: json['userId'],
      providerId: json['providerId'],
      providerName: json['providerName'],
      serviceName: json['serviceName'],
      bookingDate: DateTime.parse(json['bookingDate']),
      timeSlot: json['timeSlot'],
      price: (json['price'] as num).toDouble(),
      status: json['status'],
      notes: json['notes'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      cancelledAt:
          json['cancelledAt'] != null ? DateTime.parse(json['cancelledAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'providerId': providerId,
      'providerName': providerName,
      'serviceName': serviceName,
      'bookingDate': bookingDate.toIso8601String(),
      'timeSlot': timeSlot,
      'price': price,
      'status': status,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
    };
  }
}

class BookingRequest {
  final String providerId;
  final String serviceId;
  final DateTime bookingDate;
  final String timeSlot;
  final String notes;

  BookingRequest({
    required this.providerId,
    required this.serviceId,
    required this.bookingDate,
    required this.timeSlot,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'providerId': providerId,
      'serviceId': serviceId,
      'bookingDate': bookingDate.toIso8601String(),
      'timeSlot': timeSlot,
      'notes': notes,
    };
  }
}

class TimeSlot {
  final String time;
  final bool isAvailable;

  TimeSlot({
    required this.time,
    required this.isAvailable,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      time: json['time'],
      isAvailable: json['isAvailable'],
    );
  }
}
