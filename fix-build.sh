#!/bin/bash
# This script fixes the Flutter Android build issue

cd flutter_booking_app

echo "Step 1: Running flutter clean..."
flutter clean

echo "Step 2: Cleaning gradle cache..."
rm -rf android/.gradle
rm -rf android/app/build
rm -rf build

echo "Step 3: Running pub get..."
flutter pub get

echo "Step 4: Running pub upgrade (optional but helps with dependency resolution)..."
flutter pub upgrade

echo ""
echo "Build system cleaned successfully!"
echo ""
echo "Now try running: flutter run"
echo ""
echo "If you still encounter issues, try:"
echo "  1. Delete the entire build folder manually"
echo "  2. Run 'flutter pub get' again"
echo "  3. Try 'flutter run -v' for verbose output"
