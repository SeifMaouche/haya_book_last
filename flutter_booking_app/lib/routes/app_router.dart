import 'package:flutter/material.dart';

import '../screens/home_screen.dart' hide BrowseScreen;
import '../screens/splash_screen.dart';
import '../screens/complete_profile_screen.dart';
import '../screens/welcome_onboarding_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/otp_verification_screen.dart';
import '../screens/browse_screen.dart';
import '../screens/bookings_screen.dart';
import '../screens/messages_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/provider_detail_screen.dart';
import '../screens/booking_screen.dart';
import '../screens/confirmation_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/help_faq_screen.dart';
import '../screens/contact_us_screen.dart';
import '../screens/payment_screen.dart';
import '../screens/add_card_screen.dart';
import '../screens/privacy_policy_screen.dart';

import '../models/provider_model.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

    // ── Auth & onboarding ──────────────────────────────────
      case '/splash':
        return _build(const SplashScreen());
      case '/onboarding':
        return _build(const WelcomeOnboardingScreen());
      case '/login':
        return _build(const LoginScreen());
      case '/signup':
        return _build(const SignupScreen());
      case '/otp-verification':
        return _build(const OtpVerificationScreen());
      case '/complete-profile':
        return _build(const CompleteProfileScreen());

    // ── Main tabs ──────────────────────────────────────────
      case '/':
        return _build(const HomeScreen());
      case '/browse':
        return _build(const BrowseScreen());
      case '/bookings':
        return _build(const BookingsScreen());
      case '/my-bookings':
        return _build(const MyBookingsScreen());
      case '/messages':
        return _build(const MessagesScreen());
      case '/profile':
        return _build(const ProfileScreen());
      case '/edit-profile':
        return _build(const EditProfileScreen());

    // ── New screens ────────────────────────────────────────
      case '/notifications':
        return _build(const NotificationsScreen());
      case '/favorites':
        return _build(const FavoritesScreen());
      case '/help-faq':
        return _build(const HelpFaqScreen());
      case '/contact-us':
        return _build(const ContactUsScreen());


      case '/payment':
   return _build(const PaymentScreen());

 case '/add-card':
   return _build(const AddCardScreen());

 case '/privacy-policy':
   return _build(const PrivacyPolicyScreen());

    // ── Provider & booking flow ────────────────────────────
      case '/provider':
        final args = settings.arguments as Map<String, dynamic>?;
        final provider = args?['provider'] as ServiceProvider?;
        return _build(ProviderDetailScreen(provider: provider));
      case '/booking':
        return _build(const BookingScreen());
      case '/confirmation':
        return _build(const ConfirmationScreen());

      default:
        return _build(Scaffold(
          body: Center(
            child: Text('No route defined for "${settings.name}"',
                style: const TextStyle(fontFamily: 'Inter')),
          ),
        ));
    }
  }

  static MaterialPageRoute<dynamic> _build(Widget page) =>
      MaterialPageRoute(builder: (_) => page);
}