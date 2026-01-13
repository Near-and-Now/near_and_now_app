# Fix API Key Error - REQUEST_DENIED

## Problem

```
❌ Places API error: REQUEST_DENIED - API keys with referer restrictions cannot be used with this API.
```

This happens because your current API key is configured for **website use** (HTTP referrer restrictions), but mobile apps need **Android application restrictions**.

## Solution: Create Separate API Key for Android

### Step 1: Get Your App's SHA-1 Fingerprint

Open Command Prompt (Windows) and run:

```bash
keytool -list -v -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore
```

**Password:** `android`

You'll see output like:
```
SHA1: AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD
```

**Copy the SHA-1 value!**

---

### Step 2: Create New API Key

1. **Go to Google Cloud Console:**
   - https://console.cloud.google.com/apis/credentials

2. **Click "CREATE CREDENTIALS"**
   - Select "API key"

3. **Name it:** "Near & Now - Android App"

---

### Step 3: Configure Android Restrictions

1. **Click "Edit API key"** (on the newly created key)

2. **Under "Application restrictions":**
   - Select **"Android apps"**
   - Click **"Add an item"**
   - Enter:
     - **Package name:** `com.nearandnow.near_and_now`
     - **SHA-1 fingerprint:** Paste the SHA-1 from Step 1
   - Click **"Done"**

---

### Step 4: Set API Restrictions

1. **Under "API restrictions":**
   - Select **"Restrict key"**
   - Click **"Select APIs"**
   - Enable these 3 APIs:
     - ✅ **Places API (New)**
     - ✅ **Geocoding API**
     - ✅ **Geolocation API**

2. **Click "Save"**

---

### Step 5: Enable Required APIs

Make sure these APIs are enabled for your project:

1. Go to: https://console.cloud.google.com/apis/library

2. Search and enable:
   - **Places API (New)** - For autocomplete
   - **Geocoding API** - For address conversion
   - **Geolocation API** - For GPS location

Click "Enable" for each if not already enabled.

---

### Step 6: Wait for Propagation

⏳ **Wait 5-10 minutes** for the changes to take effect.

---

### Step 7: Update the App

Replace the API key in the code:

**File:** `lib/core/services/places_service.dart`

```dart
static const String _apiKey = String.fromEnvironment(
  'GOOGLE_MAPS_API_KEY',
  defaultValue: 'YOUR_NEW_ANDROID_API_KEY', // Put your new key here
);
```

**Or run with:**

```bash
flutter run -d emulator-5554 --dart-define=GOOGLE_MAPS_API_KEY=your_new_android_key
```

---

### Step 8: Hot Restart the App

Press `R` in terminal or restart:

```bash
flutter run -d emulator-5554
```

---

## Quick Test (No Restrictions)

For quick testing, you can temporarily remove restrictions:

1. Go to your API key settings
2. Under "Application restrictions": Select **"None"**
3. Under "API restrictions": Select **"Don't restrict key"**
4. Click "Save"
5. Wait 2-3 minutes
6. Test the app

**⚠️ Remember:** Remove restrictions only for testing! Add them back for production.

---

## Verify It's Working

1. Open app
2. Tap location widget
3. Type "Mumbai" or "Bangalore"
4. You should see suggestions appear! ✅

Console should show:
```
🔍 Searching places: Mumbai
✅ Found 5 suggestions
```

---

## Two API Keys Setup (Recommended)

Keep separate keys for different platforms:

1. **Website Key:**
   - Name: "Near & Now - Website"
   - Restrictions: HTTP referrers (localhost, your domain)
   - Used in: React app

2. **Android Key:**
   - Name: "Near & Now - Android"
   - Restrictions: Android apps (package name + SHA-1)
   - Used in: Flutter app

This is more secure and follows Google's best practices.

---

## Troubleshooting

### Still getting REQUEST_DENIED?

1. **Check SHA-1 is correct:**
   ```bash
   keytool -list -v -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore
   ```

2. **Verify package name:**
   - Check in `android/app/build.gradle.kts`
   - Should be: `com.nearandnow.near_and_now`

3. **Wait longer:**
   - Changes can take up to 10 minutes

4. **Clear app data:**
   - Emulator Settings → Apps → Near & Now → Clear Data

5. **Restart emulator:**
   - Sometimes needed for changes to apply

### Wrong SHA-1?

If you get "SignatureMismatch" error, your SHA-1 might be wrong.

**Get the actual SHA-1 from running app:**
```bash
flutter run -d emulator-5554
```
Then check logs for the actual SHA-1 being used.

---

## Cost Monitoring

Set up billing alerts:
1. https://console.cloud.google.com/billing
2. Click your billing account
3. "Budgets & alerts"
4. Set alert at $50, $100, $150

---

## Summary Checklist

- [ ] Get SHA-1 fingerprint
- [ ] Create new Android API key
- [ ] Add Android restrictions (package name + SHA-1)
- [ ] Restrict to required APIs
- [ ] Enable Places, Geocoding, Geolocation APIs
- [ ] Wait 5-10 minutes
- [ ] Update API key in code
- [ ] Hot restart app
- [ ] Test location search

---

**Need Help?**
- Check console logs for specific errors
- Verify APIs are enabled
- Ensure billing is active
- Try removing restrictions temporarily to isolate issue

---

**Status after fix:** Search should work perfectly! 🎉
