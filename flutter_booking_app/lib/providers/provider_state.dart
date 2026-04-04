// lib/providers/provider_state.dart

import 'package:flutter/material.dart';
import '../models/provider_models.dart';

class ProviderStateProvider extends ChangeNotifier {
  // ── Mock data ────────────────────────────────────────────────

  final List<ProviderBooking> _bookings = [
    // ── Today upcoming ──────────────────────────────────────
    ProviderBooking(
      id:           'pb1',
      clientName:   'Aria Montgomery',
      clientAvatar: '',
      serviceName:  'Full Glam Transformation',
      timeSlot:     '02:00 PM - 03:30 PM',
      bookingDate:  DateTime.now(),
      price:        5500,
      status:       ProviderBookingStatus.upcoming,
      clientOnline: true,
    ),
    ProviderBooking(
      id:           'pb2',
      clientName:   'Sophie Chen',
      clientAvatar: '',
      serviceName:  'Bridal Trial Package',
      timeSlot:     '06:15 PM - 07:15 PM',
      bookingDate:  DateTime.now(),
      price:        8000,
      status:       ProviderBookingStatus.upcoming,
    ),
    // ── Completed ───────────────────────────────────────────
    ProviderBooking(
      id:           'pb3',
      clientName:   'Yasmine Benali',
      clientAvatar: '',
      serviceName:  'Full Glam Transformation',
      timeSlot:     '11:00 AM - 12:30 PM',
      bookingDate:  DateTime.now().subtract(const Duration(days: 2)),
      price:        5500,
      status:       ProviderBookingStatus.completed,
    ),
    ProviderBooking(
      id:           'pb4',
      clientName:   'Lena Dupont',
      clientAvatar: '',
      serviceName:  'Signature Hair Styling',
      timeSlot:     '09:00 AM - 09:45 AM',
      bookingDate:  DateTime.now().subtract(const Duration(days: 1)),
      price:        3000,
      status:       ProviderBookingStatus.completed,
    ),
    // ── Cancelled by provider ────────────────────────────────
    ProviderBooking(
      id:           'pb5',
      clientName:   'Marcus Webb',
      clientAvatar: '',
      serviceName:  'Deep Cleansing Facial',
      timeSlot:     '03:00 PM - 04:00 PM',
      bookingDate:  DateTime.now().subtract(const Duration(days: 3)),
      price:        4200,
      status:       ProviderBookingStatus.cancelled,
      cancelReason: CancelReason.byProvider,
    ),
    // ── No-show (appointment time is in the past, still "upcoming" in data
    //    → resolveNoShows() will flip it to cancelled/noShow at runtime) ──
    ProviderBooking(
      id:           'pb6',
      clientName:   'Jordan Kim',
      clientAvatar: '',
      serviceName:  'Bridal Trial Package',
      timeSlot:     '10:00 AM - 12:00 PM',
      bookingDate:  DateTime.now().subtract(const Duration(days: 1)),
      price:        8000,
      status:       ProviderBookingStatus.upcoming, // will become cancelled/noShow
    ),
  ];

  List<ProviderService> _services = [
    ProviderService(
      id: 's1', name: 'Full Glam Transformation',
      description: 'Complete makeup including foundation, contouring, and styling.',
      price: 5500, durationMinutes: 90, isVisible: true,
    ),
    ProviderService(
      id: 's2', name: 'Signature Hair Styling',
      description: 'Professional blow-dry and styling for any occasion.',
      price: 3000, durationMinutes: 45, isVisible: true,
    ),
    ProviderService(
      id: 's3', name: 'Deep Cleansing Facial',
      description: 'Purifying facial treatment with extraction and mask.',
      price: 4200, durationMinutes: 60, isDraft: true,
    ),
    ProviderService(
      id: 's4', name: 'Bridal Trial Package',
      description: 'Full bridal look trial with consultation and adjustments.',
      price: 8000, durationMinutes: 120, isVisible: true,
    ),
  ];

