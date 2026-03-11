import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ── These imports must match YOUR existing file locations ─────────
import 'config/theme.dart';           // lib/config/theme.dart
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/favorites_provider.dart';  // NEW — add this file

// ── All screens ────────────────────────────────────────────────────
import 'screens/splash_screen.dart';
import 'screens/welcome_onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/otp_verification_screen.dart';
import 'screens/home_screen.dart' hide BrowseScreen;
import 'screens/browse_screen.dart';
import 'screens/bookings_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/provider_detail_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/confirmation_screen.dart';
import 'screens/notifications_screen.dart';   // NEW
import 'screens/favorites_screen.dart';        // NEW
import 'screens/help_faq_screen.dart';         // NEW
import 'screens/contact_us_screen.dart';       // NEW
import 'screens/reviews_screen.dart';          // NEW
import 'screens/complete_profile_screen.dart';
import '../screens/payment_screen.dart';
import '../screens/add_card_screen.dart';
import '../screens/privacy_policy_screen.dart';

import 'models/provider_model.dart';

void main() {
  runApp(const HayaBookApp());
}

class HayaBookApp extends StatelessWidget {
  const HayaBookApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()), // NEW
      ],
      child: MaterialApp(
        title: 'HayaBook',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        onGenerateRoute: _generateRoute,
        initialRoute: '/splash',
      ),
    );
  }

  // ── Router defined inline — no separate file needed ─────────────
  static Route<dynamic> _generateRoute(RouteSettings settings) {
    Widget page;

    switch (settings.name) {
      case '/splash':
        page = const SplashScreen();
        break;
      case '/onboarding':
        page = const WelcomeOnboardingScreen();
        break;
      case '/login':
        page = const LoginScreen();
        break;
      case '/signup':
        page = const SignupScreen();
        break;
      case '/otp-verification':
        page = const OtpVerificationScreen();
        break;
      case '/complete-profile':
        page = const CompleteProfileScreen();
        break;
      case '/':
        page = const HomeScreen();
        break;
      case '/browse':
        page = const BrowseScreen();
        break;
      case '/bookings':
        page = const BookingsScreen();
        break;
      case '/my-bookings':
        page = const MyBookingsScreen();
        break;
      case '/messages':
        page = const MessagesScreen();
        break;
      case '/profile':
        page = const ProfileScreen();
        break;
      case '/edit-profile':
        page = const EditProfileScreen();
        break;

    // ── New screens ──────────────────────────────────────────────
      case '/notifications':
        page = const NotificationsScreen();
        break;
      case '/favorites':
        page = const FavoritesScreen();
        break;
      case '/help-faq':
        page = const HelpFaqScreen();
        break;
      case '/contact-us':
        page = const ContactUsScreen();
        break;
      case '/payment':
        page = const PaymentScreen();
        break;

      case '/add-card':
        page = const AddCardScreen();
        break;
      case '/privacy-policy':
        page = const PrivacyPolicyScreen();
        break;




    // ── Provider & booking flow ──────────────────────────────────
      case '/provider':
        final args = settings.arguments as Map<String, dynamic>?;
        final provider = args?['provider'] as ServiceProvider?;
        page = ProviderDetailScreen(provider: provider);
        break;
      case '/booking':
        page = const BookingScreen();
        break;
      case '/confirmation':
        page = const ConfirmationScreen();
        break;

      default:
        page = Scaffold(
          body: Center(
            child: Text('No route defined for "${settings.name}"',
                style: const TextStyle(fontFamily: 'Inter')),
          ),
        );
    }

    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}