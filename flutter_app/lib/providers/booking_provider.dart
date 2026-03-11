import 'package:flutter/material.dart';
import '../models/location.dart';

class BookingProvider extends ChangeNotifier {
  final List<Booking> _bookings = [
    Booking(
      id: 'bk-1',
      provider: 'Dr. Sarah Jenkins',
      service: 'General Consultation',
      date: 'Dec 24, 2025',
      time: '10:00 AM',
      avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBMPaHBMiyjJbLlvdNEiDoBsVDjpi93KLapwnWXFptmvX584YIxwL025WGYI7eQgWELQV_eG4Vu5W0tFnpK7hbmwiN7bcq_4Ly20V2MUFOMCX0pRhvzRYGWtq9VQ4_0ra-JnawE3mAfcFjEla4oK9pvigVSoZvH1jTiOAT1tm7U0GEiHKuxEPY9InLPL7JI0oLJd36kbdrcS7E0o0vkBqGK6HmLSdQCqCkQJVstJ6rfv7aKMLydbKL8PWU1kkSSs3jaEJTiuHg0wWI',
      status: 'upcoming',
      fee: 'DZD 3,000',
    ),
    Booking(
      id: 'bk-2',
      provider: 'Dr. Marcus Chen',
      service: 'Dental Cleaning',
      date: 'Dec 28, 2025',
      time: '02:30 PM',
      avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuA5XiEEsIXwqxICBdsIGs3Mbht1Hh4UHfo7kAijOZ_zE7ss_fkX4o5BZyAyl6fniF3bh4Pku85i3s5x6oPpuJEuwBlLJ4NnOAyV6bTytXPj8Wl16tJmE4QyNP0SFVch3bJUVdq75rRW7z60Lv4d5WBdQKbj-iS9MofjBCjOvJDsJX4q6YRgnFUEkoK7_HsXylEOZMC8X-XdDB0Jjv0mEYE2Q8N8jF0kFPGEs9viY5X0uKH_DIYm5Gbg1w40egsl6-ZCWNdsAN-czAg',
      status: 'upcoming',
      fee: 'DZD 5,500',
    ),
  ];

  List<Booking> get bookings => _bookings;
  List<Booking> get upcomingBookings => _bookings.where((b) => b.status == 'upcoming').toList();
  List<Booking> get pastBookings => _bookings.where((b) => b.status == 'past').toList();
  List<Booking> get cancelledBookings => _bookings.where((b) => b.status == 'cancelled').toList();

  void addBooking(Booking booking) {
    _bookings.insert(0, booking);
    notifyListeners();
  }

  void cancelBooking(String id) {
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(status: 'cancelled');
      notifyListeners();
    }
  }

  void rescheduleBooking(String id, String newDate, String newTime) {
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(date: newDate, time: newTime);
      notifyListeners();
    }
  }
}
