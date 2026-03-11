import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/booking.dart';

final bookingProvider = StateNotifierProvider<BookingNotifier, List<Booking>>((ref) {
  return BookingNotifier();
});

final upcomingBookingsProvider = Provider<List<Booking>>((ref) {
  final bookings = ref.watch(bookingProvider);
  final now = DateTime.now();
  return bookings
      .where((b) => b.dateTime.isAfter(now) && b.status == 'upcoming')
      .toList()
    ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
});

final myBookingsProvider = Provider<List<Booking>>((ref) {
  final bookings = ref.watch(bookingProvider);
  return bookings.toList()..sort((a, b) => b.dateTime.compareTo(a.dateTime));
});

class BookingNotifier extends StateNotifier<List<Booking>> {
  BookingNotifier() : super([]) {
    _initializeBookings();
  }

  Future<void> _initializeBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final bookingsJson = prefs.getStringList('bookings') ?? [];
    
    state = bookingsJson
        .map((json) => Booking.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> addBooking(Booking booking) async {
    state = [...state, booking];
    await _saveBookings();
  }

  Future<void> updateBooking(String bookingId, Booking updatedBooking) async {
    state = state.map((b) => b.id == bookingId ? updatedBooking : b).toList();
    await _saveBookings();
  }

  Future<void> cancelBooking(String bookingId) async {
    state = state.map((b) {
      if (b.id == bookingId) {
        return b.copyWith(status: 'cancelled');
      }
      return b;
    }).toList();
    await _saveBookings();
  }

  Future<void> rescheduleBooking(String bookingId, DateTime newDateTime) async {
    state = state.map((b) {
      if (b.id == bookingId) {
        return b.copyWith(dateTime: newDateTime);
      }
      return b;
    }).toList();
    await _saveBookings();
  }

  Future<void> deleteBooking(String bookingId) async {
    state = state.where((b) => b.id != bookingId).toList();
    await _saveBookings();
  }

  Future<void> _saveBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final bookingsJson = state
        .map((booking) => jsonEncode(booking.toJson()))
        .toList();
    await prefs.setStringList('bookings', bookingsJson);
  }
}
