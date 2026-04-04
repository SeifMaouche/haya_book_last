import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../models/provider_model.dart';
import 'provider_state.dart'; // import so we can notify the provider side

class BookingProvider extends ChangeNotifier {
  List<Booking> _bookings = [];
  List<ServiceProvider> _providers = [];
  List<TimeSlot> _availableSlots = [];
  List<String> _favorites = [];
  ServiceProvider? _selectedProvider;
  Service? _selectedService;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  bool _isLoading = false;
  String? _error;

  // ── Getters ──────────────────────────────────────────────────
  List<Booking> get bookings => List.unmodifiable(_bookings);
  List<ServiceProvider> get providers => _providers;
  List<TimeSlot> get availableSlots => _availableSlots;
  List<String> get favorites => _favorites;
  ServiceProvider? get selectedProvider => _selectedProvider;
  Service? get selectedService => _selectedService;
  DateTime? get selectedDate => _selectedDate;
  String? get selectedTimeSlot => _selectedTimeSlot;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Booking? get lastBooking =>
      _bookings.isNotEmpty ? _bookings.last : null;

  // ── Filtered lists ───────────────────────────────────────────
  List<Booking> getUpcomingBookings() {
    final now = DateTime.now();
    return _bookings
        .where((b) => b.status != 'cancelled' && b.bookingDate.isAfter(now))
        .toList()
      ..sort((a, b) => a.bookingDate.compareTo(b.bookingDate));
  }

  List<Booking> getPastBookings() {
    final now = DateTime.now();
    return _bookings
        .where((b) => b.status != 'cancelled' && !b.bookingDate.isAfter(now))
        .toList()
      ..sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
  }

  List<Booking> getCancelledBookings() {
    return _bookings
        .where((b) => b.status == 'cancelled')
        .toList()
      ..sort((a, b) => (b.cancelledAt ?? b.createdAt)
          .compareTo(a.cancelledAt ?? a.createdAt));
  }

