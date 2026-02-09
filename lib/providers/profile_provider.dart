import 'package:flutter/foundation.dart';
import '../models/podcast.dart';

class ProfileProvider with ChangeNotifier {
  String _userName = 'John Doe';
  String _userEmail = 'john.doe@example.com';
  String _userAvatar = '';
  
  // Podcast History
  final List<PodcastHistoryItem> _podcastHistory = [];
  
  // Learning Statistics
  int _totalPodcastsCompleted = 0;
  int _totalMinutesLearned = 0;
  int _currentStreak = 0;
  int _longestStreak = 0;
  
  // Favorite Topics
  final List<String> _favoriteTopics = [
    'Technology',
    'Science',
    'History',
  ];
  
  // Getters
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userAvatar => _userAvatar;
  List<PodcastHistoryItem> get podcastHistory => List.unmodifiable(_podcastHistory);
  int get totalPodcastsCompleted => _totalPodcastsCompleted;
  int get totalMinutesLearned => _totalMinutesLearned;
  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  List<String> get favoriteTopics => List.unmodifiable(_favoriteTopics);
  
  // Setters
  void updateUserInfo(String name, String email) {
    _userName = name;
    _userEmail = email;
    notifyListeners();
  }
  
  void updateUserAvatar(String avatarUrl) {
    _userAvatar = avatarUrl;
    notifyListeners();
  }
  
  // Add podcast to history
  void addPodcastToHistory(Podcast podcast, {bool completed = false}) {
    final historyItem = PodcastHistoryItem(
      podcast: podcast,
      listenedAt: DateTime.now(),
      completed: completed,
      progressPercentage: completed ? 100 : 0,
    );
    
    _podcastHistory.insert(0, historyItem); // Add to beginning
    
    if (completed) {
      _totalPodcastsCompleted++;
      _totalMinutesLearned += podcast.durationMinutes;
      _updateStreak();
    }
    
    notifyListeners();
  }
  
  void updatePodcastProgress(String podcastId, double progress) {
    final index = _podcastHistory.indexWhere(
      (item) => item.podcast.id == podcastId,
    );
    
    if (index != -1) {
      _podcastHistory[index] = _podcastHistory[index].copyWith(
        progressPercentage: (progress * 100).toInt(),
        completed: progress >= 1.0,
      );
      
      if (progress >= 1.0 && !_podcastHistory[index].completed) {
        _totalPodcastsCompleted++;
        _totalMinutesLearned += _podcastHistory[index].podcast.durationMinutes;
        _updateStreak();
      }
      
      notifyListeners();
    }
  }
  
  void _updateStreak() {
    // Simple streak calculation - would be more complex in real app
    final today = DateTime.now();
    final lastPodcast = _podcastHistory.firstOrNull?.listenedAt;
    
    if (lastPodcast != null) {
      final difference = today.difference(lastPodcast).inDays;
      
      if (difference <= 1) {
        _currentStreak++;
        if (_currentStreak > _longestStreak) {
          _longestStreak = _currentStreak;
        }
      } else {
        _currentStreak = 1;
      }
    } else {
      _currentStreak = 1;
    }
  }
  
  void addFavoriteTopic(String topic) {
    if (!_favoriteTopics.contains(topic)) {
      _favoriteTopics.add(topic);
      notifyListeners();
    }
  }
  
  void removeFavoriteTopic(String topic) {
    _favoriteTopics.remove(topic);
    notifyListeners();
  }
  
  // Get recent podcasts (last 7 days)
  List<PodcastHistoryItem> getRecentPodcasts() {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return _podcastHistory
        .where((item) => item.listenedAt.isAfter(sevenDaysAgo))
        .toList();
  }
  
  // Get completed podcasts only
  List<PodcastHistoryItem> getCompletedPodcasts() {
    return _podcastHistory.where((item) => item.completed).toList();
  }
  
  // Get in-progress podcasts
  List<PodcastHistoryItem> getInProgressPodcasts() {
    return _podcastHistory
        .where((item) => !item.completed && item.progressPercentage > 0)
        .toList();
  }
}

class PodcastHistoryItem {
  final Podcast podcast;
  final DateTime listenedAt;
  final bool completed;
  final int progressPercentage; // 0-100
  
  PodcastHistoryItem({
    required this.podcast,
    required this.listenedAt,
    required this.completed,
    required this.progressPercentage,
  });
  
  PodcastHistoryItem copyWith({
    Podcast? podcast,
    DateTime? listenedAt,
    bool? completed,
    int? progressPercentage,
  }) {
    return PodcastHistoryItem(
      podcast: podcast ?? this.podcast,
      listenedAt: listenedAt ?? this.listenedAt,
      completed: completed ?? this.completed,
      progressPercentage: progressPercentage ?? this.progressPercentage,
    );
  }
  
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(listenedAt);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${listenedAt.day}/${listenedAt.month}/${listenedAt.year}';
    }
  }
}

