# Setup Guide - Commute Learning App

This guide will walk you through setting up the Commute Learning App on your development machine.

## Step 1: Install Flutter

1. Download Flutter SDK from [flutter.dev](https://flutter.dev/docs/get-started/install)
2. Extract the SDK and add to your PATH
3. Run `flutter doctor` to verify installation
4. Install any missing dependencies (Android Studio, Xcode, etc.)

## Step 2: Clone and Install

```bash
# Clone the repository
cd F:/_SEAGATE_HD/PYTHON/Podcasts

# Install dependencies
flutter pub get

# Verify everything is working
flutter doctor -v
```

## Step 3: Google Maps API Setup

### Get Your API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable the following APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Places API
   - Distance Matrix API
   - Directions API
   - Geocoding API

4. Create credentials:
   - Go to "Credentials" tab
   - Click "Create Credentials" → "API Key"
   - Copy your API key
   - (Optional) Restrict the key to your app

### Configure Android

Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Find this section and replace YOUR_GOOGLE_MAPS_API_KEY -->
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ACTUAL_API_KEY_HERE"/>
```

### Configure iOS

Edit `ios/Runner/Info.plist`:

```xml
<!-- Find this section and replace YOUR_GOOGLE_MAPS_API_KEY -->
<key>GMSApiKey</key>
<string>YOUR_ACTUAL_API_KEY_HERE</string>
```

### Configure Service File

Edit `lib/services/google_maps_service.dart`:

```dart
// Replace the API key
static const String apiKey = 'YOUR_ACTUAL_API_KEY_HERE';
```

## Step 4: AI API Setup

You have several options for AI integration:

### Option A: OpenAI

1. Get API key from [platform.openai.com](https://platform.openai.com/)
2. Update `lib/services/ai_podcast_service.dart`:

```dart
static const String apiKey = 'sk-...your-openai-key';
static const String apiUrl = 'https://api.openai.com/v1/chat/completions';
```

### Option B: Anthropic Claude

1. Get API key from [console.anthropic.com](https://console.anthropic.com/)
2. Update `lib/services/ai_podcast_service.dart`:

```dart
static const String apiKey = 'sk-ant-...your-claude-key';
static const String apiUrl = 'https://api.anthropic.com/v1/messages';
```

### Option C: Custom Backend

1. Set up your own backend server
2. Update the service file with your endpoint

## Step 5: Run the App

### Android

```bash
# Start an Android emulator or connect a device
flutter emulators --launch <emulator_id>

# Run the app
flutter run
```

### iOS (Mac only)

```bash
# Open iOS simulator
open -a Simulator

# Run the app
flutter run
```

## Step 6: Test Features

1. **Welcome Screen**: Should load with hero image
2. **Commute Setup**: 
   - Try entering addresses (autocomplete should work)
   - Select transport mode
   - Click "Calculate Commute Time"
3. **Learning Path**: 
   - See commute duration
   - Click on a learning card
   - Watch loading animation
4. **Podcast Player**:
   - See podcast information
   - Test play/pause
   - Test skip controls
   - Test speed control

## Common Issues

### Issue: Google Maps not working

**Solution**: 
- Verify API key is correct
- Check that all required APIs are enabled
- Ensure billing is enabled in Google Cloud Console
- Wait a few minutes after creating the API key

### Issue: Build fails on Android

**Solution**:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Issue: Build fails on iOS

**Solution**:
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter run
```

### Issue: Dependencies conflict

**Solution**:
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

## Development Tips

1. **Hot Reload**: Press `r` in the terminal while the app is running
2. **Hot Restart**: Press `R` for a full restart
3. **Debug Mode**: Use VS Code or Android Studio debugger
4. **Logs**: Use `flutter logs` to see all logs

## Next Steps

1. Implement actual AI podcast generation
2. Add Text-to-Speech integration
3. Implement audio playback with just_audio
4. Add user authentication
5. Set up backend for storing user preferences
6. Implement offline mode

## Production Checklist

Before deploying to production:

- [ ] Replace all API keys with production keys
- [ ] Set up proper API key restrictions
- [ ] Implement proper error handling
- [ ] Add analytics (Firebase, Mixpanel, etc.)
- [ ] Test on multiple devices
- [ ] Optimize images and assets
- [ ] Run `flutter build apk --release` (Android)
- [ ] Run `flutter build ios --release` (iOS)
- [ ] Test the release build thoroughly

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Google Maps Flutter Plugin](https://pub.dev/packages/google_maps_flutter)
- [Provider Package](https://pub.dev/packages/provider)
- [Material Design 3](https://m3.material.io/)

## Support

If you encounter any issues:
1. Check the troubleshooting section above
2. Search for the error on StackOverflow
3. Check Flutter GitHub issues
4. Open an issue in this repository

---

Happy coding! 🚀

