# Commute Learning App

Transform your commute into a learning opportunity with AI-powered personalized podcasts.

## Run Flutter in Emulator

To filter out multiple noise sources:

flutter run --verbose | findstr /V "BufferPoolAccessor EGL_emulation"

## Run in browser

flutter run -d chrome

## Flutter run key commands.
- r Hot reload.
- R Hot restart.
- d Detach (terminate "flutter run" but leave application running).
- c Clear the screen
- q Quit (terminate the application on the device).

## 🎯 Overview

Every day, millions of people spend hours commuting without doing anything productive. This Flutter app solves that problem by generating AI-powered podcasts that are:

- **Perfectly Timed**: Automatically matches your exact commute duration
- **Personalized**: Learns your interests and adapts content to your preferences
- **Dynamic**: Generates fresh content for every trip
- **Educational**: Choose between casual topics or structured micro-degrees

## ✨ Features

### 🗺️ Smart Commute Planning
- Google Maps integration for accurate route calculation
- Support for different transport modes (Car, Transit, Walking)
- Saved places for quick access
- Real-time duration estimation

### 🎓 Learning Paths

**Explore Topics**
- Casual learning on subjects like History, Technology, Science
- Perfect for a relaxed commute
- AI-generated content tailored to your interests

**Micro-Degrees**
- Structured learning programs
- Integration with LinkedIn Assessments and edX MicroMasters
- Progress tracking and certificate preparation

### 🎵 Podcast Player
- Beautiful, intuitive player interface
- Variable playback speed (1.0x - 2.0x)
- Skip forward/backward controls
- Transcript access
- Progress tracking

### 👤 User Profile
- Personal learning statistics dashboard
- Podcast history tracking (completed & in-progress)
- Learning streak counter
- Favorite topics management
- Total learning time tracker
- Beautiful gradient avatar

### 🤖 AI-Powered Personalization
- Learns your learning style over time
- Adapts to your comprehension speed
- Recommends relevant topics
- Optimizes content difficulty

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / Xcode
- Google Maps API Key
- AI API Key (OpenAI, Claude, or custom backend)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd commute_learning_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Google Maps API**

   See the detailed [Google Maps API Setup Guide](GOOGLE_MAPS_API_SETUP.md) for complete instructions.

   Quick setup:
   - Get your API key from [Google Cloud Console](https://console.cloud.google.com/)
   - Enable these APIs:
     - Maps SDK for Android/iOS
     - Places API (for autocomplete)
     - Distance Matrix API (for route calculation)
     - Geocoding API (for address lookups)
     - Directions API (for route polylines)
     - Maps Static API (for map preview)

   - Update the API key in:
     - `lib/services/google_maps_service.dart`
     - `android/app/src/main/AndroidManifest.xml`
     - `ios/Runner/AppDelegate.swift`

   **Features**:
   - ✨ Intelligent place autocomplete for origin and destination
   - 🗺️ Real-time route visualization on interactive map
   - 📍 Current location detection with GPS

4. **Configure AI Service**

   - Get your AI API key (OpenAI, Anthropic Claude, or custom)
   - Update `lib/services/ai_podcast_service.dart` with your credentials

5. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Screenshots

### Welcome Screen
Modern onboarding with engaging hero image and gradient text effects.

### Commute Setup
Interactive form with Google Maps autocomplete, transport mode selection, and saved places.

### Learning Path Selection
Beautiful cards showcasing different learning options with visual badges and icons.

### Podcast Player
Full-featured audio player with album art, progress controls, and playback options.

## 🏗️ Project Structure

```
lib/
├── main.dart                      # App entry point
├── theme/
│   └── app_theme.dart            # Theme configuration
├── providers/
│   ├── commute_provider.dart     # Commute state management
│   ├── learning_provider.dart    # Learning & playback state
│   └── profile_provider.dart     # User profile & history
├── screens/
│   ├── welcome_screen.dart       # Onboarding screen
│   ├── commute_setup_screen.dart # Route planning screen
│   ├── learning_path_screen.dart # Learning path selection
│   ├── podcast_player_screen.dart # Audio player screen
│   └── profile_screen.dart       # User profile & stats
├── models/
│   ├── place.dart                # Location models
│   ├── podcast.dart              # Podcast models
│   └── user_preferences.dart     # User settings
├── widgets/
│   ├── custom_button.dart        # Reusable buttons
│   └── loading_dialog.dart       # Loading indicators
└── services/
    ├── google_maps_service.dart  # Google Maps integration
    └── ai_podcast_service.dart   # AI podcast generation
```

## 🔧 Configuration

### Google Maps Setup

**Android**: Update `android/app/src/main/AndroidManifest.xml`
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

**iOS**: Update `ios/Runner/Info.plist`
```xml
<key>GMSApiKey</key>
<string>YOUR_API_KEY_HERE</string>
```

### AI Integration

Update `lib/services/ai_podcast_service.dart`:
```dart
static const String apiKey = 'YOUR_AI_API_KEY';
static const String apiUrl = 'YOUR_AI_API_ENDPOINT';
```

## 🎨 Design

The app uses a modern dark theme with:
- **Primary Color**: #13A4EC (Vibrant Blue)
- **Font**: Lexend (Google Fonts)
- **Design System**: Material Design 3
- **UI Framework**: Flutter

Design inspired by modern audio streaming apps with focus on:
- Clean, minimalist interface
- Smooth animations and transitions
- Intuitive navigation
- Beautiful gradients and shadows

## 🔮 Future Enhancements

- [ ] Offline podcast downloads
- [ ] Multi-language support
- [ ] Social sharing and community features
- [ ] Learning streak tracking
- [ ] Gamification with achievements
- [ ] Integration with more learning platforms
- [ ] Voice control for hands-free operation
- [ ] Smart notifications for commute reminders
- [ ] Analytics dashboard for learning progress

## 📊 Tech Stack

- **Framework**: Flutter
- **State Management**: Provider
- **Navigation**: Named Routes
- **Maps**: Google Maps Flutter
- **Audio**: just_audio
- **HTTP**: http package
- **Fonts**: Google Fonts
- **Storage**: shared_preferences

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

Your Name

## 🙏 Acknowledgments

- Design inspiration from modern audio streaming platforms
- Google Maps for location services
- OpenAI/Anthropic for AI capabilities
- Flutter community for excellent packages

## 📞 Support

For support, email your-email@example.com or open an issue in the repository.

---

**Made with ❤️ for learners who refuse to waste time**

