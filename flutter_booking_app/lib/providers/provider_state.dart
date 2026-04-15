// lib/providers/provider_state.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ FIX F8/F9
import '../models/provider_models.dart';
import '../models/provider_model.dart' as model;
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../services/provider_service.dart' as service;
import '../services/socket_service.dart';

class ProviderStateProvider extends ChangeNotifier {
  final _bookingService  = BookingService();
  final _providerService = service.ProviderService();

  List<ProviderBooking> _bookings = [];
  List<ProviderService> _services = []; // Model Service
  List<DaySchedule>     _schedule = [];
  ProviderStats         _stats    = const ProviderStats(
    todayBookings: 0,
    earnings: 0,
    rating: 0,
    totalReviews: 0,
    earningsChangePercent: 0,
    todayChange: 0,
  );
  bool                  _isLoading = false;
  String?               _error;
  model.ServiceProvider? _profile;

  bool _vacationMode         = false;
  bool _notificationsEnabled = true;

  // ── Getters ──────────────────────────────────────────────────
  bool    get isLoading            => _isLoading;
  String? get error                => _error;
  bool    get vacationMode         => _vacationMode;
  bool    get notificationsEnabled => _notificationsEnabled;
  ProviderStats get stats          => _stats;
  model.ServiceProvider? get profile => _profile;
  
  List<ProviderService> get services => List.unmodifiable(_services);
  List<DaySchedule>     get schedule => List.unmodifiable(_schedule);

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

  // ── State Reset ──────────────────────────────────────────────
  void clear() {
    _bookings = [];
    _services = [];
    _schedule = [];
    _stats = const ProviderStats(
      todayBookings: 0,
      earnings: 0,
      rating: 0,
      totalReviews: 0,
      earningsChangePercent: 0,
      todayChange: 0,
    );
    _profile = null;
    _error = null;
    _isLoading = false;
  }

  // ── Initialization ───────────────────────────────────────────

  void initSocket() async {
    socketService.init();
    final socket = socketService.socket;
    if (socket == null) return;

    socket.off('booking_update');
    socket.on('booking_update', (data) {
      debugPrint('--- [Socket.io] ProviderState: Booking Update Received ---');
      loadInitialData(); // Refresh all stats and bookings
    });
  }

