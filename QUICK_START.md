# 🚀 Quick Start Guide

Get your Flutter Near & Now app running in 5 minutes!

## ✅ Prerequisites Check

```bash
# Check Flutter installation
flutter doctor

# Expected output: All checks should pass ✓
```

## 🏃 Quick Start (3 Commands)

```bash
# 1. Navigate to project
cd /Users/tiasmondal166/projects/near_and_now_app

# 2. Get dependencies
flutter pub get

# 3. Run the app
flutter run
```

That's it! 🎉

## 📱 Choose Your Device

### Android Emulator
```bash
# Start Android emulator from Android Studio, then:
flutter run
```

### iOS Simulator (Mac only)
```bash
# Open simulator
open -a Simulator

# Run app
flutter run
```

### Physical Device
```bash
# List connected devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

## 🔥 Hot Reload

While the app is running:
- Press `r` - Hot reload (fast)
- Press `R` - Hot restart (full restart)
- Press `q` - Quit

## 🐛 Issues?

### Problem: Flutter not found
```bash
# Add Flutter to PATH
export PATH="$PATH:[PATH_TO_FLUTTER_GIT_DIRECTORY]/flutter/bin"
```

### Problem: Dependencies fail
```bash
flutter clean
flutter pub get
```

### Problem: Build fails
```bash
# Android
cd android && ./gradlew clean && cd ..

# iOS
cd ios && pod deintegrate && pod install && cd ..
```

## 📚 Next Steps

1. ✅ Run the app
2. ✅ Test login with OTP
3. ✅ Browse products
4. ✅ Add items to cart
5. ✅ Complete checkout
6. ✅ View orders

## 🎯 Key Files to Know

- `lib/main.dart` - App entry point
- `lib/core/config/app_config.dart` - Configuration
- `lib/core/theme/app_colors.dart` - Colors & theme
- `pubspec.yaml` - Dependencies

## 📖 Full Documentation

- **README.md** - Complete project overview
- **SETUP_GUIDE.md** - Detailed setup instructions
- **MIGRATION_COMPLETE.md** - What changed from React Native

## 💡 Pro Tips

1. Use hot reload (`r`) during development for instant updates
2. Use `flutter run --release` for production testing
3. Use `flutter run --profile` for performance testing
4. Keep `flutter doctor` clean (all checks pass)

## 🎨 Customize

Want to change colors? Edit:
```dart
// lib/core/theme/app_colors.dart
static const Color primary = Color(0xFF059669);
```

Want to change app name? Edit:
```yaml
# pubspec.yaml
name: your_app_name
```

## 🚀 Build for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (Mac only)
flutter build ios --release
```

## ✨ You're Ready!

Your Flutter app is fully functional and ready to go. Happy coding! 🎉

---

**Need Help?**
- Check `SETUP_GUIDE.md` for detailed instructions
- Run `flutter doctor` to diagnose issues
- Check Flutter docs: https://flutter.dev

