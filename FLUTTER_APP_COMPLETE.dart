// ===== COMPLETE FLUTTER APPLICATION =====
// Copy all the code below into separate files in your Flutter project
// File structure:
// lib/
//   ├── main.dart
//   ├── models/
//   │   ├── booking.dart
//   │   └── location.dart
//   ├── providers/
//   │   ├── booking_provider.dart
//   │   └── location_provider.dart
//   ├── screens/
//   │   ├── home_screen.dart
//   │   ├── browse_screen.dart
//   │   ├── provider_detail_screen.dart
//   │   ├── booking_screen.dart
//   │   ├── my_bookings_screen.dart
//   │   └── profile_screen.dart
//   ├── widgets/
//   │   ├── bottom_nav.dart
//   │   ├── location_modal.dart
//   │   └── booking_card.dart
//   └── theme/
//       └── app_theme.dart

// ===== pubspec.yaml =====
/*
name: bookapp
description: A Flutter booking application.
publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  provider: ^6.0.0
  intl: ^0.19.0
  shared_preferences: ^2.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
  fonts:
    - family: Geist
      fonts:
        - asset: assets/fonts/Geist-Regular.ttf
        - asset: assets/fonts/Geist-Bold.ttf
          weight: 700
*/

// ===== lib/main.dart =====
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/location_provider.dart';
import 'providers/booking_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BookApp());
}

class BookApp extends StatelessWidget {
  const BookApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: MaterialApp(
        title: 'BookApp',
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// ===== lib/theme/app_theme.dart =====
class AppTheme {
  static const Color primaryColor = Color(0xFF0d968b);
  static const Color accentColor = Color(0xFFFFA500);
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF1A1A1A);
  static const Color mutedColor = Color(0xFF666666);
  static const Color borderColor = Color(0xFFEEEEEE);
  static const Color successColor = Color(0xFF10B981);
  static const Color dangerColor = Color(0xFFEF4444);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      brightness: Brightness.light,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        elevation: 8,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textColor,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: mutedColor,
        ),
      ),
    );
  }
}

// ===== lib/models/location.dart =====
class Location {
  final String name;
  final String country;
  final bool isPopular;

  Location({
    required this.name,
    required this.country,
    this.isPopular = false,
  });
}

// ===== lib/models/booking.dart =====
class Booking {
  final String id;
  final String provider;
  final String service;
  final String date;
  final String time;
  final String avatar;
  final String status; // upcoming, past, cancelled
  final String? fee;

  Booking({
    required this.id,
    required this.provider,
    required this.service,
    required this.date,
    required this.time,
    required this.avatar,
    required this.status,
    this.fee,
  });

  Booking copyWith({
    String? id,
    String? provider,
    String? service,
    String? date,
    String? time,
    String? avatar,
    String? status,
    String? fee,
  }) {
    return Booking(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      service: service ?? this.service,
      date: date ?? this.date,
      time: time ?? this.time,
      avatar: avatar ?? this.avatar,
      status: status ?? this.status,
      fee: fee ?? this.fee,
    );
  }
}

// ===== lib/providers/location_provider.dart =====
class LocationProvider extends ChangeNotifier {
  String _selectedLocation = 'Algiers, Algeria';

  String get selectedLocation => _selectedLocation;

  final List<Location> popularLocations = [
    Location(name: 'Algiers', country: 'Algeria', isPopular: true),
    Location(name: 'Oran', country: 'Algeria', isPopular: true),
    Location(name: 'Constantine', country: 'Algeria', isPopular: true),
    Location(name: 'Sétif', country: 'Algeria', isPopular: true),
    Location(name: 'Annaba', country: 'Algeria', isPopular: true),
    Location(name: 'Blida', country: 'Algeria', isPopular: true),
    Location(name: 'Tlemcen', country: 'Algeria', isPopular: true),
    Location(name: 'Batna', country: 'Algeria', isPopular: true),
  ];

  void setLocation(String location) {
    _selectedLocation = location;
    notifyListeners();
  }
}

// ===== lib/providers/booking_provider.dart =====
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

