# 📱 How to Run Your Flutter App

## ✅ Currently Available

You have **2 devices ready** to run the app:
1. **macOS Desktop** (native app)
2. **Chrome Browser** (web app)

---

## 🖥️ **Option 1: Run on macOS (Recommended)**

### One Command:
```bash
cd /Users/tiasmondal166/projects/near_and_now_app
flutter run -d macos
```

### What You Get:
- ✅ Native Mac app window
- ✅ Full performance
- ✅ All features working
- ✅ Best experience for testing

**This is the EASIEST way to test your app right now!**

---

## 🌐 **Option 2: Run in Chrome (Quick Test)**

### One Command:
```bash
cd /Users/tiasmondal166/projects/near_and_now_app
flutter run -d chrome
```

### What You Get:
- ✅ Opens in browser
- ✅ Quick to test
- ⚠️ Some features may not work (camera, location, etc.)
- ⚠️ Not recommended for production

---

## 📱 **Option 3: Run on Android**

Android requires setup first. Choose one method:

### **Method A: Use Android Studio (Recommended)**

#### Step 1: Install Android Studio
```bash
# Download from: https://developer.android.com/studio
# Or install via Homebrew:
brew install --cask android-studio
```

#### Step 2: Open Android Studio
1. Launch Android Studio
2. Go to **More Actions** → **Virtual Device Manager**
3. Click **Create Device**
4. Select **Pixel 7** (or any phone)
5. Select **System Image** (e.g., API 34)
6. Click **Finish**

#### Step 3: Start Emulator
In Android Studio's Device Manager, click ▶️ play button on your device

#### Step 4: Run Your App
```bash
cd /Users/tiasmondal166/projects/near_and_now_app
flutter run
```

Flutter will automatically detect the Android emulator!

---

### **Method B: Command Line Only**

#### Step 1: Install Android SDK
```bash
# Install Android command-line tools
brew install --cask android-commandlinetools

# Set environment variables (add to ~/.zshrc)
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Reload shell
source ~/.zshrc

# Install SDK packages
sdkmanager "platform-tools" "platforms;android-34" "emulator" "system-images;android-34;google_apis;arm64-v8a"

# Accept licenses
flutter doctor --android-licenses
```

#### Step 2: Create AVD (Android Virtual Device)
```bash
# Create emulator
avdmanager create avd -n Pixel7 -k "system-images;android-34;google_apis;arm64-v8a" -d pixel_7

# List emulators
emulator -list-avds
```

#### Step 3: Start Emulator
```bash
# Start in background
emulator -avd Pixel7 &
```

#### Step 4: Run App
```bash
cd /Users/tiasmondal166/projects/near_and_now_app
flutter run
```

---

## 📱 **Option 4: Run on iOS Simulator (Mac only)**

### Step 1: Install Xcode
```bash
# Install from App Store (it's free but large ~15GB)
# Search for "Xcode" in App Store

# Or use command line:
xcode-select --install
```

### Step 2: Open Simulator
```bash
# Open simulator
open -a Simulator

# Or list available simulators
xcrun simctl list devices
```

### Step 3: Run Your App
```bash
cd /Users/tiasmondal166/projects/near_and_now_app
flutter run
```

---

## 🎯 **Recommended Workflow**

### For Quick Testing:
1. ✅ **Start Here**: Run on macOS (`flutter run -d macos`)
2. ✅ **Quick Web Test**: Run on Chrome if needed
3. ✅ **Mobile Testing**: Set up iOS Simulator (easier than Android)
4. ✅ **Android Later**: Set up Android when you need it

### Time Estimates:
- **macOS**: Ready now (0 minutes) ✅
- **Chrome**: Ready now (0 minutes) ✅
- **iOS Simulator**: 30-60 minutes (Xcode download)
- **Android**: 15-30 minutes (Android Studio)

---

## 🚀 **Quick Commands Reference**

```bash
# Check available devices
flutter devices

# Run on macOS
flutter run -d macos

# Run on Chrome
flutter run -d chrome

# Run on iOS
flutter run -d ios

# Run on Android
flutter run -d android

# Let Flutter choose
flutter run

# See all emulators
flutter emulators

# Start specific emulator
flutter emulators --launch <emulator_id>
```

---

## 💡 **Pro Tips**

### While App is Running:
- Press `r` → Hot reload (instant updates)
- Press `R` → Full restart
- Press `q` → Quit
- Press `h` → Help

### For macOS Development:
- Best for testing during development
- All features work
- Fast compilation
- Native performance

### For iOS:
- Simulator is free (no developer account needed for testing)
- Best for testing iOS-specific features
- Required for App Store submission

### For Android:
- Use Android Studio for easier setup
- Test on multiple device sizes
- Required for Play Store submission

---

## 🎨 **Current Setup**

✅ **Ready to Run**:
- macOS Desktop
- Chrome Browser

⏳ **Need Setup** (Optional):
- iOS Simulator (30-60 min)
- Android Emulator (15-30 min)

---

## 🆘 **Troubleshooting**

### "No devices found"
```bash
# Check what's available
flutter devices

# Run flutter doctor
flutter doctor
```

### macOS app won't start
```bash
cd /Users/tiasmondal166/projects/near_and_now_app
flutter clean
flutter pub get
flutter run -d macos
```

### Android setup issues
```bash
flutter doctor --android-licenses
flutter doctor -v
```

---

## 🎯 **Your Next Command**

**Start with macOS (easiest)**:
```bash
cd /Users/tiasmondal166/projects/near_and_now_app
flutter run -d macos
```

**The app will open in a new window on your Mac!** 🎉

---

## 📊 **Summary**

| Platform | Status | Time to Setup | Recommended |
|----------|--------|---------------|-------------|
| **macOS** | ✅ Ready | 0 min | ⭐⭐⭐⭐⭐ |
| **Chrome** | ✅ Ready | 0 min | ⭐⭐⭐ |
| **iOS** | ⏳ Setup needed | 30-60 min | ⭐⭐⭐⭐ |
| **Android** | ⏳ Setup needed | 15-30 min | ⭐⭐⭐⭐ |

**Recommendation**: Start with macOS today, set up iOS/Android later when needed!