  Future<void> loadInitialData() async {
    // ✅ Hard reset to prevent memory leakage between sessions
    clear();
    
    // ✅ FIX F9: Load persisted settings before fetching data
    await _loadSettings();
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      // ── Robust Parallel Fetch ───────────────────────────────────
      final results = await Future.wait([
        _bookingService.getProviderBookings().catchError((e) {
          debugPrint('Sync Error (Bookings): $e');
          return <Booking>[];
        }),
        _providerService.getProviderStats().catchError((e) {
          debugPrint('Sync Error (Stats): $e');
          return <String, dynamic>{}; // Return empty map instead of null
        }),
        _providerService.getAvailability().catchError((e) {
          debugPrint('Sync Error (Availability): $e');
          return <dynamic>[]; // Return empty list instead of null
        }),
        () async {
          try {
            return await _providerService.getCurrentProviderProfile();
          } catch (e) {
            debugPrint('Sync Error (Profile): $e');
            return null;
          }
        }(),
      ]);

      final clientBookings = (results[0] as List?)?.cast<Booking>() ?? [];
      final providerStats  = results[1];
      final availability   = results[2];
      final profileData    = results[3];

      if (profileData != null) {
        _profile = profileData as model.ServiceProvider;
      }

      // ─────────────────────────────────────────────────────────────
      // 1. Map Client Bookings -> ProviderBookings (Robust Mapping)
      // ─────────────────────────────────────────────────────────────
      _bookings = clientBookings.map<ProviderBooking>((b) {
        final statusStr = b.status.toUpperCase();
        
        ProviderBookingStatus calculatedStatus;
        if (statusStr == 'COMPLETED') {
          calculatedStatus = ProviderBookingStatus.completed;
        } else if (statusStr.contains('CANCELLED') || 
                   statusStr.contains('CANCELED') || 
                   statusStr.contains('NO_SHOW')) {
          calculatedStatus = ProviderBookingStatus.cancelled;
        } else if (statusStr == 'PENDING' || statusStr == 'CONFIRMED' || statusStr == 'WAITING' || statusStr == 'APPROVED') {
          calculatedStatus = ProviderBookingStatus.upcoming;
        } else {
          // Default to upcoming for any unhandled active statuses
          calculatedStatus = ProviderBookingStatus.upcoming;
        }

        CancelReason? reason;
        if (statusStr == 'CANCELLED_BY_CLIENT') {
          reason = CancelReason.byClient;
        } else if (statusStr == 'CANCELLED_BY_PROVIDER') {
          reason = CancelReason.byProvider;
        } else if (statusStr.contains('NO_SHOW')) {
          reason = CancelReason.noShow;
        }

        return ProviderBooking.fromClientBooking(
          id:           b.id,
          clientName:   b.clientName,
          clientId:     b.userId,
          clientAvatar: b.clientAvatar,
          serviceName:  b.serviceName,
          bookingDate:  b.bookingDate,
          timeSlot:     b.timeSlot,
          price:        b.price,
          status:       calculatedStatus,
          cancelReason: reason,
          notes:        b.notes,
        );
      }).toList();

      // ─────────────────────────────────────────────────────────────
      // 2. Refresh Stats
      // ─────────────────────────────────────────────────────────────
      if (providerStats != null) {
        final statsMap = providerStats as Map<String, dynamic>;
        _stats = ProviderStats(
          todayBookings:         statsMap['todayBookings'] ?? 0,
          earnings:              (statsMap['totalEarnings'] as num?)?.toDouble() ?? 0.0,
          earningsChangePercent: (statsMap['earningsChangePercent'] as num?)?.toDouble() ?? 0.0,
          rating:                (statsMap['rating'] as num?)?.toDouble() ?? 0.0,
          totalReviews:          statsMap['totalReviews'] ?? 0,
          todayChange:           (statsMap['todayChange'] as num?)?.toInt() ?? 0,
        );
      } else {
         _stats = ProviderStats(
          todayBookings: 0, 
          earnings: 0.0, earningsChangePercent: 0.0, 
          rating: 0.0, totalReviews: 0,
          todayChange: 0,
         );
      }

      // ─────────────────────────────────────────────────────────────
      // 3. Map Availability & Profile
      // ─────────────────────────────────────────────────────────────
      if (availability != null) {
        _schedule = (availability as List).map((e) => DaySchedule.fromJson(e)).toList();
      } else {
        _schedule = _generateDefaultSchedule();
      }

      if (profileData != null) {
        final p = profileData as model.ServiceProvider;
        _profile = p;
        
        // Update local services list from profile
        _services = p.services.map((s) => ProviderService(
          id:              s.id,
          name:            s.name,
          description:     s.description,
          price:           s.price,
          durationMinutes: s.durationMinutes,
          isVisible:       !s.isDraft,
          isDraft:         s.isDraft,
        )).toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load provider dashboard: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('--- [ProviderState] Critical Load Error: $e ---');
    }
  }