  // ── Providers ────────────────────────────────────────────────
  Future<void> fetchProviders(
      {String? category, String? searchQuery}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 600));

      _providers = [
        ServiceProvider(
          id: '1',
          name: 'Dr. Jhon Johnson',
          category: 'Clinic',
          imageUrl: 'assets/images/doc.png',
          rating: 4.8,
          reviewCount: 127,
          location: '123 Health St, Algiers',
          distance: 0.5,
          phone: '+213 555 0101',
          email: 'Jhon@clinic.com',
          bio: 'Experienced family physician with 10 years of practice.',
          services: ['Consultation', 'Check-up', 'Vaccination'],
          workingHours: [
            WorkingHours(day: 'Monday',    startTime: '09:00', endTime: '17:00', isOpen: true),
            WorkingHours(day: 'Tuesday',   startTime: '09:00', endTime: '17:00', isOpen: true),
            WorkingHours(day: 'Wednesday', startTime: '09:00', endTime: '17:00', isOpen: true),
            WorkingHours(day: 'Thursday',  startTime: '09:00', endTime: '17:00', isOpen: true),
            WorkingHours(day: 'Friday',    startTime: '09:00', endTime: '13:00', isOpen: true),
            WorkingHours(day: 'Saturday',  startTime: '',      endTime: '',      isOpen: false),
            WorkingHours(day: 'Sunday',    startTime: '',      endTime: '',      isOpen: false),
          ],
          isVerified: true,
          averagePrice: 5000.0,
        ),
        ServiceProvider(
          id: '2',
          name: "Bella's Beauty Salon",
          category: 'Salon',
          imageUrl: 'assets/images/salon.png',
          rating: 4.6,
          reviewCount: 89,
          location: '456 Style Ave, Algiers',
          distance: 1.2,
          phone: '+213 555 0202',
          email: 'info@bellas.com',
          bio: 'Premium beauty and hair salon with certified stylists.',
          services: ['Hair Cut', 'Hair Coloring', 'Facial', 'Manicure'],
          workingHours: [
            WorkingHours(day: 'Monday',    startTime: '10:00', endTime: '18:00', isOpen: true),
            WorkingHours(day: 'Tuesday',   startTime: '10:00', endTime: '18:00', isOpen: true),
            WorkingHours(day: 'Wednesday', startTime: '10:00', endTime: '18:00', isOpen: true),
            WorkingHours(day: 'Thursday',  startTime: '10:00', endTime: '18:00', isOpen: true),
            WorkingHours(day: 'Friday',    startTime: '10:00', endTime: '18:00', isOpen: true),
            WorkingHours(day: 'Saturday',  startTime: '10:00', endTime: '16:00', isOpen: true),
            WorkingHours(day: 'Sunday',    startTime: '',      endTime: '',      isOpen: false),
          ],
          isVerified: true,
          averagePrice: 3500.0,
        ),
        ServiceProvider(
          id: '3',
          name: 'Prof. James Tutoring',
          category: 'Tutor',
          imageUrl: 'assets/images/tutop.png',
          rating: 4.9,
          reviewCount: 156,
          location: '789 Education Rd, Algiers',
          distance: 2.1,
          phone: '+213 555 0303',
          email: 'james@tutoring.com',
          bio: 'Expert in mathematics and physics tutoring for all levels.',
          services: ['Math Tutoring', 'Physics Tutoring', 'Test Prep'],
          workingHours: [
            WorkingHours(day: 'Monday',    startTime: '14:00', endTime: '20:00', isOpen: true),
            WorkingHours(day: 'Tuesday',   startTime: '14:00', endTime: '20:00', isOpen: true),
            WorkingHours(day: 'Wednesday', startTime: '14:00', endTime: '20:00', isOpen: true),
            WorkingHours(day: 'Thursday',  startTime: '14:00', endTime: '20:00', isOpen: true),
            WorkingHours(day: 'Friday',    startTime: '14:00', endTime: '18:00', isOpen: true),
            WorkingHours(day: 'Saturday',  startTime: '10:00', endTime: '14:00', isOpen: true),
            WorkingHours(day: 'Sunday',    startTime: '',      endTime: '',      isOpen: false),
          ],
          isVerified: true,
          averagePrice: 2000.0,
        ),
      ];

      if (category != null) {
        _providers =
            _providers.where((p) => p.category == category).toList();
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        _providers = _providers
            .where((p) =>
        p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            p.category.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch providers: $e';
      _isLoading = false;
      notifyListeners();
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
    _isLoading = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      _availableSlots = _generateAvailableSlots();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch slots: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  List<TimeSlot> _generateAvailableSlots() {
    final now = DateTime.now();
    final sel = _selectedDate;
    if (sel == null) return [];

    final isToday = sel.year == now.year &&
        sel.month == now.month &&
        sel.day == now.day;

    final slots = <TimeSlot>[];
    DateTime t = DateTime(sel.year, sel.month, sel.day, 9, 0);
    final end = DateTime(sel.year, sel.month, sel.day, 17, 0);

    while (t.isBefore(end) || t.isAtSameMomentAs(end)) {
      bool available = !isToday ||
          t.isAfter(now.add(const Duration(minutes: 30)));
      if (t.hour == 10 && t.minute == 0) available = false;
      if (t.hour == 14 && t.minute == 30) available = false;
      slots.add(TimeSlot(time: _formatTime(t), isAvailable: available));
      t = t.add(const Duration(minutes: 30));
    }
    return slots;
  }

  String _formatTime(DateTime t) {
    final h = t.hour;
    final m = t.minute;
    final period = h >= 12 ? 'PM' : 'AM';
    final dh = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '${dh.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $period';
  }

  void selectTimeSlot(String timeSlot) {
    _selectedTimeSlot = timeSlot;
    notifyListeners();
  }

  // ── Create booking — AUTO-CONFIRMED ─────────────────────────
  /// Creates a booking with `status: 'confirmed'` immediately.
  /// Also registers it on the provider side via [providerState].
  Future<bool> createBooking(
      String notes, {
        ProviderStateProvider? providerState,
      }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_selectedProvider == null ||
          _selectedService == null ||
          _selectedDate == null ||
          _selectedTimeSlot == null) {
        throw Exception('Please select all required fields');
      }

      await Future.delayed(const Duration(milliseconds: 800));

      final bookingId =
          'BK${DateTime.now().year}${(DateTime.now().millisecondsSinceEpoch % 1000000).toString().padLeft(6, '0')}';

      final booking = Booking(
        id:           bookingId,
        userId:       'current_user_id',
        providerId:   _selectedProvider!.id,
        providerName: _selectedProvider!.name,
        serviceName:  _selectedService!.name,
        bookingDate:  _selectedDate!,
        timeSlot:     _selectedTimeSlot!,
        price:        _selectedService!.price,
        status:       'confirmed', // always confirmed — no pending
        notes:        notes,
        createdAt:    DateTime.now(),
      );

      _bookings.add(booking);

      // ── Sync to provider side (auto-confirm) ──────────────────
      providerState?.addBookingFromClient(
        id:          bookingId,
        clientName:  'Client', // replace with real user name when auth is wired
        serviceName: _selectedService!.name,
        timeSlot:    _selectedTimeSlot!,
        bookingDate: _selectedDate!,
        price:       _selectedService!.price,
        notes:       notes.isNotEmpty ? notes : null,
      );

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
    try {
      final i = _bookings.indexWhere((b) => b.id == bookingId);
      if (i != -1) {
        final b = _bookings[i];
        _bookings[i] = Booking(
          id:          b.id,
          userId:      b.userId,
          providerId:  b.providerId,
          providerName: b.providerName,
          serviceName: b.serviceName,
          bookingDate: b.bookingDate,
          timeSlot:    b.timeSlot,
          price:       b.price,
          status:      'cancelled',
          notes:       b.notes,
          createdAt:   b.createdAt,
          cancelledAt: DateTime.now(),
        );
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to cancel: $e';
      notifyListeners();
      return false;
    }
  }

  // ── Reschedule booking ───────────────────────────────────────
  Future<bool> rescheduleBooking(
      String bookingId, DateTime newDate, String newTimeSlot) async {
    try {
      final i = _bookings.indexWhere((b) => b.id == bookingId);
      if (i != -1) {
        final b = _bookings[i];
        _bookings[i] = Booking(
          id:          b.id,
          userId:      b.userId,
          providerId:  b.providerId,
          providerName: b.providerName,
          serviceName: b.serviceName,
          bookingDate: newDate,
          timeSlot:    newTimeSlot,
          price:       b.price,
          status:      'confirmed',
          notes:       b.notes,
          createdAt:   b.createdAt,
        );
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to reschedule: $e';
      notifyListeners();
      return false;
    }
  }

  // ── Favorites ────────────────────────────────────────────────
  void toggleFavorite(String providerId) {
    if (_favorites.contains(providerId)) {
      _favorites.remove(providerId);
    } else {
      _favorites.add(providerId);
    }
    notifyListeners();
  }

  bool isFavorite(String providerId) => _favorites.contains(providerId);

  List<ServiceProvider> getFavoriteProviders() {
    return _providers
        .where((provider) => _favorites.contains(provider.id))
        .toList();
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
    await Future.delayed(const Duration(milliseconds: 300));
    _isLoading = false;
    notifyListeners();
  }
}