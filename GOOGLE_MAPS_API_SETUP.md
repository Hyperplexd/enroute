# Google Maps API Setup Guide

This guide will help you set up the Google Maps API for the Commute Learning App.

## Prerequisites

- A Google Cloud Platform (GCP) account
- A project created in Google Cloud Console

## Step 1: Create a Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Note your project ID for reference

## Step 2: Enable Required APIs

Navigate to the **APIs & Services** > **Library** section and enable the following APIs:

1. **Maps SDK for Android** (if building for Android)
2. **Maps SDK for iOS** (if building for iOS)
3. **Places API** (for autocomplete functionality)
4. **Distance Matrix API** (for route calculation)
5. **Geocoding API** (for address lookups)
6. **Directions API** (for route polylines and detailed navigation)
7. **Maps Static API** (for map preview images)

## Step 3: Create API Key

1. Go to **APIs & Services** > **Credentials**
2. Click **+ CREATE CREDENTIALS** > **API key**
3. Copy the generated API key
4. **Important**: Click **Restrict Key** to secure it

## Step 4: Restrict Your API Key (Recommended)

### Application Restrictions
- For development: Choose "None"
- For production: Choose "Android apps" or "iOS apps" and add your app's package name/bundle ID

### API Restrictions
Select "Restrict key" and enable only:
- Maps SDK for Android/iOS
- Places API
- Distance Matrix API
- Geocoding API
- Directions API
- Maps Static API

## Step 5: Configure the App

### Update the API Key in Code

Open `lib/services/google_maps_service.dart` and replace the placeholder:

```dart
static const String apiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
```

With your actual API key:

```dart
static const String apiKey = 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
```

### Android Configuration

1. Open `android/app/src/main/AndroidManifest.xml`
2. Add the following inside the `<application>` tag:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

3. Add location permissions if not already present (inside `<manifest>` tag):

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET"/>
```

### iOS Configuration

1. Open `ios/Runner/AppDelegate.swift`
2. Add the import at the top:

```swift
import GoogleMaps
```

3. Add the following inside the `application` function before `return`:

```swift
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```

4. Open `ios/Runner/Info.plist` and add location permissions:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to your location to calculate commute times.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs access to your location to calculate commute times.</string>
```

## Step 6: Enable Billing (Required)

Google Maps Platform requires billing to be enabled:

1. Go to **Billing** in Google Cloud Console
2. Link a billing account to your project
3. Google provides $200 free credit per month, which is sufficient for most development and small-scale usage

### Cost Estimates (as of 2024)
- **Places API Autocomplete**: $2.83 per 1000 requests (after free tier)
- **Distance Matrix API**: $5 per 1000 requests (after free tier)
- **Geocoding API**: $5 per 1000 requests (after free tier)
- **Directions API**: $5 per 1000 requests (after free tier)
- **Maps Static API**: $2 per 1000 requests (after free tier)

The $200/month free credit covers approximately:
- 70,000+ autocomplete requests
- 40,000+ distance calculations
- 40,000+ geocoding requests
- 40,000+ directions requests
- 100,000+ static map loads

## Step 7: Test the Integration

1. Run your Flutter app:
```bash
flutter run
```

2. Navigate to the Commute Setup screen
3. Try typing in the destination field - you should see autocomplete suggestions
4. Click the location icon in the "From" field to get your current location

## Troubleshooting

### API Key Not Working

- Verify the API key is correctly copied
- Check that all required APIs are enabled in Google Cloud Console
- Ensure billing is enabled
- Check API key restrictions aren't blocking your requests
- Wait a few minutes after creating the key (it can take time to propagate)

### Autocomplete Not Showing

- Check your internet connection
- Verify Places API is enabled
- Check the browser/app console for error messages
- Ensure the API key has Places API permissions

### Location Services Not Working

- Grant location permissions when prompted
- Check that location services are enabled on your device
- For iOS simulator, use **Features** > **Location** > **Custom Location**
- For Android emulator, use the location controls in the emulator toolbar

### API Quota Errors

- Check your usage in Google Cloud Console
- Increase quotas if needed (under **APIs & Services** > **Quotas**)
- Monitor your usage to avoid unexpected charges

## Security Best Practices

1. **Never commit API keys to public repositories**
   - Use environment variables for production
   - Add `google_maps_service.dart` to `.gitignore` if needed
   
2. **Use API key restrictions** in production
   - Restrict by application (Android/iOS package name)
   - Restrict by API (only enable what you need)
   
3. **Monitor your usage**
   - Set up billing alerts in Google Cloud Console
   - Regular check API usage reports

4. **For Production: Use Environment Variables**
   
   Create a `lib/config/api_keys.dart`:
   ```dart
   class ApiKeys {
     static const String googleMapsApiKey = String.fromEnvironment(
       'GOOGLE_MAPS_API_KEY',
       defaultValue: 'YOUR_DEFAULT_KEY_FOR_DEV',
     );
   }
   ```
   
   Then use it in `google_maps_service.dart`:
   ```dart
   import '../config/api_keys.dart';
   
   static const String apiKey = ApiKeys.googleMapsApiKey;
   ```

## Additional Resources

- [Google Maps Platform Documentation](https://developers.google.com/maps/documentation)
- [Places API Documentation](https://developers.google.com/maps/documentation/places/web-service)
- [Distance Matrix API Documentation](https://developers.google.com/maps/documentation/distance-matrix)
- [Flutter Google Maps Plugin](https://pub.dev/packages/google_maps_flutter)

## Support

If you encounter issues:
1. Check the [Google Maps Platform Status Dashboard](https://status.cloud.google.com/)
2. Review your Cloud Console logs
3. Check Flutter console for error messages
4. Consult the official documentation

---

**Note**: This app uses the following Flutter packages:
- `google_maps_flutter: ^2.5.0`
- `google_places_flutter: ^2.0.9`
- `flutter_google_places_sdk: ^0.4.2+1`
- `geolocator: ^10.1.0`
- `geocoding: ^2.1.1`

Make sure these are installed by running:
```bash
flutter pub get
```