// ===== lib/screens/home_screen.dart =====
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeContent(),
          const BrowseScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNav(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildHomeContent() {
    return Column(
      children: [
        // Header
        Container(
          color: AppTheme.primaryColor,
          padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
          child: Consumer<LocationProvider>(
            builder: (context, locationProvider, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BookApp',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  GestureDetector(
                    onTap: () {
                      _showLocationModal(context);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            locationProvider.selectedLocation,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        Text(
                          'Change',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        // Content
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search doctors, clinics...',
                      prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.borderColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      fillColor: AppTheme.cardColor,
                      filled: true,
                    ),
                  ),
                ),
                // Categories
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCategoryButton('Clinics', Icons.medical_services),
                      _buildCategoryButton('Salons', Icons.spa),
                      _buildCategoryButton('Tutors', Icons.school),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Upcoming Bookings
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Upcoming Bookings',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 12),
                Consumer<BookingProvider>(
                  builder: (context, bookingProvider, _) {
                    final upcoming = bookingProvider.upcomingBookings;
                    if (upcoming.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.borderColor),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.schedule, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 12),
                              const Text(
                                'No upcoming bookings',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedIndex = 1;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  minimumSize: const Size(double.infinity, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Browse Now',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: upcoming.length,
                      itemBuilder: (context, index) {
                        return BookingCard(booking: upcoming[index]);
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryButton(String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  void _showLocationModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => LocationModal(),
    );
  }
}

// ===== lib/screens/browse_screen.dart =====
class BrowseScreen extends StatelessWidget {
  const BrowseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          AppBar(
            title: const Text('Browse Providers'),
            elevation: 0,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildProviderCard(
                  'City Health Specialists',
                  'Clinic',
                  4.9,
                  124,
                  'Downtown',
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBdCiuytJCU4K2UjXSqkf4CtyUZQ_1acYvR-DQo-wcu5W9eqB16ha9gIHJ96IRIrugRsdW59J7mLC_mzjHkciMaffs68dzgItdG7rVXg0zZKlcrwztkZyam1BNhyyOXFJHXfBxihqmE6z95qy9EYpQjJBAb83uu-nuz0-bGxocelptaVcuFXgY3S8WXTHeVKFUyGgpkOOOghU-t9CAr0tSr2TWvNA8mUEc_6EiSv7lLsaann2NyoQtcYEtP7Fgz83_xq4iTw0s0apI',
                  context,
                ),
                const SizedBox(height: 12),
                _buildProviderCard(
                  'Glow Up Beauty Studio',
                  'Salon',
                  4.7,
                  85,
                  'Greenwich Village',
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuD58O9sAwuQeuxjkT4V7XTtAL6Bzy0PJyDdklCjNqMtSYdgsqw_jm165mnOtdWfMqFi8NTN3KqK-9YV6QT7vRdcDarbWzYsvqEK_tf3PsCT0xHh0Df_VH78ut6zqruaNVaDm3vPCqX__7XwjOeMckEj-LPNpkok4HAGWU39pu2eelNJ3H33qaqb8f-9H6cU7sxO-PFC_OVrhQr1olgpOmkGxRnYmb4sAo6VX4gN50c4NP9tYqPI2WZrkbAz6QR-AKPsPsdPIH-VdAs',
                  context,
                ),
                const SizedBox(height: 12),
                _buildProviderCard(
                  'Apex Math Tutoring',
                  'Tutor',
                  5.0,
                  42,
                  'Chelsea',
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCakLGNctXB0gYEVj5qgAugU_tlBB3lZ7HIGqlmDMg7GBBFM5KVW6N8yQE_962w4m9uY4LMrjK3__2dGL8yJzKrvUU6uGbXQdFdsoa0m9q14wOJyJDcUFXy1oaTaBamMz8r-xhxDMLEb-4QXr-Aiwg9R5LyHeHnqGpaXtEmRNYFvqde2jD7styTels2lbpUHktmpflHOWUQiK-Zh9Aha0OYqcnkQGBKEjdy-WseojLs2jBuc7uaVrn7tXmpGAlHpl8F9dInUB4xrV0',
                  context,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(
    String name,
    String type,
    double rating,
    int reviews,
    String location,
    String imageUrl,
    BuildContext context,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              imageUrl,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$rating ($reviews reviews)',
                      style: const TextStyle(fontSize: 12, color: AppTheme.mutedColor),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  location,
                  style: const TextStyle(fontSize: 12, color: AppTheme.mutedColor),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProviderDetailScreen(
                          providerName: name,
                          providerType: type,
                          imageUrl: imageUrl,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  child: const Text('View Details', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===== lib/screens/provider_detail_screen.dart =====
class ProviderDetailScreen extends StatefulWidget {
  final String providerName;
  final String providerType;
  final String imageUrl;

  const ProviderDetailScreen({
    Key? key,
    required this.providerName,
    required this.providerType,
    required this.imageUrl,
  }) : super(key: key);

  @override
  State<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen> {
  bool _isLiked = false;
  String? _selectedService;
  DateTime? _selectedDate;
  String? _selectedTime;

  final List<String> _services = ['General Consultation', 'Cardiology Screening'];
  final List<String> _times = ['10:00 AM', '11:00 AM', '2:30 PM', '3:30 PM'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Image
            Stack(
              children: [
                Image.network(
                  widget.imageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isLiked = !_isLiked;
                          });
                        },
                        icon: Icon(
                          _isLiked ? Icons.favorite : Icons.favorite_border,
                          color: _isLiked ? AppTheme.dangerColor : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.providerName,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'OPEN',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.providerType,
                        style: const TextStyle(fontSize: 12, color: AppTheme.mutedColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Services
                  Text(
                    'Services',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ..._services.map((service) {
                    final isSelected = _selectedService == service;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedService = service;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: isSelected ? AppTheme.primaryColor.withOpacity(0.05) : Colors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  service,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const Text(
                                'DZD 3,000',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 20),
                  // Date Selection
                  Text(
                    'Select Date',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (date != null) {
                        setState(() {
                          _selectedDate = date;
                        });
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _selectedDate == null
                          ? 'Choose Date'
                          : '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}',
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryColor,
                      side: const BorderSide(color: AppTheme.borderColor),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Time Selection
                  Text(
                    'Select Time',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _times.map((time) {
                      final isSelected = _selectedTime == time;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTime = time;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryColor : Colors.white,
                            border: Border.all(
                              color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            time,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppTheme.textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  // Book Button
                  ElevatedButton(
                    onPressed: _selectedService != null && _selectedDate != null && _selectedTime != null
                        ? () {
                            final booking = Booking(
                              id: 'bk-${DateTime.now().millisecondsSinceEpoch}',
                              provider: widget.providerName,
                              service: _selectedService!,
                              date: '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}',
                              time: _selectedTime!,
                              avatar: widget.imageUrl,
                              status: 'upcoming',
                            );
                            Provider.of<BookingProvider>(context, listen: false).addBooking(booking);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Booking confirmed!')),
                            );
                            Navigator.pop(context);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Book Appointment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== lib/screens/profile_screen.dart =====
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          AppBar(
            title: const Text('Profile'),
            elevation: 0,
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_circle, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'User Profile',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Email: user@bookapp.com',
                    style: TextStyle(color: AppTheme.mutedColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===== lib/widgets/bottom_nav.dart =====
class BottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const BottomNav({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Browse',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'Profile',
        ),
      ],
    );
  }
}

// ===== lib/widgets/location_modal.dart =====
class LocationModal extends StatefulWidget {
  const LocationModal({Key? key}) : super(key: key);

  @override
  State<LocationModal> createState() => _LocationModalState();
}

class _LocationModalState extends State<LocationModal> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, _) {
        final filtered = locationProvider.popularLocations
            .where((loc) => loc.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                      const Expanded(
                        child: Text(
                          'Select Location',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search city or area...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.borderColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.location_on, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Use Current Location',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Enable GPS for better accuracy',
                                    style: TextStyle(fontSize: 12, color: AppTheme.mutedColor),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: AppTheme.mutedColor),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'POPULAR CITIES',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.mutedColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...filtered.map((location) {
                        return GestureDetector(
                          onTap: () {
                            locationProvider.setLocation('${location.name}, ${location.country}');
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Icon(Icons.location_on, color: AppTheme.mutedColor, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    location.name,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                const Icon(Icons.chevron_right, color: AppTheme.mutedColor),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          "Can't find your city?",
                          style: TextStyle(fontSize: 12, color: AppTheme.mutedColor),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Center(
                        child: Text(
                          'Contact support',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ===== lib/widgets/booking_card.dart =====
class BookingCard extends StatelessWidget {
  final Booking booking;

  const BookingCard({Key? key, required this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.network(
              booking.avatar,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.provider,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  booking.service,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 12, color: AppTheme.mutedColor),
                    const SizedBox(width: 4),
                    Text(
                      '${booking.date} at ${booking.time}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.mutedColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
