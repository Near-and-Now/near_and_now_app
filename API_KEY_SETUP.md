# API Key Setup Instructions

## ⚠️ IMPORTANT SECURITY NOTICE

The Google Maps API key is currently set as a build-time constant. For production, you should:

1. **Never commit API keys to git**
2. **Use environment variables**
3. **Implement proper key restrictions**

## Current Implementation

The `PlacesService` uses `String.fromEnvironment()` which requires passing the API key at build time.

## Option 1: Build-Time Configuration (Current)

### For Development:

Pass the API key when running:

```bash
flutter run --dart-define=GOOGLE_MAPS_API_KEY=your_api_key_here -d emulator-5554
```

### For Release Build:

```bash
flutter build apk --dart-define=GOOGLE_MAPS_API_KEY=your_api_key_here
```

## Option 2: Environment File (Recommended)

### Setup:

1. Create a `.env` file in project root (already gitignored):

```env
GOOGLE_MAPS_API_KEY=your_api_key_here
```

2. Install `flutter_dotenv` package:

```bash
flutter pub add flutter_dotenv
```

3. Update `pubspec.yaml`:

```yaml
flutter:
  assets:
    - .env
```

4. Load in `main.dart`:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}
```

5. Use in code:

```dart
final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
```

## Option 3: Firebase Remote Config (Production)

For production apps, use Firebase Remote Config to fetch API keys securely.

## Temporary Workaround for Testing

For quick testing, you can temporarily hardcode the key in `places_service.dart`:

```dart
static const String _apiKey = 'your_api_key_here';
```

**BUT REMEMBER TO:**
- Never commit this file with the key
- Remove the key before pushing to git
- Use one of the secure options above

## Google Maps API Key Restrictions

### Set up API restrictions:

1. Go to: https://console.cloud.google.com/apis/credentials
2. Click your API key
3. Under "Application restrictions":
   - For development: Choose "None"
   - For production: Choose "Android apps" and add your app's package name and SHA-1

4. Under "API restrictions":
   - Select "Restrict key"
   - Enable:
     - Maps JavaScript API
     - Places API  
     - Geocoding API
     - Geolocation API

### Get your app's SHA-1 fingerprint:

```bash
# For debug builds
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore

# For release builds
keytool -list -v -alias your-key-alias -keystore your-key.jks
```

## Required APIs

Make sure these are enabled in Google Cloud Console:

1. **Places API** (New) - For autocomplete
2. **Geocoding API** - For address conversion
3. **Geolocation API** - For GPS location

Enable at: https://console.cloud.google.com/apis/library

## Cost Considerations

Google Maps API pricing:
- **Places Autocomplete**: $2.83 per 1,000 requests
- **Place Details**: $17 per 1,000 requests
- **Geocoding**: $5 per 1,000 requests

**$200 free credit per month** (first month)

To minimize costs:
- Implement caching
- Debounce search requests (already implemented: 500ms)
- Limit autocomplete results (already implemented: 5 results)
- Use saved addresses feature

## Security Checklist

- [ ] API key not in git repository
- [ ] Using environment variables or build config
- [ ] API restrictions enabled
- [ ] Application restrictions configured
- [ ] Billing enabled on Google Cloud
- [ ] Cost monitoring set up
- [ ] Rate limiting implemented
- [ ] Caching enabled

## Current Status

✅ Debouncing implemented (500ms)
✅ Result limiting (5 suggestions)
✅ Caching via saved addresses
✅ .env files gitignored
⚠️ API key needs to be set via build config or env file

## Next Steps

1. Choose one of the options above
2. Set up your API key securely
3. Test the location search functionality
4. Configure API restrictions
5. Set up billing alerts in Google Cloud

---

**Remember:** Never expose API keys in client-side code in production!
