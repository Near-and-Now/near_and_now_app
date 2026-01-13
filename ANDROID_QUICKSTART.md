# 🚀 Android Studio Quick Start

## ✅ Step-by-Step Setup (15 minutes)

### Step 1: Open Android Studio
1. Open **Applications** folder
2. Find and open **Android Studio**
3. Wait for it to load (first time takes ~1 minute)

---

### Step 2: Complete Setup Wizard

When Android Studio opens, you'll see a setup wizard:

1. **Welcome Screen**: Click **Next**
2. **Install Type**: Choose **Standard** → Click **Next**
3. **UI Theme**: Choose your preference (Dark/Light) → Click **Next**
4. **Verify Settings**: Click **Next**
5. **License Agreement**: Accept all licenses → Click **Finish**
6. **Downloading Components**: Wait 5-10 minutes for SDK download

☕ Take a break while components download!

---

### Step 3: Create Virtual Device (Emulator)

After download completes:

1. Click **More Actions** (three dots) → **Virtual Device Manager**
2. Click **Create Device** button
3. **Select Hardware**:
   - Category: **Phone**
   - Choose: **Pixel 7**
   - Click **Next**
4. **System Image**:
   - Choose: **API 34** (latest)
   - Click **Download** next to it
   - Wait for download (~500MB, takes 3-5 minutes)
   - Click **Finish** when done
   - Click **Next**
5. **Verify Configuration**:
   - AVD Name: `Pixel_7_API_34` (or leave default)
   - Click **Finish**

✅ Your emulator is now created!

---

### Step 4: Accept Flutter Licenses

Open Terminal and run:

```bash
flutter doctor --android-licenses
```

- Press **`y`** and **Enter** for each license (usually 5-7 licenses)
- Takes about 30 seconds

---

### Step 5: Start Emulator

**Option A: From Android Studio** (Easiest)
1. In Android Studio, find **Device Manager** panel (right side)
2. Find your **Pixel 7** device
3. Click the **▶️ Play button**
4. Wait ~1 minute for emulator to boot up

**Option B: From Terminal**
```bash
emulator -avd Pixel_7_API_34 &
```

Wait until you see the Android home screen appear!

---

### Step 6: Run Your Flutter App! 🎉

In Terminal:

```bash
cd /Users/tiasmondal166/projects/near_and_now_app
flutter run
```

Flutter will:
- Detect the Android emulator
- Build your app (~2 minutes first time)
- Install it on the emulator
- Launch your app!

---

## 🎯 Quick Reference

```bash
# Check devices
flutter devices

# Accept licenses
flutter doctor --android-licenses

# Start emulator (command line)
emulator -avd Pixel_7_API_34 &

# Run app
cd /Users/tiasmondal166/projects/near_and_now_app
flutter run

# Hot reload while running
# Press 'r' in terminal

# Restart app
# Press 'R' in terminal

# Quit
# Press 'q' in terminal
```

---

## 📊 Checklist

- [ ] Android Studio opened
- [ ] Setup wizard completed
- [ ] SDK components downloaded
- [ ] Virtual device created (Pixel 7, API 34)
- [ ] Licenses accepted (`flutter doctor --android-licenses`)
- [ ] Emulator started and showing Android home screen
- [ ] App running with `flutter run`

---

## 🐛 Troubleshooting

### "Unable to locate adb"
```bash
flutter doctor -v
# Follow any suggestions shown
```

### "License not accepted"
```bash
flutter doctor --android-licenses
# Press 'y' for all
```

### Emulator is slow
- Make sure you have at least 4GB RAM available
- Close other applications
- Consider using a physical device instead

### Build fails
```bash
cd /Users/tiasmondal166/projects/near_and_now_app
flutter clean
flutter pub get
flutter run
```

---

## 💡 Pro Tips

1. **Keep Emulator Running**: Don't close it between runs (hot reload is instant!)
2. **Keyboard Shortcuts**:
   - `r` = Hot reload (instant updates!)
   - `R` = Full restart
   - `q` = Quit
3. **Performance**: First build takes ~2 min, subsequent builds are much faster
4. **Multiple Devices**: You can run on multiple devices at once!

---

## ✨ What to Expect

When your app launches, you'll see:
- 🏠 Home screen with your green theme
- 🛍️ Product listings
- 🛒 Shopping cart
- 💳 Checkout flow
- 📱 All features working natively on Android!

---

## 🎯 Current Step

**You are here**: ✅ Android Studio downloaded

**Next**: 
1. Open Android Studio
2. Complete setup wizard (5-10 min)
3. Create emulator (5 min)
4. Run app!

---

**Ready? Open Android Studio from Applications!** 🚀
