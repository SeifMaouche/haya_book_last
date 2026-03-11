# BookApp Flutter - Setup Guide for Latest Android Studio

This guide will help you set up and run the BookApp Flutter application with the latest Android Studio, SDK, and NDK.

## Requirements

- **Flutter SDK**: Version 3.0.0 or higher
- **Android Studio**: Latest version (2024.x or higher)
- **Android SDK**: API level 34 (Android 14)
- **NDK**: Version 27.0.12077973
- **Java**: JDK 11 or higher

## Setup Steps

### 1. Verify Flutter Installation

```bash
flutter --version
flutter doctor
```

Make sure all required items have checkmarks (✓).

### 2. Configure Android SDK in Flutter

Get your Android SDK path:
- **Windows**: Usually `C:\Users\YourUsername\AppData\Local\Android\Sdk`
- **Mac**: Usually `~/Library/Android/sdk`
- **Linux**: Usually `~/Android/Sdk`

Set it in Flutter:
```bash
flutter config --android-sdk /path/to/android/sdk
```

### 3. Accept Android Licenses

```bash
flutter doctor --android-licenses
```

Press `y` to accept all licenses when prompted.

### 4. Verify Android Setup in Android Studio

1. Open Android Studio
2. Go to **File → Settings → Languages & Frameworks → Android SDK**
3. Go to **SDK Tools** tab
4. Ensure these are installed:
   - Android SDK Build-Tools (34.0.0 or latest)
   - Android SDK Platform (API 34)
   - **NDK (Side by side)** - Version 27.0.12077973
   - **CMake** - Latest version
   - **Android Emulator**

### 5. Create/Start Android Emulator

1. In Android Studio, click **AVD Manager** (or **Tools → Device Manager**)
2. Create or select an emulator with:
   - API level 34 or higher
   - Target: Android 14.0 (Google Play or AOSP)
3. Click **Start** to launch the emulator
4. Wait for it to fully boot (2-3 minutes)

### 6. Verify Emulator is Running

```bash
flutter devices
```

You should see your emulator listed.

### 7. Navigate to Project Directory

```bash
cd flutter_booking_app
```

### 8. Install Dependencies

```bash
flutter pub get
```

### 9. Build and Run

**First time build (takes longer):**
```bash
flutter run
```

**Or for faster builds:**
```bash
flutter run --release
```

**On a specific emulator:**
```bash
flutter run -d emulator-5554
```

## Common Issues & Solutions

### Issue: No Supported Devices Connected

**Solution:**
1. Check running devices: `flutter devices`
2. Start the Android emulator from AVD Manager
3. Wait for it to fully boot
4. Run `flutter run` again

### Issue: NDK Not Found

**Solution:**
The gradle files are configured to use NDK 27.0.12077973. Make sure it's installed:
1. Open Android Studio
2. Tools → SDK Manager → SDK Tools
3. Check "NDK (Side by side)"
4. Install version 27.0.12077973

### Issue: Build Fails with Gradle Errors

**Solution:**
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: Emulator is Slow

**Solution:**
Use a release build:
```bash
flutter run --release
```

Or use a faster emulator configuration in AVD Manager.

## Project Structure

```
flutter_booking_app/
├── lib/
│   ├── main.dart              # App entry point
│   ├── config/
│   │   └── theme.dart         # Theme configuration
│   ├── models/
│   │   ├── provider_model.dart
│   │   └── booking_model.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   └── booking_provider.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── browse_screen.dart
│   │   ├── booking_screen.dart
│   │   └── ... other screens
│   ├── widgets/
│   │   ├── category_card.dart
│   │   └── provider_card.dart
│   └── routes/
│       └── app_router.dart
├── android/                   # Android native code
├── pubspec.yaml              # Dependencies
└── README.md
```

## Dependencies

Key packages used:
- **provider**: State management
- **table_calendar**: Calendar widget for booking dates
- **intl**: Date/time formatting
- **http/dio**: API calls
- **shared_preferences**: Local storage
- **flutter_svg**: SVG icon support

## Testing the App

1. **Home Screen**: View featured providers and categories
2. **Browse**: Search and filter providers
3. **Provider Details**: View detailed provider information
4. **Booking Flow**: Select service, date, and time
5. **My Bookings**: View your booking history

## Troubleshooting Commands

```bash
# Clean build
flutter clean

# Get fresh dependencies
flutter pub get

# Run with verbose output
flutter run -v

# Run in debug mode
flutter run -d emulator-5554 --debug

# Run in release mode
flutter run -d emulator-5554 --release

# Check SDK info
flutter doctor -v

# Update Flutter
flutter upgrade
```

## Next Steps

1. Once the app runs successfully, you can:
   - Connect it to a backend API
   - Add authentication
   - Implement payment processing
   - Build for production

2. For production build:
   ```bash
   flutter build apk --release
   ```

## Support

If you encounter issues:
1. Run `flutter doctor -v` to check your setup
2. Check Flutter documentation: https://flutter.dev
3. Check Android Studio documentation: https://developer.android.com

---

**Happy coding! 🚀**
