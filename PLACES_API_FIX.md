# 🔧 Google Places API Key Fix

**Issue:** Address search not working  
**Cause:** API key is using placeholder value `'YOUR_ANDROID_API_KEY_HERE'`  
**Status:** Needs your real API key

---

## ✅ Quick Fix Steps

### Step 1: Add Your Real API Key

1. **Open:** `lib/core/services/places_service.dart`
2. **Find line 9:** 
   ```dart
   static const String _apiKey = 'YOUR_ACTUAL_GOOGLE_MAPS_API_KEY_HERE';
   ```
3. **Replace with your real key:**
   ```dart
   static const String _apiKey = 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'; // Your real key
   ```

### Step 2: Hot Reload

In your terminal where Flutter is running, press:
```
R
```
(Capital R for full hot restart)

### Step 3: Test Again

- Open location picker
- Type in search box
- Should now show autocomplete suggestions

---

## 🔑 Where to Get Your API Key

### If You Already Have One:
1. Go to https://console.cloud.google.com/apis/credentials
2. Find your API key for the Near & Now project
3. Copy the key value
4. Paste it in `places_service.dart`

### If You Need to Create One:
1. Go to Google Cloud Console
2. Select your project (or create new)
3. Enable these APIs:
   - Places API (New)
   - Geocoding API
   - Maps JavaScript API
4. Create credentials → API Key
5. Copy the key

---

## ⚠️ Important for Production

**This is a temporary fix for testing!**

For production, you should:
1. Never commit API keys to git
2. Use environment variables or build configurations
3. Add API restrictions:
   - Application restrictions (Android package name + SHA-1)
   - API restrictions (only enable required APIs)

See `API_KEY_SETUP.md` for detailed production setup.

---

## 🧪 How to Test

After adding your key and hot reloading:

1. **Tap location widget** on home screen
2. **Tap search box** in location picker
3. **Type:** "Howrah" or "Salt Lake"
4. **Expected:** 5 autocomplete suggestions appear
5. **Tap any suggestion**
6. **Expected:** Full address loads and picker closes

---

## 🐛 If It Still Doesn't Work

Check these:

### 1. API Key Valid?
- Key copied correctly (no spaces)
- Key is active in Google Cloud Console

### 2. APIs Enabled?
- Places API (New) enabled
- Geocoding API enabled

### 3. Billing Enabled?
- Google Cloud billing account active
- Has credit available

### 4. API Restrictions?
- If testing, set to "None" temporarily
- Or add your Android package name + SHA-1

### 5. Check Console Logs:
In the running terminal, look for errors like:
```
❌ Places API error: REQUEST_DENIED
```
or
```
❌ HTTP error: 403
```

---

## 📞 Next Steps

1. ✅ Add your real API key to `places_service.dart`
2. ✅ Press `R` in terminal to hot restart
3. ✅ Test location search
4. ✅ Report back if working!

---

**File to Edit:** `lib/core/services/places_service.dart`  
**Line to Change:** Line 9  
**What to Add:** Your real Google Maps API key

Let me know once you've added the key and I'll help you test it!
