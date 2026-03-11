# BookApp - Flutter Mobile Booking Application

A modern, feature-rich mobile booking application built with Flutter for discovering and booking services like clinics, salons, and tutors.

## Features

### Client App
- **Home Screen**: Browse featured providers and quick access to categories
- **Browse & Search**: Find providers by name, category, distance, or rating
- **Provider Details**: View complete provider information, services, working hours, and reviews
- **Booking Flow**: 4-step booking process with service selection, date/time picker, and confirmation
- **My Bookings**: View upcoming and past bookings with status management
- **Authentication**: User registration and login with email/password

### Design
- **Modern UI**: Clean and intuitive interface with professional design
- **Color Palette**: Teal primary (#0D9488) and Orange accent (#F97316)
- **Typography**: Poppins for headings, Inter for body text
- **Responsive**: Fully responsive design for all screen sizes
- **Dark Mode Ready**: Complete dark theme support

## Project Structure

```
lib/
├── config/
│   └── theme.dart              # Theme configuration and colors
├── models/
│   ├── provider_model.dart      # ServiceProvider, Service, Review models
│   └── booking_model.dart       # Booking, BookingRequest, TimeSlot models
├── providers/
│   ├── auth_provider.dart       # Authentication state management
│   └── booking_provider.dart    # Booking state management
├── routes/
│   └── app_router.dart          # Route definitions
├── screens/
│   ├── home_screen.dart         # Home page
│   ├── browse_screen.dart       # Provider browse & search
│   ├── provider_detail_screen.dart  # Provider details
│   ├── booking_screen.dart      # Booking flow (4 steps)
│   ├── confirmation_screen.dart # Booking confirmation
│   ├── my_bookings_screen.dart  # User bookings list
│   ├── login_screen.dart        # Authentication
│   └── signup_screen.dart       # Registration
├── widgets/
│   ├── category_card.dart       # Category selection card
│   └── provider_card.dart       # Provider list card
└── main.dart                    # App entry point
```

## Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- iOS or Android development environment

### Installation

1. **Clone or extract the project**
   ```bash
   cd flutter_booking_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code (if needed)**
   ```bash
   flutter pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## Dependencies

Key packages used in this project:

- **provider** (6.0.0): State management
- **table_calendar** (3.0.9): Calendar for date selection
- **intl** (0.19.0): Internationalization and date formatting
- **shared_preferences** (2.2.2): Local data persistence
- **http** / **dio** (5.3.1): API communication
- **cached_network_image** (3.3.0): Image caching
- **flutter_local_notifications** (16.1.0): Push notifications

## Architecture

The app follows a clean architecture pattern with clear separation of concerns:

- **Models**: Data classes for type safety
- **Providers**: State management using Provider package
- **Screens**: UI screens with business logic
- **Widgets**: Reusable UI components
- **Config**: App-wide configuration (theme, constants)

## State Management

Using the Provider pattern for state management:

- **AuthProvider**: Manages user authentication and session
- **BookingProvider**: Handles provider data, bookings, and booking workflow

## API Integration

The app is ready to integrate with any backend API. Currently uses mock data in:
- `BookingProvider.fetchProviders()`
- `AuthProvider.login()` / `AuthProvider.signup()`

Replace the TODO comments with actual API calls using the `http` or `dio` package.

## Customization

### Colors
Edit `lib/config/theme.dart` in the `AppColors` class:
```dart
static const Color primary = Color(0xFF0D9488); // Teal
static const Color secondary = Color(0xFFF97316); // Orange
```

### Typography
Modify font sizes and families in `AppTheme` class.

### Providers Data
Update mock data in `BookingProvider.fetchProviders()` or connect to a real API.

## Future Enhancements

- Real API integration
- Provider maps and location services
- Push notifications
- Payment integration
- Reviews and ratings system
- Booking history and invoices
- Provider dashboard (admin app)
- Video consultations
- Messaging system between clients and providers

## Building for Production

### iOS
```bash
flutter build ios --release
```

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

## Troubleshooting

### Issue: Dependencies not installing
**Solution**: Clear pub cache and get dependencies again
```bash
flutter pub cache clean
flutter pub get
```

### Issue: Calendar widget showing errors
**Solution**: Ensure `table_calendar` package is properly installed
```bash
flutter pub add table_calendar
```

### Issue: Images not loading
**Solution**: Check network connectivity and ensure image URLs are valid

## License

This project is created for the BookApp platform.

## Support

For issues and feature requests, please contact the development team or create an issue in the repository.

---

**Built with Flutter | Design inspired by modern booking platforms**