  List<DaySchedule> _schedule = [
    DaySchedule(day: 'Monday',    letter: 'M', isOpen: true,  blocks: [TimeBlock(startTime: '09:00 AM', endTime: '12:00 PM'), TimeBlock(startTime: '02:00 PM', endTime: '06:00 PM')]),
    DaySchedule(day: 'Tuesday',   letter: 'T', isOpen: true,  blocks: [TimeBlock(startTime: '09:00 AM', endTime: '01:00 PM'), TimeBlock(startTime: '03:00 PM', endTime: '06:00 PM')]),
    DaySchedule(day: 'Wednesday', letter: 'W', isOpen: false, blocks: [TimeBlock(startTime: '09:00 AM', endTime: '05:00 PM')]),
    DaySchedule(day: 'Thursday',  letter: 'T', isOpen: true,  blocks: [TimeBlock(startTime: '10:00 AM', endTime: '04:00 PM')]),
    DaySchedule(day: 'Friday',    letter: 'F', isOpen: true,  blocks: [TimeBlock(startTime: '09:00 AM', endTime: '12:00 PM'), TimeBlock(startTime: '01:30 PM', endTime: '06:00 PM')]),
    DaySchedule(day: 'Saturday',  letter: 'S', isOpen: false, blocks: [TimeBlock(startTime: '10:00 AM', endTime: '03:00 PM')]),
    DaySchedule(day: 'Sunday',    letter: 'S', isOpen: false, blocks: [TimeBlock(startTime: '10:00 AM', endTime: '03:00 PM')]),
  ];

  final ProviderStats stats = const ProviderStats(
    todayBookings: 12, earnings: 1400, rating: 4.95,
    totalReviews: 2000, earningsChangePercent: 12, todayChange: 3,
  );

  bool _vacationMode        = false;
  bool _notificationsEnabled = true;

  bool get vacationMode         => _vacationMode;
  bool get notificationsEnabled => _notificationsEnabled;

  // ── Getters ──────────────────────────────────────────────────

  /// Confirmed bookings whose end time is still in the future.
  List<ProviderBooking> get upcomingBookings {
    _resolveNoShows();
    return _bookings
        .where((b) => b.status == ProviderBookingStatus.upcoming)
        .toList();
  }

  /// Bookings the provider marked as complete.
  List<ProviderBooking> get completedBookings {
    _resolveNoShows();
    return _bookings
        .where((b) => b.status == ProviderBookingStatus.completed)
        .toList()
      ..sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
  }

  /// Bookings cancelled by the provider OR auto-cancelled as no-shows.
  List<ProviderBooking> get cancelledBookings {
    _resolveNoShows();
    return _bookings
        .where((b) => b.status == ProviderBookingStatus.cancelled)
        .toList()
      ..sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
  }

  /// Legacy — kept empty so old call-sites don't break.
  List<ProviderBooking> get pendingBookings => const [];

  /// Legacy alias used by home screen.
  List<ProviderBooking> get pastBookings => completedBookings;

  List<ProviderService> get services => List.unmodifiable(_services);
  List<DaySchedule>     get schedule => List.unmodifiable(_schedule);

  // ── No-show auto-resolution ──────────────────────────────────
  /// Scans _bookings and flips any upcoming booking whose end time
  /// has already passed into cancelled/noShow — in-memory only.
  /// Called lazily from every getter so it always reflects real time.
  void _resolveNoShows() {
    for (int i = 0; i < _bookings.length; i++) {
      final b = _bookings[i];
      if (b.isNoShow) {
        _bookings[i] = b.copyWith(
          status:       ProviderBookingStatus.cancelled,
          cancelReason: CancelReason.noShow,
        );
      }
    }
    // We intentionally do NOT call notifyListeners() here to avoid
    // infinite rebuild loops; the UI will pick up the state change
    // on the next natural rebuild cycle.
  }

  // ── Schedule lookup ──────────────────────────────────────────

  DaySchedule? scheduleForDate(DateTime date) {
    final idx = date.weekday - 1;
    if (idx < 0 || idx >= _schedule.length) return null;
    final ds = _schedule[idx];
    return ds.isOpen ? ds : null;
  }

