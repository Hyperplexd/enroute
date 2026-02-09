class AppConstants {
  // App Info
  static const String appName = 'Commute Learning';
  static const String appTagline = 'Turn your commute into a learning journey';
  
  // Learning Topics
  static const List<String> exploreTopics = [
    'History',
    'Technology',
    'Science',
    'Business',
    'Psychology',
    'Philosophy',
    'Health & Wellness',
    'Arts & Culture',
    'Current Events',
    'Personal Development',
  ];
  
  // Micro-Degree Programs
  static const List<Map<String, String>> microDegreePrograms = [
    {
      'name': 'LinkedIn Assessments',
      'description': 'Professional skill certifications',
      'provider': 'LinkedIn Learning',
    },
    {
      'name': 'edX MicroMasters',
      'description': 'Graduate-level programs',
      'provider': 'edX',
    },
    {
      'name': 'Coursera Specializations',
      'description': 'In-depth skill mastery',
      'provider': 'Coursera',
    },
    {
      'name': 'Google Career Certificates',
      'description': 'Job-ready skills',
      'provider': 'Google',
    },
  ];
  
  // Transport Modes
  static const Map<String, String> transportModes = {
    'car': 'driving',
    'transit': 'transit',
    'walk': 'walking',
  };
  
  // Playback Speeds
  static const List<double> playbackSpeeds = [0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
  
  // Default Values
  static const int defaultCommuteDuration = 30; // minutes
  static const int minCommuteDuration = 5;
  static const int maxCommuteDuration = 180;
  
  // API Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Storage Keys
  static const String keyUserPreferences = 'user_preferences';
  static const String keySavedPlaces = 'saved_places';
  static const String keyLearningHistory = 'learning_history';
  static const String keyPlaybackSpeed = 'playback_speed';
}

