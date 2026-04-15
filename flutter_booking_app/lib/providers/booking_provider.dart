import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this import
import '../models/booking_model.dart';
import '../models/provider_model.dart';
import '../models/provider_models.dart'; // Add this import
import '../models/category_model.dart' as cat;
import '../services/provider_service.dart' as service;
import '../services/booking_service.dart';
import '../services/socket_service.dart';
import 'provider_state.dart';

class BookingProvider extends ChangeNotifier {
  final _providerService = service.ProviderService();
  final _bookingService  = BookingService();

  List<Booking> _bookings = [];
  List<ServiceProvider> _providers = [];
  List<cat.Category> _categories = [];
  List<TimeSlot> _availableSlots = [];
  ServiceProvider? _selectedProvider;
  Service? _selectedService;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  bool _isLoading = false;
  String? _error;
  
  // ── Sync & State state ─────────────────────────────────────────
  int _lastRequestId = 0;
  String? _currentCategory;
  String? _currentSearchQuery;

  // ── Getters ──────────────────────────────────────────────────
  List<Booking> get bookings => List.unmodifiable(_bookings);
  List<ServiceProvider> get providers => _providers;
  List<cat.Category> get categories => _categories;
  List<TimeSlot> get availableSlots => _availableSlots;
  ServiceProvider? get selectedProvider => _selectedProvider;
  Service? get selectedService => _selectedService;
  DateTime? get selectedDate => _selectedDate;
  String? get selectedTimeSlot => _selectedTimeSlot;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentCategory => _currentCategory;
  String? get currentSearchQuery => _currentSearchQuery;

  // ── Sync ──────────────────────────────────────────────────
  void initSocket() async {
    socketService.init();
    final socket = socketService.socket;
    if (socket == null) return;

    socket.off('booking_update');
    socket.on('booking_update', (data) {
      debugPrint('--- [Socket.io] BookingProvider: Booking Update Received ---');
      fetchUserBookings();
      // If we are looking at a specific provider's slots, refresh them
      if (_selectedProvider != null && _selectedDate != null) {
        _fetchAvailableSlots();
      }
    });

    socket.off('notification_received');
    socket.on('notification_received', (data) {
      debugPrint('--- [Socket.io] Notification Received: $data ---');
      // Potential to show a top snackbar or badge
    });
  }

  Booking? get lastBooking =>
      _bookings.isNotEmpty ? _bookings.last : null;

  // ── Filtered lists ───────────────────────────────────────────
  List<Booking> getUpcomingBookings() {
    final now = DateTime.now();
    return _bookings
        .where((b) {
          final isCancelled = b.status.toLowerCase().contains('cancelled');
          final isInProgress = b.status.toUpperCase() == 'IN_PROGRESS';
          
          if (isCancelled) return false;
          // Show if its full start time is in the future OR if it's currently IN_PROGRESS
          // Also show if it's within the past hour (so users can still see it right as it starts)
          return b.fullStartDateTime.isAfter(now.subtract(const Duration(minutes: 5))) || isInProgress;
        })
        .toList()
      ..sort((a, b) => a.fullStartDateTime.compareTo(b.fullStartDateTime));
  }

  List<Booking> getPastBookings() {
    final now = DateTime.now();
    return _bookings
        .where((b) {
          final isCancelled = b.status.toLowerCase().contains('cancelled');
          final isInProgress = b.status.toUpperCase() == 'IN_PROGRESS';
          // It's upcoming if its start time is still in the future (or recently started)
          final isUpcoming = b.fullStartDateTime.isAfter(now.subtract(const Duration(minutes: 5)));
          
          // It's past if it's not cancelled, not in progress, and not upcoming
          return !isCancelled && !isInProgress && !isUpcoming;
        })
        .toList()
      ..sort((a, b) => b.fullStartDateTime.compareTo(a.fullStartDateTime));
  }

  List<Booking> getCancelledBookings() {
    return _bookings
        .where((b) => b.status.toLowerCase().contains('cancelled'))
        .toList()
      ..sort((a, b) => (b.cancelledAt ?? b.createdAt)
          .compareTo(a.cancelledAt ?? a.createdAt));
  }

