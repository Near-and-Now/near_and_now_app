# 📱 Android Setup Guide

## 🚀 Quick Setup (3 Steps)

### Step 1: Install Android Studio ✅ (Installing now...)

```bash
brew install --cask android-studio
```

This will take 5-10 minutes to download and install.

---

### Step 2: Configure Android Studio

#### A. First Launch
1. Open **Android Studio** from Applications
2. Choose **Standard** installation when asked
3. Wait for SDK downloads to complete (~5-10 minutes)

#### B. Create Virtual Device
1. Click **More Actions** → **Virtual Device Manager**
2. Click **Create Device**
3. Select **Phone** → **Pixel 7** → **Next**
4. Select **System Image** → Choose **API 34** (Latest)
5. Click **Download** next to API 34 (wait for download)
6. Click **Next** → **Finish**

---

### Step 3: Accept Android Licenses

```bash
flutter doctor --android-licenses
```

Press `y` for all licenses.

---

### Step 4: Start Emulator & Run App

```bash
# Start Android Studio and launch your emulator
# OR use command line:

# List available emulators
emulator -list-avds

# Start emulator (replace with your emulator name)
emulator -avd Pixel_7_API_34 &

# Wait 30 seconds for emulator to start, then run app
cd /Users/tiasmondal166/projects/near_and_now_app
flutter run
```

Flutter will automatically detect the Android emulator!

---

## 🎯 Quick Visual Guide

### Creating Emulator in Android Studio:

```
Android Studio
  → More Actions
    → Virtual Device Manager
      → Create Device
        → Pixel 7 → Next
          → API 34 (Download if needed) → Next
            → Finish
              → Click ▶️ to start
```

---

## 📋 Checklist

- [ ] Android Studio installed
- [ ] Android Studio opened and setup complete
- [ ] Virtual Device created (Pixel 7, API 34)
- [ ] Android licenses accepted (`flutter doctor --android-licenses`)
- [ ] Emulator started
- [ ] App running on Android!

---

## ⚡ After Initial Setup

Once set up, running on Android is easy:

```bash
# Option 1: Start from Android Studio
# Open Android Studio → Device Manager → Click ▶️
# Then run: flutter run

# Option 2: Command line
emulator -avd Pixel_7_API_34 &
sleep 30  # Wait for emulator
flutter run

# Option 3: Let Flutter handle it
flutter emulators --launch Pixel_7_API_34
flutter run
```

---

## 🔧 Troubleshooting

### "Unable to locate Android SDK"
```bash
# Set environment variables (add to ~/.zshrc)
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Reload
source ~/.zshrc
```

### "License not accepted"
```bash
flutter doctor --android-licenses
# Press 'y' for all
```

### "Emulator won't start"
```bash
# Check available emulators
flutter emulators

# Launch specific emulator
flutter emulators --launch <emulator_id>

# Or use Android Studio's Device Manager
```

### "Build fails"
```bash
cd /Users/tiasmondal166/projects/near_and_now_app
flutter clean
flutter pub get
flutter run
```

---

## 💡 Pro Tips

1. **First Launch Takes Time**: Emulator takes ~1 minute to boot up first time
2. **Keep Emulator Running**: Leave it open while developing (hot reload works!)
3. **Performance**: Emulator works best with 8GB+ RAM available
4. **Alternative**: Use physical Android device (faster than emulator)

### Using Physical Device:
1. Enable Developer Options on Android phone
2. Enable USB Debugging
3. Connect phone via USB
4. Run `flutter devices` to verify
5. Run `flutter run` - it will install on your phone!

---

## 🎨 What You'll Get

When running on Android:
- ✅ Native Android app
- ✅ Full performance
- ✅ All features working
- ✅ Material Design UI
- ✅ Your green theme (#059669)

---

## 📊 Timeline

| Task | Time |
|------|------|
| Install Android Studio | 5-10 min |
| First launch & SDK setup | 5-10 min |
| Create virtual device | 2-5 min |
| Download system image | 3-5 min |
| Accept licenses | 1 min |
| Start emulator | 1-2 min |
| **Total** | **15-30 min** |

After initial setup: **2 minutes** to start emulator and run app!

---

## ✅ Current Status

- ✅ Android Studio: Installing...
- ⏳ Setup: After install completes
- ⏳ Emulator: After setup
- ⏳ App running: After emulator starts

---

## 🎯 Your Next Steps

**WAIT FOR INSTALL TO COMPLETE** (will show "✅ android-studio was successfully installed!")

Then:

1. **Open Android Studio** from Applications
2. **Complete setup wizard** (Standard installation)
3. **Create virtual device** (Pixel 7, API 34)
4. **Accept licenses**: `flutter doctor --android-licenses`
5. **Start emulator** in Device Manager
6. **Run app**: `flutter run`

---

## 🚀 Quick Command Reference

```bash
# Check Android setup
flutter doctor

# Accept licenses
flutter doctor --android-licenses

# List emulators
flutter emulators
emulator -list-avds

# Start emulator
emulator -avd Pixel_7_API_34 &

# Run app
flutter run

# Build APK
flutter build apk --release
```

---

**Installing Android Studio now... Watch for completion message!** 📦
