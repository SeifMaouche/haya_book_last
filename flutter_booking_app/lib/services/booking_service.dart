// lib/services/booking_service.dart
import 'package:dio/dio.dart';
import './api_client.dart';
import '../models/booking_model.dart';

class BookingService {
  final Dio _dio = apiClient.dio;

  // ── Client bookings ──────────────────────────────────────────────
  Future<List<Booking>> getUserBookings() async {
    try {
      final response = await _dio.get('/bookings/client');
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) {
          // Flatten nested objects for fromJson compatibility
          final provider = json['providerProfile'] ?? {};
          final user     = provider['user'] ?? {};
          final service  = json['service'] ?? {};
          
          final map = Map<String, dynamic>.from(json);
          map['providerName']   = provider['businessName'] ?? 'Provider';
          map['providerAvatar'] = user['profileImage'] ?? '';
          map['serviceName']    = service['name'] ?? 'Service';
          map['bookingDate']    = json['date'];
          map['timeSlot']       = json['startTime'];
          
          return Booking.fromJson(map);
        }).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  // ── Create booking ───────────────────────────────────────────────
  Future<Booking> createBooking({
    required String providerProfileId,
    required String serviceId,
    String? serviceOptionId,
    required String date,
    required String startTime,
    String? notes,
  }) async {
    try {
      final response = await _dio.post('/bookings', data: {
        'providerProfileId': providerProfileId,
        'serviceId':         serviceId,
        if (serviceOptionId != null) 'serviceOptionId': serviceOptionId,
        'date':      date,
        'startTime': startTime,
        'notes':     notes,
      });

      if (response.statusCode == 201) {
        return Booking.fromJson(response.data);
      }
      throw Exception('Booking failed');
    } catch (e) {
      rethrow;
    }
  }

  // ── Update booking status ────────────────────────────────────────
  Future<bool> updateStatus(String bookingId, String status) async {
    try {
      final response = await _dio.patch('/bookings/$bookingId/status', data: {
        'status': status,
      });
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    return updateStatus(bookingId, 'CANCELLED_BY_CLIENT');
  }

  Future<bool> rescheduleBooking(String bookingId, String newDate, String newTime) async {
    try {
      final response = await _dio.patch('/bookings/$bookingId', data: {
        'date':      newDate,
        'startTime': newTime,
      });
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  // ── Provider bookings ────────────────────────────────────────────
  Future<List<Booking>> getProviderBookings() async {
    try {
      final response = await _dio.get('/bookings/provider');
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) {
          final client  = json['client'] ?? {};
          final service = json['service'] ?? {};
          
          final map = Map<String, dynamic>.from(json);
          map['clientName']   = '${client['firstName'] ?? 'Client'} ${client['lastName'] ?? ''}'.trim();
          map['clientAvatar'] = client['profileImage'] ?? '';
          map['serviceName']  = service['name'] ?? 'Service';
          map['bookingDate']  = json['date'];
          map['timeSlot']     = json['startTime'];
          // ✅ FIX F7: Map clientId → userId so provider_state.dart gets the real client ID
          // Backend returns 'clientId' not 'userId'; client['id'] is the source of truth
          map['userId']       = client['id'] ?? json['clientId'] ?? '';

          return Booking.fromJson(map);
        }).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  // ── Get booked slots for a provider on a given date ─────────────
  /// Returns a list of already-booked { startTime, endTime } windows.
  /// Used by the booking flow to mark slots unavailable.
  Future<List<Map<String, String>>> getBookedSlots({
    required String providerId,
    required String date,
  }) async {
    try {
      final response = await _dio.get('/bookings/slots', queryParameters: {
        'providerId': providerId,
        'date':       date,
      });
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((item) => {
          'startTime': item['startTime'] as String,
          'endTime':   item['endTime']   as String,
        }).toList();
      }
      return [];
    } catch (e) {
      // Non-critical — fall back to showing all slots as available
      return [];
    }
  }

  // ── Favorites ────────────────────────────────────────────────────
  Future<bool> toggleFavorite(String providerProfileId) async {
    try {
      final response = await _dio.post('/favorites/toggle', data: {
        'providerProfileId': providerProfileId,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<List<String>> getFavorites() async {
    try {
      final response = await _dio.get('/favorites');
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((f) => f['providerProfileId'].toString()).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
