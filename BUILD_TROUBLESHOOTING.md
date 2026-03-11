# Flutter Build Troubleshooting Guide

## Issue: Android Resource Linking Failed

### Error Message:
```
ERROR: ...build/app/intermediates/packaged_manifests/debug/processDebugManifestForPackage/AndroidManifest.xml:40: AAPT: error: resource mipmap/ic_launcher (aka com.example.booking_app:mipmap/ic_launcher) not found.
```

### Root Cause:
This error typically occurs due to:
1. Gradle cache corruption from dependency conflicts
2. Incompatible `shared_preferences` version with Android dependencies
3. Kotlin daemon compilation failures
4. Build cache not properly cleaned between builds

### Solution Steps:

#### Option 1: Windows - Quick Fix (Try This First)
```batch
cd flutter_booking_app

REM Run the automated cleanup script
fix-build-windows.bat
```

#### Option 2: macOS/Linux - Quick Fix
```bash
cd flutter_booking_app

# Run the automated cleanup script
bash ../fix-build.sh
```

#### Option 3: Manual Steps (Cross-Platform)
```bash
cd flutter_booking_app

# Step 1: Clean Flutter
flutter clean

# Step 2: Remove Gradle cache
rm -rf android/.gradle
rm -rf android/app/build
rm -rf build

# Step 3: Get dependencies again
flutter pub get

# Step 4: Rebuild
flutter run
```

#### Option 4: Full Nuclear Option (If Above Doesn't Work)
```bash
cd flutter_booking_app

# Remove all build artifacts
flutter clean
rm -rf android/.gradle
rm -rf android/app/build
rm -rf build

# Update dependencies
flutter pub get
flutter pub upgrade

# If on Windows:
# Also try: flutter pub cache repair

# Then run with verbose output to see what's happening
flutter run -v
```

### If Error Persists:

1. **Check Flutter Version:**
   ```bash
   flutter --version
   ```
   Ensure you're on a stable channel: `flutter channel stable`

2. **Check Java Version:**
   The project requires Java 17+
   ```bash
   java -version
   ```

3. **Check Android SDK:**
   ```bash
   flutter doctor -v
   ```

4. **Check Dependency Compatibility:**
   The `shared_preferences` dependency has been pinned to `^2.2.0` to ensure Android compatibility.

5. **Reset Gradle Daemon:**
   ```bash
   cd android
   ./gradlew --stop
   cd ..
   flutter run
   ```

### Windows-Specific Issues:

The current error suggests an issue with Kotlin incremental compilation on Windows with cross-drive paths (C: vs Z: drives). This has been fixed in the Gradle configuration by disabling incremental compilation.

If you're on Windows and still having issues:

1. **First**, run the provided batch script:
   ```batch
   fix-build-windows.bat
   ```

2. If that doesn't work, manually:
   - Close Android Studio completely
   - Close all IntelliJ-based IDEs
   - Delete the Kotlin daemon cache: `C:\Users\<YourUsername>\AppData\Local\kotlin-daemon`
   - Delete the Gradle cache: `C:\Users\<YourUsername>\.gradle\caches`
   - Then run:
     ```batch
     flutter pub cache repair
     flutter clean
     flutter pub get
     flutter run
     ```

3. **Cross-drive path issues**: If your project is on a different drive than Gradle cache (e.g., Z: drive vs C: drive), the incremental Kotlin compilation fails. The `build.gradle.kts` has been updated to disable incremental compilation. If issues persist, ensure your project is on the same drive as your user directory.

4. **Reset Gradle Daemon**:
   ```batch
   cd android
   gradlew --stop
   cd ..
   flutter run
   ```

### Alternative: Development on Different Emulator/Device

Sometimes the issue is specific to a particular emulator instance:

```bash
# List devices
flutter devices

# Run on a different device
flutter run -d <device_id>

# Or create a fresh emulator
# In Android Studio: Device Manager → Create Virtual Device
```

### Still Stuck?

If none of the above work:

1. Check the verbose output for more details:
   ```bash
   flutter run -v
   ```

2. Check the Gradle build output:
   ```bash
   cd android
   ./gradlew build --stacktrace
   ```

3. Review the complete error messages in the output - they often contain hints about what's wrong

4. Consider checking the Flutter GitHub issues: https://github.com/flutter/flutter/issues

---

## Additional Notes:

- The project uses Kotlin for Android (Kotlin 1.9+)
- Java version requirement: 17 or higher
- Gradle version is managed by Flutter
- The app includes proper desugaring for Android support

## Success Indicator:

Once the build succeeds, you should see:
```
Launching lib\main.dart on sdk gphone64 x86 64 in debug mode...
```
