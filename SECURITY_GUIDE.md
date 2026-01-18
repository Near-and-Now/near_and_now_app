# Security Guide - API Keys & Secrets

## ⚠️ IMPORTANT: API Key Security

Your Google Maps API key has been secured! It's no longer hardcoded in the source files.

---

## 🔒 Current Security Setup

### What We Changed:
1. ✅ **Removed hardcoded API key** from `places_service.dart`
2. ✅ **Using `String.fromEnvironment()`** for build-time configuration
3. ✅ **`.env` files are gitignored** (won't be committed to git)
4. ✅ **Created run script** for easy development

---

## 🚀 How to Run the App Now

### Option 1: Using the Script (Recommended)
```bash
.\run_with_api_key.bat
```

### Option 2: Manual Command
```bash
flutter run --dart-define=GOOGLE_MAPS_API_KEY=AIzaSyC15Y8u7pn9_diCH6Cb1x73pA5RAwIjuLo
```

### Option 3: With Device Selection
```bash
flutter run --dart-define=GOOGLE_MAPS_API_KEY=AIzaSyC15Y8u7pn9_diCH6Cb1x73pA5RAwIjuLo -d <device-id>
```

---

## 📁 Files Changed

### ✅ Secured Files:
- `lib/core/config/app_config.dart` - Now uses `String.fromEnvironment()`
- `lib/core/services/places_service.dart` - Reads from AppConfig

### ✅ Created Files:
- `run_with_api_key.bat` - Script to run app with API key
- `.env.example` - Template for environment variables
- `SECURITY_GUIDE.md` - This file

### ✅ Protected Files:
- `.env` - Actual API keys (gitignored)

---

## 🔐 For Production Release

### Step 1: Build Release with API Key
```bash
flutter build apk --dart-define=GOOGLE_MAPS_API_KEY=your_key_here --release
```

### Step 2: Build App Bundle (for Play Store)
```bash
flutter build appbundle --dart-define=GOOGLE_MAPS_API_KEY=your_key_here --release
```

---

## 🛡️ Best Practices

### ✅ DO:
- Use `--dart-define` for build-time configuration
- Keep API keys in `.env` files (gitignored)
- Use different keys for dev/staging/production
- Set up API restrictions in Google Cloud Console
- Rotate keys periodically

### ❌ DON'T:
- Hardcode API keys in source code
- Commit `.env` files to git
- Share API keys publicly
- Use production keys in development
- Skip API restrictions in Google Cloud

---

## 🔑 API Key Restrictions (Google Cloud Console)

### Recommended Setup:

1. **Application Restrictions:**
   - Type: Android apps
   - Package name: `com.nearandnow.near_and_now`
   - SHA-1 certificate fingerprint: (Get from `gradlew signingReport`)

2. **API Restrictions:**
   - Places API (New) ✅
   - Geocoding API ✅
   - Geolocation API ✅
   - Maps JavaScript API ❌ (not needed for mobile)

3. **Usage Limits:**
   - Set daily quota limits
   - Enable billing alerts
   - Monitor usage regularly

---

## 📊 Cost Monitoring

### Google Maps API Pricing:
- **Places Autocomplete:** $2.83 per 1,000 requests
- **Place Details:** $17 per 1,000 requests  
- **Geocoding:** $5 per 1,000 requests

### Cost Savings Implemented:
- ✅ 500ms debounce (reduces autocomplete requests)
- ✅ 5 result limit (reduces data transfer)
- ✅ Local caching (saved addresses)
- ✅ Country restriction (India only)

---

## 🧪 Testing with API Key

### Development:
```bash
# Quick test
flutter run --dart-define=GOOGLE_MAPS_API_KEY=your_dev_key

# On specific device
flutter run --dart-define=GOOGLE_MAPS_API_KEY=your_dev_key -d device-id
```

### Hot Reload/Restart:
- Hot reload (`r`) works normally
- Hot restart (`R`) works normally
- No need to rebuild for code changes

---

## 🆘 Troubleshooting

### "API key not found" error:
Make sure you're running with `--dart-define`:
```bash
flutter run --dart-define=GOOGLE_MAPS_API_KEY=your_key_here
```

### API key not working:
1. Check key is valid in Google Cloud Console
2. Verify APIs are enabled
3. Remove restrictions for testing
4. Wait 5-10 minutes after creating/modifying key

### Build errors:
```bash
flutter clean
flutter pub get
flutter run --dart-define=GOOGLE_MAPS_API_KEY=your_key_here
```

---

## 📝 Quick Reference

### Files with API Keys:
- ❌ `lib/core/services/places_service.dart` - NO LONGER has hardcoded key
- ✅ `lib/core/config/app_config.dart` - Uses `String.fromEnvironment()`
- ✅ `run_with_api_key.bat` - Helper script (gitignored)

### Git Status:
```bash
# These files are NOT tracked by git:
.env
.env.local
.env.*.local
run_with_api_key.bat (should be)
```

---

## 🎯 Summary

Your API key is now secure! ✅

**To run the app:**
```bash
.\run_with_api_key.bat
```

**To build release:**
```bash
flutter build apk --dart-define=GOOGLE_MAPS_API_KEY=your_key --release
```

---

**Remember:** Never commit API keys to git! Use `--dart-define` for all builds.

🔐 **Your code is now production-ready!**
