# Logo Setup Instructions

## Current Status

The app is currently using a placeholder emoji icon (🏪) because the logo image file needs to be added to the project.

## How to Add Your Logo

### Step 1: Save Your Logo Image

1. Save your logo image (the Near & Now shop icon) as `app_logo.png`
2. Recommended image specs:
   - **Format**: PNG with transparency
   - **Size**: 512x512px or 1024x1024px (square)
   - **File size**: < 500KB
   - **Quality**: High resolution for all screen sizes

### Step 2: Add to Assets Folder

Place the logo file in:
```
assets/logo/app_logo.png
```

### Step 3: Update the Code

Once the image is in place, replace the placeholder in `lib/features/home/screens/home_screen.dart`:

**Current placeholder code:**
```dart
// Logo icon using emoji/icon until image is added
Container(
  padding: const EdgeInsets.all(4),
  decoration: BoxDecoration(
    color: AppColors.primary.withOpacity(0.1),
    borderRadius: BorderRadius.circular(8),
  ),
  child: const Text(
    '🏪',
    style: TextStyle(fontSize: 28),
  ),
),
```

**Replace with:**
```dart
Image.asset(
  'assets/logo/app_logo.png',
  height: 36,
  fit: BoxFit.contain,
),
```

### Step 4: Hot Restart

After adding the logo file:
1. Press `R` (capital R) in the terminal running flutter to do a full restart
2. Or stop and restart: `flutter run -d emulator-5554`

## Alternative: Using Network Image

If your logo is already hosted online, you can use it directly:

```dart
CachedNetworkImage(
  imageUrl: 'YOUR_LOGO_URL_HERE',
  height: 36,
  fit: BoxFit.contain,
  placeholder: (context, url) => const Icon(Icons.store, size: 36),
  errorWidget: (context, url, error) => const Icon(Icons.store, size: 36),
),
```

## Troubleshooting

### Image not loading after adding file

1. Make sure the file path is correct: `assets/logo/app_logo.png`
2. Check that `assets/logo/` is declared in `pubspec.yaml` (already done ✓)
3. Do a full restart: Press `R` in terminal
4. If still not working, stop the app and run: `flutter clean && flutter pub get && flutter run`

### RenderFlex overflow error

If you see "RenderFlex overflowed" error:
- The logo + text is too wide for the AppBar
- Solution: Reduce logo height (try 32 or 28)
- Or shorten the tagline text

## Current Display

The app currently shows:
```
🏪  Near & Now
    Digital Dukan, Local Dil Se
```

Once you add the logo image, it will show:
```
[Your Logo]  Near & Now
             Digital Dukan, Local Dil Se
```

## Note

The `pubspec.yaml` already includes the assets folder declaration:
```yaml
flutter:
  assets:
    - assets/logo/
```

So you just need to drop the logo file into the `assets/logo/` folder and do a hot restart!
