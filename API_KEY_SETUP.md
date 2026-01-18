# Google Maps API Key Setup

## Problem
You're getting `REQUEST_DENIED` errors because the app is running **without the API key**.

## Quick Fix

### Option 1: Use the Batch Script (Easiest)

1. **Edit `run_with_api_key.bat`**:
   ```batch
   set GOOGLE_API_KEY=YOUR_ACTUAL_API_KEY
   ```
   Replace `YOUR_ACTUAL_API_KEY` with your real Google Maps API key.

2. **Run the script**:
   ```bash
   .\run_with_api_key.bat
   ```

### Option 2: Use VS Code Launch Configuration

1. **Edit `.vscode\launch.json`**:
   - Replace `YOUR_API_KEY_HERE` with your actual API key (appears twice)

2. **Run from VS Code**:
   - Press `F5` or click the Run button
   - Select "Near & Now (Development)" from the dropdown

### Option 3: Manual Command Line

Run this command every time:

```bash
flutter run -d <device-id> --dart-define=GOOGLE_MAPS_API_KEY=your_actual_api_key
```

## Why This Happened

Your `app_config.dart` expects the API key to be passed at runtime:

```dart
static const String googleMapsApiKey = String.fromEnvironment(
  'GOOGLE_MAPS_API_KEY',
  defaultValue: '', // Empty = no API key!
);
```

If you run `flutter run` without `--dart-define`, the API key is empty, causing `REQUEST_DENIED` errors.

## Verify It's Working

After running with the API key, you should see:

```
🔍 Searching places: Mumbai
✅ Found 5 suggestions
```

Instead of:

```
❌ Places API error: REQUEST_DENIED
```

## Security Note

- `run_with_api_key.bat` is git-ignored (safe to add your key)
- `.vscode/launch.json` is **NOT** git-ignored by default
  - Either: Add `.vscode/` to `.gitignore`
  - Or: Use the batch script method instead

## Where to Find Your API Key

1. Go to: https://console.cloud.google.com/apis/credentials
2. Look for: "Near & Now - Android App" or similar
3. Copy the API key value

If you don't have an API key, follow the instructions in `FIX_API_KEY_ERROR.md` to create one.
