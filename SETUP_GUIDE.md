# Setup Guide - Near & Now Flutter App

This guide will help you set up and run the Near & Now Flutter mobile app.

## Prerequisites

Before you begin, ensure you have the following installed:

1. **Flutter SDK** (3.0 or higher)
   - Download from: https://flutter.dev/docs/get-started/install
   - Add Flutter to your PATH

2. **Dart SDK** (3.0 or higher)
   - Comes bundled with Flutter

3. **IDE** (choose one):
   - Android Studio (recommended for Android)
   - VS Code with Flutter extension
   - IntelliJ IDEA

4. **Platform-specific tools**:
   - For Android: Android Studio + Android SDK
   - For iOS: Xcode (Mac only)

## Step 1: Verify Flutter Installation

```bash
# Check Flutter version
flutter --version

# Check for any issues
flutter doctor

# Fix any issues reported by flutter doctor
flutter doctor --android-licenses  # For Android
```

## Step 2: Clone/Navigate to Project

```bash
cd /Users/tiasmondal166/projects/near_and_now_app
```

## Step 3: Install Dependencies

```bash
# Get all packages
flutter pub get

# If you have issues, try:
flutter clean
flutter pub get
```

## Step 4: Configure the App

### Supabase Configuration
The app is pre-configured with Supabase credentials. You can find them in:
```
lib/core/config/app_config.dart
```

If you need to use your own Supabase instance:
1. Create a Supabase project at https://supabase.com
2. Update the `supabaseUrl` and `supabaseAnonKey` in `app_config.dart`

### Android Configuration

#### 1. Set Minimum SDK Version
File: `android/app/build.gradle`
```gradle
defaultConfig {
    minSdkVersion 21  // Already set
    targetSdkVersion 33
}
```

#### 2. Enable Internet Permission
File: `android/app/src/main/AndroidManifest.xml`
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS Configuration

#### 1. Set Minimum iOS Version
File: `ios/Podfile`
```ruby
platform :ios, '12.0'  # Already set
```

#### 2. Install CocoaPods
```bash
cd ios
pod install
cd ..
```

## Step 5: Run the App

### On Android Emulator
```bash
# List available devices
flutter devices

# Run on Android
flutter run
```

### On iOS Simulator (Mac only)
```bash
# Open simulator
open -a Simulator

# Run on iOS
flutter run
```

### On Physical Device

#### Android:
1. Enable Developer Options on your device
2. Enable USB Debugging
3. Connect device via USB
4. Run: `flutter run`

#### iOS:
1. Connect iPhone/iPad via USB
2. Trust computer on device
3. Sign the app in Xcode
4. Run: `flutter run`

## Step 6: Build for Release

### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS App (Mac only)
```bash
flutter build ios --release
# Then open Xcode to create archive
```

## Common Issues & Solutions

### Issue 1: Gradle Build Failed
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Issue 2: CocoaPods Issues (iOS)
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter run
```

### Issue 3: Network Errors
- Check internet connection
- Verify Supabase URL and keys
- Check firewall/proxy settings

### Issue 4: Plugin Errors
```bash
flutter clean
rm -rf ios/Pods ios/Podfile.lock
flutter pub get
cd ios && pod install && cd ..
```

### Issue 5: Hot Reload Not Working
- Restart the app: press 'R' in terminal
- Full restart: press 'Shift + R'
- If still not working, restart VS Code/Android Studio

## Development Tips

### 1. Enable Hot Reload
Hot reload is enabled by default. Just save your files!

### 2. Debug Mode
```bash
# Run in debug mode (default)
flutter run

# Run in profile mode (for performance testing)
flutter run --profile

# Run in release mode
flutter run --release
```

### 3. View Logs
```bash
# View all logs
flutter logs

# Filter logs
flutter logs | grep "flutter"
```

### 4. Useful Flutter Commands
```bash
# Check for updates
flutter upgrade

# Analyze code
flutter analyze

# Format code
flutter format lib/

# Clean build files
flutter clean

# Show device information
flutter devices -v

# Run specific file
flutter run -t lib/main.dart
```

## Testing

### Run Unit Tests
```bash
flutter test
```

### Run Integration Tests
```bash
flutter drive --target=test_driver/app.dart
```

### Run with Coverage
```bash
flutter test --coverage
```

## App Configuration

### Change App Name
1. Android: `android/app/src/main/AndroidManifest.xml`
2. iOS: `ios/Runner/Info.plist`

### Change App Icon
1. Replace files in `assets/icons/`
2. Use flutter_launcher_icons package:
```bash
flutter pub run flutter_launcher_icons:main
```

### Change Package Name
Use the `change_app_package_name` package:
```bash
flutter pub run change_app_package_name:main com.yourcompany.appname
```

## Environment-Specific Configuration

### Development
Use the default configuration in `app_config.dart`

### Production
Create a production configuration:
```dart
// lib/core/config/app_config_prod.dart
class AppConfig {
  static const String supabaseUrl = 'PROD_URL';
  static const String supabaseAnonKey = 'PROD_KEY';
}
```

## Next Steps

1. ✅ Run the app on an emulator/device
2. ✅ Test all features (cart, checkout, auth)
3. ✅ Customize theme colors if needed
4. ✅ Add your own app icon and splash screen
5. ✅ Test on both Android and iOS
6. ✅ Build release versions
7. ✅ Submit to app stores

## Getting Help

- Flutter Docs: https://flutter.dev/docs
- Supabase Docs: https://supabase.com/docs
- Stack Overflow: https://stackoverflow.com/questions/tagged/flutter

## Support

For issues specific to Near & Now app:
- Email: support@nearandnow.com
- GitHub Issues: (if applicable)

---

Happy coding! 🚀

