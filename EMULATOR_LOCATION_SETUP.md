# Emulator Location Setup Guide

## Issue
The Android emulator shows location as California (Mountain View - Google's HQ) instead of your actual location because it uses mock GPS data.

## Solutions

### Option 1: Set Custom Location in Android Emulator (Recommended)

1. **Open Extended Controls**:
   - While the emulator is running, click the **"..."** (more) button on the emulator toolbar
   - Or press `Ctrl + Shift + P` (Windows/Linux) or `Cmd + Shift + P` (Mac)

2. **Navigate to Location Settings**:
   - Click on **"Location"** in the left sidebar
   - You'll see a map interface

3. **Set Your Location**:
   
   **Method A: Search for your location**
   - Use the search box at the top
   - Type your city or address
   - Select from the suggestions

   **Method B: Click on map**
   - Click anywhere on the map to set custom coordinates
   - The latitude/longitude will update automatically

   **Method C: Enter coordinates manually**
   - Enter your latitude and longitude in the decimal fields
   - For example, for India:
     - New Delhi: `28.6139, 77.2090`
     - Mumbai: `19.0760, 72.8777`
     - Bangalore: `12.9716, 77.5946`
     - Chennai: `13.0827, 80.2707`

4. **Save the Location**:
   - Click **"SEND"** button to send the location to the emulator
   - The app should now detect your custom location

### Option 2: Use GPX/KML File for Route Simulation

1. Open Extended Controls → Location
2. Click on **"Load GPX/KML"**
3. Select a file with location data
4. Click **"Play"** to simulate movement

### Option 3: Test on Physical Device

For accurate location testing:
1. Connect your Android phone via USB
2. Enable USB Debugging on your phone:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times to enable Developer Options
   - Go to Settings → Developer Options
   - Enable "USB Debugging"
3. Run the app: `flutter run` (it will auto-detect your phone)
4. The app will use your phone's actual GPS location

## Verifying Location Changes

After setting the location in the emulator:
1. Pull down from the top of the home screen to refresh
2. Or restart the app with hot reload: Press `R` in the terminal
3. The location widget should update with your new address

## Common Locations for Testing (India)

```
New Delhi:     28.6139, 77.2090
Mumbai:        19.0760, 72.8777
Bangalore:     12.9716, 77.5946
Chennai:       13.0827, 80.2707
Kolkata:       22.5726, 88.3639
Hyderabad:     17.3850, 78.4867
Pune:          18.5204, 73.8567
Ahmedabad:     23.0225, 72.5714
Jaipur:        26.9124, 75.7873
Lucknow:       26.8467, 80.9462
```

## Persistent Location Setting

The emulator will remember your location settings between sessions. However, if you create a new emulator or reset it, you'll need to set the location again.

## Troubleshooting

### Location not updating in app
1. Make sure you clicked "SEND" in the emulator's location panel
2. Pull to refresh on the home screen
3. Clear the app's data: Settings → Apps → Near & Now → Clear Data
4. Restart the app

### Permission denied
1. Go to emulator Settings → Apps → Near & Now → Permissions
2. Enable Location permission
3. Restart the app

### Still showing California
1. Check if location was properly sent (you should see a toast in emulator)
2. Clear the app cache
3. Try restarting the emulator

## Why Does This Happen?

Android emulators don't have real GPS hardware, so they use:
- **Default location**: Mountain View, CA (37.4219983, -122.084)
- **Mock location provider**: You can set custom coordinates
- **Google Play Services**: Routes location through emulator settings

This is normal behavior and affects all Android apps in the emulator, not just Flutter apps.

## For Production Testing

When testing location-based features:
1. ✅ Test on physical device for real GPS
2. ✅ Test with multiple emulator locations
3. ✅ Test location permission denial scenarios
4. ✅ Test with location services disabled
5. ✅ Test in areas with poor GPS signal (simulated)

The app is designed to handle all these scenarios gracefully with caching and fallback mechanisms.
