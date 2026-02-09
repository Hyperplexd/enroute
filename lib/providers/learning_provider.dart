import 'package:flutter/foundation.dart';

enum LearningPathType { exploreTopic, microDegree }

class LearningProvider with ChangeNotifier {
  LearningPathType? _selectedPath;
  String _selectedTopic = '';
  bool _isGenerating = false;
  
  // Podcast details
  final String _podcastTitle = 'The Future of AI';
  final String _podcastCategory = 'Technology & Ethics';
  double _progress = 0.6; // 60% complete
  int _currentTimeSeconds = 724; // 12:04
  int _totalTimeSeconds = 1234; // 20:34
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;
  
  // Getters
  LearningPathType? get selectedPath => _selectedPath;
  String get selectedTopic => _selectedTopic;
  bool get isGenerating => _isGenerating;
  String get podcastTitle => _podcastTitle;
  String get podcastCategory => _podcastCategory;
  double get progress => _progress;
  int get currentTimeSeconds => _currentTimeSeconds;
  int get totalTimeSeconds => _totalTimeSeconds;
  bool get isPlaying => _isPlaying;
  double get playbackSpeed => _playbackSpeed;
  
  String get currentTimeFormatted => _formatTime(_currentTimeSeconds);
  String get remainingTimeFormatted => '-${_formatTime(_totalTimeSeconds - _currentTimeSeconds)}';
  
  void selectPath(LearningPathType path, String topic) {
    _selectedPath = path;
    _selectedTopic = topic;
    notifyListeners();
  }
  
  Future<void> generatePodcast(int durationMinutes) async {
    _isGenerating = true;
    notifyListeners();
    
    // Simulate AI podcast generation
    await Future.delayed(const Duration(seconds: 3));
    
    _totalTimeSeconds = durationMinutes * 60;
    _isGenerating = false;
    notifyListeners();
  }
  
  void togglePlayPause() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }
  
  void updateProgress() {
    if (_isPlaying && _currentTimeSeconds < _totalTimeSeconds) {
      _currentTimeSeconds++;
      _progress = _currentTimeSeconds / _totalTimeSeconds;
      notifyListeners();
    } else if (_currentTimeSeconds >= _totalTimeSeconds) {
      // Reached end, pause
      _isPlaying = false;
      notifyListeners();
    }
  }
  
  void seekTo(double position) {
    _progress = position;
    _currentTimeSeconds = (_totalTimeSeconds * position).toInt();
    notifyListeners();
  }
  
  void skipForward() {
    _currentTimeSeconds = (_currentTimeSeconds + 10).clamp(0, _totalTimeSeconds);
    _progress = _currentTimeSeconds / _totalTimeSeconds;
    notifyListeners();
  }
  
  void skipBackward() {
    _currentTimeSeconds = (_currentTimeSeconds - 10).clamp(0, _totalTimeSeconds);
    _progress = _currentTimeSeconds / _totalTimeSeconds;
    notifyListeners();
  }
  
  void changePlaybackSpeed() {
    if (_playbackSpeed == 1.0) {
      _playbackSpeed = 1.25;
    } else if (_playbackSpeed == 1.25) {
      _playbackSpeed = 1.5;
    } else if (_playbackSpeed == 1.5) {
      _playbackSpeed = 2.0;
    } else {
      _playbackSpeed = 1.0;
    }
    notifyListeners();
  }
  
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