  // ── Providers ────────────────────────────────────────────────
  Future<void> fetchProviders({
    String? category,
    String? searchQuery,
    double? minRating,
    double? maxPrice,
    String? sortBy,
    double? lat,
    double? lng,
    int? maxDistanceKm,
  }) async {
    final requestId = ++_lastRequestId;
    _isLoading = true;
    _error = null;
    _currentCategory = category;
    _currentSearchQuery = searchQuery;
    notifyListeners();

    try {
      if (_categories.isEmpty) {
        await fetchCategories();
      }

      // All filtering is now done server-side — no client-side filtering needed
      final allProviders = await _providerService.getAllProviders(
        category:       category,
        minRating:      minRating,
        maxPrice:       maxPrice,
        sortBy:         sortBy,
        lat:            lat,
        lng:            lng,
        maxDistanceKm:  maxDistanceKm,
      );

      // STALE CHECK
      if (requestId != _lastRequestId) return;

      _providers = allProviders;

      // Client-side search query filter (name/category text match)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        _providers = _providers.where((p) =>
          p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          p.category.toLowerCase().contains(searchQuery.toLowerCase())
        ).toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (requestId != _lastRequestId) return;
      _error = 'Failed to fetch providers: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCategories() async {
    try {
      _categories = await _providerService.getPublicCategories();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  // ── Selection ────────────────────────────────────────────────
  void selectProvider(ServiceProvider provider) {
    _selectedProvider = provider;
    _selectedService = null;
    _selectedDate = null;
    _selectedTimeSlot = null;
    notifyListeners();
  }

  void selectService(Service service) {
    _selectedService = service;
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    _selectedTimeSlot = null;
    _fetchAvailableSlots();
  }

  Future<void> _fetchAvailableSlots() async {
    if (_selectedProvider == null || _selectedDate == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final dateStr = _selectedDate!.toIso8601String().split('T')[0];
      final booked = await _bookingService.getBookedSlots(
        providerId: _selectedProvider!.id,
        date: dateStr,
      );

      // Expand booked windows into 30m busy chunks
      final busyChunks = <String>[];
      for (var b in booked) {
        final startStr = b['startTime']!;
        final endStr   = b['endTime']!;
        
        DateTime start = _parseTime(_selectedDate!, startStr);
        DateTime end   = _parseTime(_selectedDate!, endStr);
        
        DateTime curr = start;
        while (curr.isBefore(end)) {
          busyChunks.add(_formatTime(curr));
          curr = curr.add(const Duration(minutes: 30));
        }
      }

      _availableSlots = _generateAvailableSlots(busyChunks);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch slots: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  List<TimeSlot> _generateAvailableSlots(List<String> busyChunks) {
    if (_selectedProvider == null || _selectedDate == null || _selectedService == null) return [];
    
    final sel = _selectedDate!;
    final now = DateTime.now();
    final isToday = sel.year == now.year && sel.month == now.month && sel.day == now.day;

    final dayName = DateFormat('EEEE').format(sel);
    final schedule = _selectedProvider!.workingHours.firstWhere(
      (h) => h.day.toLowerCase() == dayName.toLowerCase(),
      orElse: () => DaySchedule(day: dayName, letter: dayName[0], isOpen: false, blocks: []),
    );

    if (!schedule.isOpen) return [];

    final slots = <TimeSlot>[];
    final serviceDuration = _selectedService!.durationMinutes;
    final chunksNeeded = (serviceDuration / 30).ceil();
    
    for (var block in schedule.blocks) {
      DateTime blockStart = _parseTime(sel, block.startTime);
      DateTime blockEnd   = _parseTime(sel, block.endTime);

      DateTime t = blockStart;
      while (t.add(Duration(minutes: serviceDuration)).isBefore(blockEnd.add(const Duration(minutes: 1)))) {
        final timeStr = _formatTime(t);
        
        // 1. Check if in past
        bool available = !isToday || t.isAfter(now.add(const Duration(minutes: 15)));
        
        // 2. Check all chunks needed for this service duration
        if (available) {
          for (int i = 0; i < chunksNeeded; i++) {
            final chunkTime = _formatTime(t.add(Duration(minutes: i * 30)));
            if (busyChunks.contains(chunkTime)) {
              available = false;
              break;
            }
          }
        }

        if (available) {
          slots.add(TimeSlot(time: timeStr, isAvailable: true));
        }
        
        // Move by 30 mins to allow picking any 30m starting boundary
        t = t.add(const Duration(minutes: 30));
      }
    }
    
    return slots;
  }

  DateTime _parseTime(DateTime date, String timeStr) {
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
      debugPrint('Error parsing time "$timeStr": $e');
      // Fallback to start of day if parsing fails
      return DateTime(date.year, date.month, date.day, 0, 0);
    }
  }

  String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void selectTimeSlot(String timeSlot) {
    _selectedTimeSlot = timeSlot;
    notifyListeners();
  }

  // ── Create booking — AUTO-CONFIRMED ─────────────────────────
  /// Creates a booking with `status: 'confirmed'` immediately.
  /// Also registers it on the provider side via [providerState].
  Future<bool> createBooking(String notes, {ProviderStateProvider? providerState}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_selectedProvider == null || _selectedService == null || _selectedDate == null || _selectedTimeSlot == null) {
        throw Exception('Please select all required fields');
      }

      final dateStr = _selectedDate!.toIso8601String().split('T')[0];

      final booking = await _bookingService.createBooking(
        providerProfileId: _selectedProvider!.id,
        serviceId:         _selectedService!.id,
        date:              dateStr,
        startTime:         _selectedTimeSlot!,
        notes:             notes,
      );

      _bookings.add(booking);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to create booking: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Cancel booking ───────────────────────────────────────────
  Future<bool> cancelBooking(String bookingId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _bookingService.cancelBooking(bookingId);
      if (success) {
        await fetchUserBookings(); // Refresh list to get updated status
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to cancel: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Reschedule booking ───────────────────────────────────────
  Future<bool> rescheduleBooking(
      String bookingId, DateTime newDate, String newTimeSlot) async {
    _isLoading = true;
    notifyListeners();
    try {
      final dateStr = newDate.toIso8601String().split('T')[0];
      final success = await _bookingService.rescheduleBooking(bookingId, dateStr, newTimeSlot);
      if (success) {
        await fetchUserBookings(); // Refresh list to get updated status
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to reschedule: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Reset & Fetch ────────────────────────────────────────────
  void resetBookingSelection() {
    _selectedProvider = null;
    _selectedService  = null;
    _selectedDate     = null;
    _selectedTimeSlot = null;
    _availableSlots   = [];
    notifyListeners();
  }

  Future<void> fetchUserBookings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _bookings = await _bookingService.getUserBookings();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}

// ✅ FIX F6: Removed duplicate TimeSlot class — canonical definition is in models/booking_model.dart