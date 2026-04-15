// lib/models/provider_models.dart

enum ProviderBookingStatus { upcoming, completed, cancelled }

// ─────────────────────────────────────────────────────────────
// TIME BLOCK
// ─────────────────────────────────────────────────────────────
class TimeBlock {
  final String startTime;
  final String endTime;

  const TimeBlock({required this.startTime, required this.endTime});

  TimeBlock copyWith({String? startTime, String? endTime}) => TimeBlock(
    startTime: startTime ?? this.startTime,
    endTime:   endTime   ?? this.endTime,
  );

  factory TimeBlock.fromJson(Map<String, dynamic> json) => TimeBlock(
    startTime: json['startTime'] ?? '09:00',
    endTime:   json['endTime']   ?? '17:00',
  );

  bool containsTime(String time) {
    final t     = _toMinutes(time);
    final start = _toMinutes(startTime);
    final end   = _toMinutes(endTime);
    return t >= start && t < end;
  }

  int get durationMinutes => _toMinutes(endTime) - _toMinutes(startTime);

  static int _toMinutes(String t) {
    final lower = t.toLowerCase().trim();
    final parts = lower.split(' ');
    final hm    = parts[0].split(':');
    int h       = int.parse(hm[0]);
    final m     = int.parse(hm[1]);
    
    // Support optional AM/PM for compatibility during transition
    if (lower.contains('pm') && h != 12) h += 12;
    if (lower.contains('am') && h == 12) h = 0;
    
    return h * 60 + m;
  }

  @override
  String toString() => '$startTime – $endTime';
}

// ─────────────────────────────────────────────────────────────
// DAY SCHEDULE
// ─────────────────────────────────────────────────────────────
class DaySchedule {
  final String          day;
  final String          letter;
  final bool            isOpen;
  final List<TimeBlock> blocks;

  const DaySchedule({
    required this.day,
    required this.letter,
    required this.isOpen,
    required this.blocks,
  });

  String get startTime => blocks.isNotEmpty ? blocks.first.startTime : '09:00';
  String get endTime   => blocks.isNotEmpty ? blocks.last.endTime   : '17:00';

  DaySchedule copyWith({
    bool?            isOpen,
    List<TimeBlock>? blocks,
    String?          startTime,
    String?          endTime,
  }) {
    List<TimeBlock> newBlocks = blocks ?? this.blocks;
    if (blocks == null && (startTime != null || endTime != null)) {
      final first = newBlocks.isNotEmpty
          ? newBlocks.first
          : const TimeBlock(startTime: '09:00', endTime: '17:00');
      newBlocks = [
        first.copyWith(startTime: startTime, endTime: endTime),
        ...newBlocks.skip(1),
      ];
    }
    return DaySchedule(
      day:    day,
      letter: letter,
      isOpen: isOpen ?? this.isOpen,
      blocks: newBlocks,
    );
  }

  factory DaySchedule.fromJson(Map<String, dynamic> json) => DaySchedule(
    day:    json['day']     ?? 'Monday',
    letter: json['letter']  ?? 'M',
    isOpen: json['isOpen']  ?? false,
    blocks: (json['blocks'] as List<dynamic>?)
            ?.map((b) => TimeBlock.fromJson(b))
            .toList() ??
        const [],
  );

  bool isTimeAvailable(String time) {
    if (!isOpen) return false;
    return blocks.any((b) => b.containsTime(time));
  }
}

// ─────────────────────────────────────────────────────────────
// PROVIDER BOOKING
// ─────────────────────────────────────────────────────────────

/// Why a booking ended up cancelled.
enum CancelReason {
  byProvider, // provider tapped "Cancel Appointment"
  byClient,   // client cancelled from their app
  noShow,     // appointment time passed with no action taken
}

class ProviderBooking {
  final String                id;
  final String                clientName;
  final String                clientAvatar;
  final String                serviceName;
  final String                timeSlot;
  final DateTime              bookingDate;
  final double                price;
  final ProviderBookingStatus status;
  final String?               notes;
  final String                clientId; // Required for messaging back
  final bool                  clientOnline;
  final CancelReason?         cancelReason; // only set when status == cancelled

