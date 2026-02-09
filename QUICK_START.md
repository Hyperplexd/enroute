# Quick Start Guide

Get your Commute Learning App running in 5 minutes!

## Prerequisites Check

Open a terminal and run:
```bash
flutter doctor
```

✅ All checks should pass. If not, follow Flutter's installation guide.

## 🚀 Steps to Run

### 1. Install Dependencies (2 minutes)

```bash
# Navigate to project directory
cd F:/_SEAGATE_HD/PYTHON/Podcasts

# Install all packages
flutter pub get
```

### 2. Configure API Keys (Optional for initial testing)

The app will run without API keys, but with mock data.

**To enable real features:**

1. **Google Maps** (for route calculation)
   - Get key from: https://console.cloud.google.com/
   - Update in:
     - `android/app/src/main/AndroidManifest.xml` (line with YOUR_GOOGLE_MAPS_API_KEY)
     - `ios/Runner/Info.plist` (GMSApiKey)
     - `lib/services/google_maps_service.dart` (apiKey constant)

2. **AI Service** (for podcast generation)
   - Get key from: https://platform.openai.com/ or https://console.anthropic.com/
   - Update in: `lib/services/ai_podcast_service.dart` (apiKey constant)

### 3. Run the App (1 minute)

**Android:**
```bash
# List available emulators
flutter emulators

# Launch an emulator (replace pixel_6 with your emulator id)
flutter emulators --launch pixel_6

# Run the app
flutter run
```

**iOS (Mac only):**
```bash
# Open iOS simulator
open -a Simulator

# Run the app
flutter run
```

**Physical Device:**
```bash
# Connect device via USB
# Enable USB debugging (Android) or trust computer (iOS)
flutter devices

# Run on connected device
flutter run
```

## ✨ Test the App

1. **Welcome Screen**
   - See the hero image and gradient text
   - Click "Get Started"

2. **Commute Setup**
   - Enter any destination in the "To" field
   - Select a transport mode
   - Click "Calculate Commute Time"

3. **Learning Path**
   - See the calculated commute duration
   - Click "Start" on "Explore Topics"
   - Wait for generation animation

4. **Podcast Player**
   - See the podcast information
   - Click play/pause button
   - Try skip controls
   - Change playback speed

## 🔧 Development Mode Features

- **Hot Reload**: Press `r` in terminal (instant UI updates)
- **Hot Restart**: Press `R` in terminal (full app restart)
- **Quit**: Press `q` in terminal

## 📱 Device Recommendations

**Android:**
- Minimum: Pixel 4 API 30
- Recommended: Pixel 6 API 33

**iOS:**
- Minimum: iPhone 11 (iOS 13)
- Recommended: iPhone 14 (iOS 16)

## 🐛 Troubleshooting

### Problem: "flutter: command not found"
**Solution**: Add Flutter to your PATH or use full path to flutter executable

### Problem: "No devices found"
**Solution**: 
- Android: Start an emulator or connect device with USB debugging
- iOS: Open Simulator app

### Problem: Build fails
**Solution**:
```bash
flutter clean
flutter pub get
flutter run
```

### Problem: "Waiting for another flutter command to release the startup lock"
**Solution**:
```bash
# Delete the lock file
rm -rf $HOME/.flutter/bin/cache/lockfile
```

## 📊 What Works Right Now

✅ All 4 screens with beautiful UI
✅ Navigation between screens
✅ State management with Provider
✅ Mock data for testing
✅ Responsive design
✅ Dark theme
✅ Animations and transitions

## 🔜 What Needs API Keys

⏳ Google Maps autocomplete
⏳ Real route calculation
⏳ Map display
⏳ AI podcast generation
⏳ Audio playback

## 💡 Tips

1. **Work on one screen at a time** - easier to test changes
2. **Use hot reload frequently** - see changes instantly
3. **Check console for errors** - they're usually descriptive
4. **Modify colors in** `lib/theme/app_theme.dart`
5. **Test on multiple screen sizes** - use different emulators

## 📖 Next Steps

After testing the app:

1. Read `SETUP_GUIDE.md` for detailed configuration
2. Read `PROJECT_OVERVIEW.md` to understand the structure
3. Add your API keys to enable real features
4. Customize the theme and content
5. Deploy to App Store / Play Store

## 🎯 Expected Output

When you run `flutter run`, you should see:
```
Launching lib/main.dart on [device] in debug mode...
Running Gradle task 'assembleDebug'...
✓ Built build/app/outputs/flutter-apk/app-debug.apk.
Installing build/app/outputs/flutter-apk/app-debug.apk...
Flutter run key commands.
r Hot reload.
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).

💪 Running with sound null safety 💪

An Observatory debugger and profiler on [device] is available at: http://127.0.0.1:xxxxx/
The Flutter DevTools debugger and profiler on [device] is available at: http://127.0.0.1:xxxxx/
```

## 🚀 You're Ready!

Your app should now be running. Start exploring and building!

---

**Need Help?** Check the full guides:
- `SETUP_GUIDE.md` - Detailed setup instructions
- `PROJECT_OVERVIEW.md` - Project structure and architecture
- `README.md` - Full documentation

