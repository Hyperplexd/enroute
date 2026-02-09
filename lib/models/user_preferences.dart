class UserPreferences {
  final List<String> favoriteTopics;
  final String preferredDifficulty;
  final double preferredPlaybackSpeed;
  final bool autoGeneratePodcast;
  final List<String> completedTopics;
  final Map<String, int> topicProgress;

  UserPreferences({
    this.favoriteTopics = const [],
    this.preferredDifficulty = 'intermediate',
    this.preferredPlaybackSpeed = 1.0,
    this.autoGeneratePodcast = false,
    this.completedTopics = const [],
    this.topicProgress = const {},
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      favoriteTopics: List<String>.from(json['favoriteTopics'] ?? []),
      preferredDifficulty: json['preferredDifficulty'] ?? 'intermediate',
      preferredPlaybackSpeed: json['preferredPlaybackSpeed'] ?? 1.0,
      autoGeneratePodcast: json['autoGeneratePodcast'] ?? false,
      completedTopics: List<String>.from(json['completedTopics'] ?? []),
      topicProgress: Map<String, int>.from(json['topicProgress'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'favoriteTopics': favoriteTopics,
      'preferredDifficulty': preferredDifficulty,
      'preferredPlaybackSpeed': preferredPlaybackSpeed,
      'autoGeneratePodcast': autoGeneratePodcast,
      'completedTopics': completedTopics,
      'topicProgress': topicProgress,
    };
  }

  UserPreferences copyWith({
    List<String>? favoriteTopics,
    String? preferredDifficulty,
    double? preferredPlaybackSpeed,
    bool? autoGeneratePodcast,
    List<String>? completedTopics,
    Map<String, int>? topicProgress,
  }) {
    return UserPreferences(
      favoriteTopics: favoriteTopics ?? this.favoriteTopics,
      preferredDifficulty: preferredDifficulty ?? this.preferredDifficulty,
      preferredPlaybackSpeed: preferredPlaybackSpeed ?? this.preferredPlaybackSpeed,
      autoGeneratePodcast: autoGeneratePodcast ?? this.autoGeneratePodcast,
      completedTopics: completedTopics ?? this.completedTopics,
      topicProgress: topicProgress ?? this.topicProgress,
    );
  }
}