  const ProviderBooking({
    required this.id,
    required this.clientName,
    required this.clientAvatar,
    required this.serviceName,
    required this.timeSlot,
    required this.bookingDate,
    required this.price,
    required this.status,
    required this.clientId,
    this.notes,
    this.clientOnline = false,
    this.cancelReason,
  });

  factory ProviderBooking.fromClientBooking({
    required String   id,
    required String   clientName,
    required String   clientId,
    required String   clientAvatar,
    required String   serviceName,
    required String   timeSlot,
    required DateTime bookingDate,
    required double   price,
    String?           notes,
    ProviderBookingStatus? status,
    CancelReason?      cancelReason,
  }) {
    return ProviderBooking(
      id:           id,
      clientName:   clientName,
      clientAvatar: clientAvatar,
      serviceName:  serviceName,
      timeSlot:     timeSlot,
      clientId:     clientId,
      bookingDate:  bookingDate,
      price:        price,
      status:       status ?? ProviderBookingStatus.upcoming,
      notes:        notes,
      cancelReason: cancelReason,
    );
  }

  ProviderBooking copyWith({
    ProviderBookingStatus? status,
    String?                notes,
    CancelReason?          cancelReason,
  }) {
    return ProviderBooking(
      id:           id,
      clientName:   clientName,
      clientAvatar: clientAvatar,
      serviceName:  serviceName,
      timeSlot:     timeSlot,
      bookingDate:  bookingDate,
      price:        price,
      status:       status       ?? this.status,
      notes:        notes        ?? this.notes,
      clientId:     clientId,
      clientOnline: clientOnline,
      cancelReason: cancelReason ?? this.cancelReason,
    );
  }

  // ── Helpers ────────────────────────────────────────────────

  /// Parses the END time from timeSlot (e.g. "14:00 - 15:30" → 15:30,
  /// or "16:30" → 16:30) and returns the absolute DateTime of that moment.
  DateTime get appointmentEndTime {
    final parts = timeSlot.split('-');
    final endStr = parts.length >= 2 ? parts.last.trim() : parts.first.trim();
    final mins   = _parseSlotMinutes(endStr);
    return DateTime(
      bookingDate.year,
      bookingDate.month,
      bookingDate.day,
      mins ~/ 60,
      mins % 60,
    );
  }

  static int _parseSlotMinutes(String t) {
    final lower = t.toLowerCase().trim();
    final parts = lower.split(' ');
    final hm    = parts[0].split(':');
    int h       = int.tryParse(hm.isNotEmpty ? hm[0] : '09') ?? 9;
    final m     = int.tryParse(hm.length > 1 ? hm[1] : '00') ?? 0;
    
    if (lower.contains('pm') && h != 12) h += 12;
    if (lower.contains('am') && h == 12) h = 0;
    
    return h * 60 + m;
  }

  /// Returns true when the appointment end time has passed and
  /// the booking is still [upcoming] — i.e. a no-show.
  bool get isNoShow =>
      status == ProviderBookingStatus.upcoming &&
          DateTime.now().isAfter(appointmentEndTime);
}

// ─────────────────────────────────────────────────────────────
// PROVIDER SERVICE
// ─────────────────────────────────────────────────────────────
class ProviderService {
  final String  id;
  final String  name;
  final String  description;
  final double  price;
  final int     durationMinutes;
  final bool    isVisible;
  final bool    isDraft;
  final String? imageUrl;

  const ProviderService({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    this.isVisible = true,
    this.isDraft   = false,
    this.imageUrl,
  });

  ProviderService copyWith({
    String? name,
    String? description,
    double? price,
    int?    durationMinutes,
    bool?   isVisible,
    bool?   isDraft,
  }) {
    return ProviderService(
      id:              id,
      name:            name            ?? this.name,
      description:     description     ?? this.description,
      price:           price           ?? this.price,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isVisible:       isVisible       ?? this.isVisible,
      isDraft:         isDraft         ?? this.isDraft,
      imageUrl:        imageUrl,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PROVIDER STATS
// ─────────────────────────────────────────────────────────────
class ProviderStats {
  final int    todayBookings;
  final double earnings;
  final double rating;
  final int    totalReviews;
  final double earningsChangePercent;
  final int    todayChange;

  const ProviderStats({
    required this.todayBookings,
    required this.earnings,
    required this.rating,
    required this.totalReviews,
    required this.earningsChangePercent,
    required this.todayChange,
  });
}