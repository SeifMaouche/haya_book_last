// lib/routes/app_router.dart
import 'package:flutter/material.dart';

// ── Client screens ─────────────────────────────────────────────
import '../screens/splash_screen.dart';
import '../screens/welcome_onboarding_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/otp_verification_screen.dart';
import '../screens/complete_profile_screen.dart';
import '../screens/home_screen.dart' hide BrowseScreen;
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

// ── Provider screens ───────────────────────────────────────────
import '../screens/provider/provider_home_screen.dart';
import '../screens/provider/provider_bookings_screen.dart';
import '../screens/provider/provider_messages_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/provider/provider_services_screen.dart';
import '../screens/provider/provider_add_service_screen.dart';
import '../screens/provider/provider_booking_detail_screen.dart';
import '../screens/provider/provider_profile_screen.dart';
import '../screens/provider/provider_edit_profile_screen.dart';
import '../screens/provider/provider_settings_screen.dart';
import '../screens/provider/provider_complete_profile_screen.dart';
import '../screens/provider/provider_availability_screen.dart';

// ── Models ─────────────────────────────────────────────────────
import '../models/provider_model.dart';
import '../models/provider_models.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

    // ══════════════════════════════════════════════════════════
    // AUTH & ONBOARDING
    // ══════════════════════════════════════════════════════════
      case '/splash':
        return _build(const SplashScreen());

      case '/onboarding':
        return _build(const WelcomeOnboardingScreen());

      case '/login':
        return _build(const LoginScreen());

      case '/signup/client':
        return _build(const SignupScreen(role: 'client'));

      case '/signup/provider':
        return _build(const SignupScreen(role: 'provider'));

    // Legacy fallback
      case '/signup':
        return _build(const SignupScreen(role: 'client'));

      case '/otp-verification':
        return _build(const OtpVerificationScreen());

    // Client profile setup (after OTP as client)
      case '/complete-profile':
        return _build(const CompleteProfileScreen());

    // ══════════════════════════════════════════════════════════
    // CLIENT — MAIN TABS
    // ══════════════════════════════════════════════════════════
      case '/':
        return _build(const HomeScreen());

      case '/browse':
        return _build(const BrowseScreen());

      case '/bookings':
        return _build(const BookingsScreen());

      case '/messages':
        return _build(const MessagesScreen());

      case '/profile':
        return _build(const ProfileScreen());

      case '/edit-profile':
        return _build(const EditProfileScreen());

    // ══════════════════════════════════════════════════════════
    // CLIENT — EXTRA SCREENS
    // ══════════════════════════════════════════════════════════
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

    // ══════════════════════════════════════════════════════════
    // CLIENT — BOOKING FLOW
    // ══════════════════════════════════════════════════════════
      case '/provider':
        final args     = settings.arguments as Map<String, dynamic>?;
        final provider = args?['provider'] as ServiceProvider?;
        return _build(ProviderDetailScreen(provider: provider));

      case '/booking':
        return _build(const BookingScreen());

      case '/confirmation':
        return _build(const ConfirmationScreen());

    // ══════════════════════════════════════════════════════════
    // PROVIDER — 4 NAV TABS
    // ══════════════════════════════════════════════════════════
      case '/provider/home':       // tab 0
        return _build(const ProviderHomeScreen());

      case '/provider/bookings':   // tab 1
        return _build(const ProviderBookingsScreen());

      case '/provider/messages':   // tab 2
        return _build(const ProviderMessagesScreen());

      case '/provider/services':   // tab 3
        return _build(const ProviderServicesScreen());

      case '/provider/profile':    // tab 4
        return _build(const ProviderProfileScreen());

    // ══════════════════════════════════════════════════════════
    // PROVIDER — SUPPORTING SCREENS
    // ══════════════════════════════════════════════════════════

    // 5-step onboarding — reached after OTP as provider
      case '/provider/setup':
        return _build(const ProviderCompleteProfileScreen());

    // Business profile form — from Profile tab → Edit Profile
      case '/provider/edit-profile':
        return _build(const ProviderEditProfileScreen());

    // Settings — from Profile tab → General Settings
      case '/provider/settings':
        return _build(const ProviderSettingsScreen());

    // Weekly availability — from Profile tab → Availability
    // also from Schedule view → Block Time
      case '/provider/availability':
        return _build(const ProviderAvailabilityScreen());

    // Add or edit a service — from Services tab → +
      case '/provider/add-service':
        final service = settings.arguments as ProviderService?;
        return _build(ProviderAddServiceScreen(service: service));

    // Booking detail — from Bookings tab → DETAILS
      case '/provider/booking-detail':
        final booking = settings.arguments as ProviderBooking;
        return _build(ProviderBookingDetailScreen(booking: booking));

    // ══════════════════════════════════════════════════════════
    // FALLBACK
    // ══════════════════════════════════════════════════════════
      default:
        return _build(Scaffold(
          body: Center(
            child: Text(
              'No route defined for "${settings.name}"',
              style: const TextStyle(fontFamily: 'Inter'),
            ),
          ),
        ));
    }
  }

  static MaterialPageRoute<dynamic> _build(Widget page) =>
      MaterialPageRoute(builder: (_) => page);
}