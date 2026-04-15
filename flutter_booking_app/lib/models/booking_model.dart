class Booking {
  final String id;
  final String userId;
  final String providerId;
  final String providerName;
  final String providerAvatar;
  final String serviceName;
  final DateTime bookingDate;
  final String timeSlot;
  final double price;
  final String status; // pending, confirmed, completed, cancelled
  final String notes;
  final String clientName;
  final String clientAvatar;
  final DateTime createdAt;
  final DateTime? cancelledAt;
  final int durationMinutes;

  Booking({
    required this.id,
    required this.userId,
    required this.providerId,
    required this.providerName,
    this.providerAvatar = '',
    required this.serviceName,
    required this.bookingDate,
    required this.timeSlot,
    required this.price,
    required this.status,
    required this.notes,
    this.clientName = '',
    this.clientAvatar = '',
    required this.createdAt,
    this.cancelledAt,
    this.durationMinutes = 60,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      providerId: json['providerId']?.toString() ?? '',
      providerName: json['providerName'] ?? '',
      providerAvatar: json['providerAvatar'] ?? '',
      serviceName: json['serviceName'] ?? '',
      bookingDate: () {
        final raw = json['bookingDate']?.toString() ?? DateTime.now().toIso8601String();
        try {
          // Robustly extract only Y/M/D to avoid TZ shift
          final datePart = raw.split('T')[0];
          final p = datePart.split('-');
          return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
        } catch (_) {
          return DateTime.parse(raw);
        }
      }(),
      timeSlot: json['timeSlot'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      notes: json['notes'] ?? '',
      clientName: json['clientName'] ?? '',
      clientAvatar: json['clientAvatar'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      cancelledAt:
          json['cancelledAt'] != null ? DateTime.parse(json['cancelledAt']) : null,
      durationMinutes: json['durationMinutes'] ?? 60,
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
      'durationMinutes': durationMinutes,
    };
  }

  /// Combines [bookingDate] and [timeSlot] into a single [DateTime] object.
  DateTime get fullStartDateTime {
    return _combineDateAndTime(bookingDate, timeSlot);
  }

  /// Returns the estimated end time based on duration (if available in future) 
  /// or simple start + 60m fallback for UI markers.
  DateTime get fullEndDateTime {
    // Current durationMinutes is in the model, so we use it.
    // If it's missing or 0, fallback to 60.
    final duration = (durationMinutes > 0) ? durationMinutes : 60;
    return fullStartDateTime.add(Duration(minutes: duration));
  }

  DateTime _combineDateAndTime(DateTime date, String timeStr) {
    try {
      final lower = timeStr.toLowerCase().trim();
      final isPM = lower.contains('pm');
      final isAM = lower.contains('am');
      
      // Remove AM/PM for splitting
      final clean = lower.replaceAll('am', '').replaceAll('pm', '').trim();
      final parts = clean.split(':');
      
      int hour = int.parse(parts[0]);
      int min  = parts.length > 1 ? int.parse(parts[1]) : 0;
      
      if (isPM && hour != 12) hour += 12;
      if (isAM && hour == 12) hour = 0;
      
      return DateTime(date.year, date.month, date.day, hour, min);
    } catch (e) {
      // Fallback
      return date;
    }
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
