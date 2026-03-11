@echo off
REM Flutter Build Fix Script for Windows
REM This script resolves common Gradle and Kotlin compilation issues
REM especially for cross-drive paths and incremental compilation issues

echo.
echo ===================================================
echo Flutter Build Fix Script for Windows
echo ===================================================
echo.

REM Check if we're in the Flutter project root
if not exist "pubspec.yaml" (
    echo ERROR: This script must be run from the Flutter project root directory!
    echo Please navigate to your flutter_booking_app directory and try again.
    pause
    exit /b 1
)

echo Step 1: Cleaning Flutter cache and build directories...
call flutter clean
if %errorlevel% neq 0 (
    echo Error during flutter clean. Continuing anyway...
)

echo.
echo Step 2: Deleting Android build cache...
if exist "android\.gradle" (
    rmdir /s /q android\.gradle
    echo Deleted android\.gradle
)

if exist "android\build" (
    rmdir /s /q android\build
    echo Deleted android\build
)

if exist "build" (
    rmdir /s /q build
    echo Deleted root build directory
)

echo.
echo Step 3: Cleaning Gradle cache...
if exist "%USERPROFILE%\.gradle\caches" (
    echo WARNING: This will delete Gradle caches. Press Ctrl+C to cancel if needed.
    timeout /t 3
    rmdir /s /q "%USERPROFILE%\.gradle\caches"
    echo Deleted Gradle caches
)

echo.
echo Step 4: Getting Flutter dependencies...
call flutter pub get
if %errorlevel% neq 0 (
    echo Error during flutter pub get!
    pause
    exit /b 1
)

echo.
echo Step 5: Running Flutter pub upgrade for potential fixes...
call flutter pub upgrade
if %errorlevel% neq 0 (
    echo Warning: flutter pub upgrade had issues, but continuing...
)

echo.
echo ===================================================
echo Build cleanup complete!
echo ===================================================
echo.
echo Next steps:
echo 1. Run: flutter run
echo 2. If still failing, try: flutter run --verbose
echo 3. For more details, see BUILD_TROUBLESHOOTING.md
echo.
pause