  bool isSlotAvailable(DateTime date, String timeStr) {
    final ds = scheduleForDate(date);
    if (ds == null) return false;
    return ds.isTimeAvailable(timeStr);
  }

  // ── Booking actions ──────────────────────────────────────────

  void addBookingFromClient({
    required String   id,
    required String   clientName,
    required String   serviceName,
    required String   timeSlot,
    required DateTime bookingDate,
    required double   price,
    String?           notes,
  }) {
    _bookings.add(ProviderBooking.fromClientBooking(
      id:          id,
      clientName:  clientName,
      serviceName: serviceName,
      timeSlot:    timeSlot,
      bookingDate: bookingDate,
      price:       price,
      notes:       notes,
    ));
    notifyListeners();
  }

  Future<void> completeBooking(String id) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final idx = _bookings.indexWhere((b) => b.id == id);
    if (idx != -1) {
      _bookings[idx] = _bookings[idx].copyWith(
        status: ProviderBookingStatus.completed,
      );
      notifyListeners();
    }
  }

  Future<void> cancelBooking(String id) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final idx = _bookings.indexWhere((b) => b.id == id);
    if (idx != -1) {
      _bookings[idx] = _bookings[idx].copyWith(
        status:       ProviderBookingStatus.cancelled,
        cancelReason: CancelReason.byProvider,
      );
      notifyListeners();
    }
  }

  // ── Service actions ──────────────────────────────────────────

  void addService(ProviderService service) {
    _services.add(service);
    notifyListeners();
  }

  void updateService(ProviderService updated) {
    final idx = _services.indexWhere((s) => s.id == updated.id);
    if (idx != -1) { _services[idx] = updated; notifyListeners(); }
  }

  void deleteService(String id) {
    _services.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  // ── Schedule actions ─────────────────────────────────────────

  void updateDaySchedule(int index, DaySchedule updated) {
    _schedule[index] = updated;
    notifyListeners();
  }

  void addBlockToDay(int dayIndex) {
    final day      = _schedule[dayIndex];
    String newStart = '05:00 PM';
    String newEnd   = '06:00 PM';
    if (day.blocks.isNotEmpty) {
      newStart = day.blocks.last.endTime;
      newEnd   = _addHours(newStart, 1);
    }
    _schedule[dayIndex] = day.copyWith(blocks: [
      ...day.blocks,
      TimeBlock(startTime: newStart, endTime: newEnd),
    ]);
    notifyListeners();
  }

  void removeBlockFromDay(int dayIndex, int blockIndex) {
    final day  = _schedule[dayIndex];
    final newB = List<TimeBlock>.from(day.blocks)..removeAt(blockIndex);
    _schedule[dayIndex] = day.copyWith(
      blocks: newB.isNotEmpty
          ? newB
          : [const TimeBlock(startTime: '09:00 AM', endTime: '05:00 PM')],
    );
    notifyListeners();
  }

  void updateBlock(int dayIndex, int blockIndex, TimeBlock updated) {
    final day  = _schedule[dayIndex];
    final newB = List<TimeBlock>.from(day.blocks);
    newB[blockIndex]    = updated;
    _schedule[dayIndex] = day.copyWith(blocks: newB);
    notifyListeners();
  }

  Future<void> saveSchedule() async =>
      Future.delayed(const Duration(milliseconds: 800));

  // ── Settings ─────────────────────────────────────────────────

  void toggleVacationMode(bool value) {
    _vacationMode = value;
    notifyListeners();
  }

  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  // ── Helpers ──────────────────────────────────────────────────

  static String _addHours(String timeStr, int hours) {
    final parts  = timeStr.trim().split(' ');
    final hm     = parts[0].split(':');
    int hour     = int.parse(hm[0]);
    final minute = int.parse(hm[1]);
    final isPm   = parts.length > 1 && parts[1].toUpperCase() == 'PM';
    if (isPm  && hour != 12) hour += 12;
    if (!isPm && hour == 12) hour  = 0;
    hour = (hour + hours).clamp(0, 23);
    final period = hour >= 12 ? 'PM' : 'AM';
    final h12    = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final m      = minute.toString().padLeft(2, '0');
    return '$h12:$m $period';
  }
}