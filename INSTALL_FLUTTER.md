# 📱 Flutter Installation Guide for macOS

Flutter is not yet installed on your system. Follow these steps to install it and run your app.

## 🚀 Quick Install (Recommended)

### Option 1: Using Homebrew (Easiest)

```bash
# Install Flutter using Homebrew
brew install --cask flutter

# Add Flutter to PATH (add to ~/.zshrc or ~/.bash_profile)
export PATH="$PATH:$HOME/flutter/bin"

# Reload shell
source ~/.zshrc  # or source ~/.bash_profile

# Verify installation
flutter --version
```

### Option 2: Manual Installation

```bash
# 1. Download Flutter SDK
cd ~/
git clone https://github.com/flutter/flutter.git -b stable

# 2. Add Flutter to PATH
# Add this line to ~/.zshrc (for Zsh) or ~/.bash_profile (for Bash)
export PATH="$PATH:$HOME/flutter/bin"

# 3. Reload shell
source ~/.zshrc  # or source ~/.bash_profile

# 4. Verify installation
flutter --version
```

## ✅ Post-Installation Setup

### 1. Run Flutter Doctor

```bash
flutter doctor
```

This will show you what's missing. Expected output:
```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.x.x, on macOS 14.x)
[✓] Android toolchain - develop for Android devices
[✓] Xcode - develop for iOS and macOS
[✓] Chrome - develop for the web
[✓] Android Studio
[✓] VS Code
[✓] Connected device
[✓] Network resources
```

### 2. Install Missing Components

#### For Android Development:
```bash
# Install Android Studio from:
# https://developer.android.com/studio

# After installation, open Android Studio and:
# 1. Install Android SDK
# 2. Install Android SDK Command-line Tools
# 3. Accept Android licenses:
flutter doctor --android-licenses
```

#### For iOS Development (Mac only):
```bash
# Install Xcode from App Store
# Then install Xcode command line tools:
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch

# Install CocoaPods
sudo gem install cocoapods
```

## 🎯 Run Your App

Once Flutter is installed:

```bash
# Navigate to your project
cd /Users/tiasmondal166/projects/near_and_now_app

# Get dependencies
flutter pub get

# Check available devices
flutter devices

# Run on Android
flutter run

# Or run on iOS (Mac only)
flutter run -d ios

# Or run on Chrome (for testing only)
flutter run -d chrome
```

## 📱 Set Up Emulator/Simulator

### Android Emulator:
```bash
# Open Android Studio > AVD Manager > Create Virtual Device
# Or use command line:
flutter emulators --launch <emulator_id>
```

### iOS Simulator (Mac only):
```bash
# Open simulator
open -a Simulator

# Or list available simulators
xcrun simctl list devices
```

## 🔧 Verify Flutter Setup

```bash
# Check Flutter installation
flutter doctor -v

# Check for updates
flutter upgrade

# Test Flutter
flutter create test_app
cd test_app
flutter run
```

## ⚡ Expected Timeline

- **Flutter Installation**: 5-10 minutes
- **Android Studio Setup**: 10-15 minutes
- **Xcode Setup** (Mac): 30-60 minutes
- **First App Run**: 2-5 minutes

**Total: ~30-60 minutes** for complete setup

## 📋 Installation Checklist

- [ ] Flutter SDK installed
- [ ] Flutter added to PATH
- [ ] `flutter --version` works
- [ ] `flutter doctor` shows all green ✓
- [ ] Android Studio installed (for Android)
- [ ] Xcode installed (for iOS, Mac only)
- [ ] At least one emulator/simulator available
- [ ] `flutter devices` shows available devices

## 🐛 Common Issues

### Issue: "flutter: command not found"
**Solution**: Add Flutter to PATH
```bash
# Add to ~/.zshrc or ~/.bash_profile
export PATH="$PATH:$HOME/flutter/bin"
source ~/.zshrc
```

### Issue: "Android licenses not accepted"
**Solution**:
```bash
flutter doctor --android-licenses
# Press 'y' to accept all
```

### Issue: "Xcode not configured"
**Solution**:
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

### Issue: "CocoaPods not installed"
**Solution**:
```bash
sudo gem install cocoapods
pod setup
```

## 🎉 Once Installed

Run these commands in sequence:

```bash
# 1. Navigate to project
cd /Users/tiasmondal166/projects/near_and_now_app

# 2. Get dependencies
flutter pub get

# 3. Run the app
flutter run
```

## 📚 Resources

- **Flutter Installation**: https://docs.flutter.dev/get-started/install/macos
- **Flutter Doctor**: https://docs.flutter.dev/get-started/install/macos#run-flutter-doctor
- **Android Setup**: https://docs.flutter.dev/get-started/install/macos#android-setup
- **iOS Setup**: https://docs.flutter.dev/get-started/install/macos#ios-setup

## 💡 Pro Tips

1. **Use VS Code**: Install Flutter and Dart extensions
2. **Use Android Studio**: Better for Android development
3. **Keep Flutter Updated**: Run `flutter upgrade` regularly
4. **Use Hot Reload**: Press `r` while app is running for instant updates

## ⏱️ Quick Command Reference

```bash
# Check version
flutter --version

# Check what's missing
flutter doctor

# Update Flutter
flutter upgrade

# Clean build
flutter clean

# Get dependencies
flutter pub get

# Run app
flutter run

# Build release
flutter build apk --release
```

## 🚀 Next Steps After Installation

1. ✅ Install Flutter
2. ✅ Run `flutter doctor` and fix issues
3. ✅ Navigate to project: `cd /Users/tiasmondal166/projects/near_and_now_app`
4. ✅ Get dependencies: `flutter pub get`
5. ✅ Run the app: `flutter run`
6. ✅ Test all features
7. ✅ Build for production

---

**Need Help?**
- Flutter Discord: https://discord.gg/flutter
- Stack Overflow: https://stackoverflow.com/questions/tagged/flutter
- Flutter Docs: https://docs.flutter.dev

---

**Installation Status**: ❌ Flutter not installed yet

**Your Next Command**: 
```bash
brew install --cask flutter
```