  List<DaySchedule> _generateDefaultSchedule() {
    return [
      DaySchedule(day: 'Monday',    letter: 'M', isOpen: true,  blocks: [const TimeBlock(startTime: '09:00', endTime: '17:00')]),
      DaySchedule(day: 'Tuesday',   letter: 'T', isOpen: true,  blocks: [const TimeBlock(startTime: '09:00', endTime: '17:00')]),
      DaySchedule(day: 'Wednesday', letter: 'W', isOpen: true,  blocks: [const TimeBlock(startTime: '09:00', endTime: '17:00')]),
      DaySchedule(day: 'Thursday',  letter: 'T', isOpen: true,  blocks: [const TimeBlock(startTime: '09:00', endTime: '17:00')]),
      DaySchedule(day: 'Friday',    letter: 'F', isOpen: true,  blocks: [const TimeBlock(startTime: '09:00', endTime: '17:00')]),
      DaySchedule(day: 'Saturday',  letter: 'S', isOpen: false, blocks: [const TimeBlock(startTime: '10:00', endTime: '15:00')]),
      DaySchedule(day: 'Sunday',    letter: 'S', isOpen: false, blocks: [const TimeBlock(startTime: '10:00', endTime: '15:00')]),
    ];
  }

  // ── No-show auto-resolution ──────────────────────────────────
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

  Future<void> completeBooking(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _bookingService.updateStatus(id, 'COMPLETED');
      if (success) {
        final idx = _bookings.indexWhere((b) => b.id == id);
        if (idx != -1) {
          _bookings[idx] = _bookings[idx].copyWith(status: ProviderBookingStatus.completed);
        }
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelBooking(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _bookingService.updateStatus(id, 'CANCELLED_BY_PROVIDER');
      if (success) {
        final idx = _bookings.indexWhere((b) => b.id == id);
        if (idx != -1) {
          _bookings[idx] = _bookings[idx].copyWith(
            status: ProviderBookingStatus.cancelled,
            cancelReason: CancelReason.byProvider,
          );
        }
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Service actions ──────────────────────────────────────────

  Future<bool> addService(String name, String desc, double price, int duration) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _providerService.addService(name: name, description: desc, price: price, durationMinutes: duration);
      // Safety delay for backend indexing sync
      await Future.delayed(const Duration(milliseconds: 600));
      await loadInitialData();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateService(String id, String name, String desc, double price, int duration) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _providerService.updateService(id, name: name, description: desc, price: price, durationMinutes: duration);
      // Safety delay for backend indexing sync
      await Future.delayed(const Duration(milliseconds: 600));
      await loadInitialData();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteService(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _providerService.deleteService(id);
      // Safety delay for backend indexing sync
      await Future.delayed(const Duration(milliseconds: 600));
      await loadInitialData();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Schedule actions ─────────────────────────────────────────

  void updateDaySchedule(int index, DaySchedule updated) {
    _schedule[index] = updated;
    notifyListeners();
  }

  void addBlockToDay(int dayIndex) {
    final day      = _schedule[dayIndex];
    String newStart = '17:00';
    String newEnd   = '18:00';
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
          : [const TimeBlock(startTime: '09:00', endTime: '17:00')],
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

  Future<void> saveSchedule() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _providerService.saveAvailability(_schedule);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Settings ─────────────────────────────────────────────────

  // ✅ FIX F8/F9: SharedPreferences keys for persistent provider settings
  static const _kVacationMode         = 'provider_vacationMode';
  static const _kNotificationsEnabled = 'provider_notificationsEnabled';

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _vacationMode         = prefs.getBool(_kVacationMode)         ?? false;
    _notificationsEnabled = prefs.getBool(_kNotificationsEnabled) ?? true;
    notifyListeners();
  }

  void toggleVacationMode(bool value) async {
    _vacationMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kVacationMode, value);
  }

  void toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotificationsEnabled, value);
  }

  // ── Helpers ──────────────────────────────────────────────────

  static String _addHours(String timeStr, int hours) {
    final lower = timeStr.toLowerCase().trim();
    final parts = lower.split(' ');
    final hm    = parts[0].split(':');
    int hour    = int.parse(hm[0]);
    final minute = int.parse(hm[1]);
    
    // Support AM/PM for transition compatibility
    if (lower.contains('pm') && hour != 12) hour += 12;
    if (lower.contains('am') && hour == 12) hour = 0;
    
    hour = (hour + hours).clamp(0, 23);
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}