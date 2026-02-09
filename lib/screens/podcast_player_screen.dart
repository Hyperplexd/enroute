import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/learning_provider.dart';
import '../providers/commute_provider.dart';
import '../widgets/transcript_modal.dart';

class PodcastPlayerScreen extends StatefulWidget {
  const PodcastPlayerScreen({super.key});

  @override
  State<PodcastPlayerScreen> createState() => _PodcastPlayerScreenState();
}

class _PodcastPlayerScreenState extends State<PodcastPlayerScreen> {
  Timer? _progressTimer;
  final FocusNode _focusNode = FocusNode();
  int? _commuteTimeRemainingSeconds; // null means not synced, static display
  bool _isSynced = false;
  bool _hasShownCompletionDialog = false;

  @override
  void initState() {
    super.initState();
    _startProgressTimer();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _startProgressTimer() {
    _progressTimer?.cancel();
    final learningProvider = Provider.of<LearningProvider>(context, listen: false);
    
    if (learningProvider.isPlaying && learningProvider.totalTimeSeconds > 0) {
      _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        final currentProvider = Provider.of<LearningProvider>(context, listen: false);
        if (!currentProvider.isPlaying) {
          timer.cancel();
          return;
        }
        currentProvider.updateProgress();
        
        // Update commute timer if synced
        if (_isSynced && _commuteTimeRemainingSeconds != null && _commuteTimeRemainingSeconds! > 0) {
          setState(() {
            _commuteTimeRemainingSeconds = _commuteTimeRemainingSeconds! - 1;
          });
        }
        
        // Check if podcast has reached the end
        if (currentProvider.currentTimeSeconds >= currentProvider.totalTimeSeconds && !_hasShownCompletionDialog) {
          _hasShownCompletionDialog = true;
          currentProvider.togglePlayPause(); // Pause the podcast
          timer.cancel();
          
          // Show completion dialog
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showCompletionDialog();
          });
        }
      });
    }
  }
  
  void _showCompletionDialog() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(
                color: AppTheme.borderDark,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primary,
                        AppTheme.primary.withOpacity(0.7),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Title
                const Text(
                  'You have reached your destination!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Message
                Text(
                  'Great job! You\'ve completed your learning journey. Keep up the momentum and turn every commute into a learning opportunity.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSubDark,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      if (mounted) {
                        Navigator.of(context).pop(); // Go back from player screen
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  void _syncCommuteTimer() {
    final commuteProvider = Provider.of<CommuteProvider>(context, listen: false);
    final learningProvider = Provider.of<LearningProvider>(context, listen: false);
    
    if (commuteProvider.commuteTimeMinutes > 0 && learningProvider.totalTimeSeconds > 0) {
      // Sync with 2 second offset: commute timer 2 seconds ahead, progress bar 2 seconds behind
      // This means: commute has 7 seconds left, podcast has 5 seconds left
      final targetCommuteRemaining = 7; // 7 seconds left to commute
      final targetPodcastRemaining = 5; // 5 seconds left for podcast
      
      // Calculate what the current time should be to achieve this
      final targetCurrentTime = learningProvider.totalTimeSeconds - targetPodcastRemaining;
      
      setState(() {
        _commuteTimeRemainingSeconds = targetCommuteRemaining;
        _isSynced = true;
      });
      
      // Adjust progress bar to be 2 seconds behind
      learningProvider.seekTo(targetCurrentTime / learningProvider.totalTimeSeconds);
    }
  }
  
  String _formatCommuteTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) {
      return '${minutes}:${secs.toString().padLeft(2, '0')}';
    }
    return '0:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final title = 'The Pyramids: History\'s Biggest "How Tho?"';
    final category = 'History';

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: KeyboardListener(
          focusNode: _focusNode,
          onKeyEvent: (event) {
            if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyK) {
              _syncCommuteTimer();
            }
          },
          child: Consumer2<LearningProvider, CommuteProvider>(
            builder: (context, learningProvider, commuteProvider, _) {
    // Restart timer if playing state changes
    if (learningProvider.isPlaying && (_progressTimer == null || !_progressTimer!.isActive)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
                _startProgressTimer();
      });
    } else if (!learningProvider.isPlaying) {
      _progressTimer?.cancel();
    }
    
            return Column(
            children: [
              // Header
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.keyboard_arrow_down, size: 32),
                        color: AppTheme.textSubDark,
                    ),
                    Column(
                      children: [
                          Text(
                          'NOW PLAYING',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Your Commute Mix',
                          style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.textSubDark,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                        onPressed: () {
                          // Show options menu
                        },
                      icon: const Icon(Icons.more_horiz),
                        color: AppTheme.textSubDark,
                    ),
                  ],
                ),
              ),
              
              // Main Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        // Album Art with Glow
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxHeight: 400),
                          child: AspectRatio(
                        aspectRatio: 1,
                        child: Stack(
                              alignment: Alignment.center,
                          children: [
                            // Glow Effect
                                Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                        color: AppTheme.primary.withOpacity(0.3),
                                      blurRadius: 60,
                                        spreadRadius: 20,
                                    ),
                                  ],
                                ),
                              ),
                                // Album Art
                            Container(
                                  width: double.infinity,
                                  height: double.infinity,
                              decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                                boxShadow: [
                                  BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                        // Background Image (faded)
                                        Image.asset(
                                          'assets/images/pyramids.png',
                                      fit: BoxFit.cover,
                                          color: Colors.white.withOpacity(0.3),
                                          colorBlendMode: BlendMode.overlay,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                    AppTheme.primary,
                                                    Colors.purple.shade400,
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                        // Dark overlay
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.4),
                                            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                                          ),
                                        ),
                                        // Icon on top
                                        Center(
                                          child: Icon(
                                            Icons.headphones,
                                            size: 120,
                                            color: Colors.white.withOpacity(0.9),
                                          ),
                                        ),
                                    // AI Generated Badge
                                    Positioned(
                                      top: 16,
                                          right: 16,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                              color: AppTheme.primary,
                                          borderRadius: BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppTheme.primary.withOpacity(0.5),
                                                  blurRadius: 8,
                                                  spreadRadius: 2,
                                          ),
                                              ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                                const Icon(
                                                  Icons.auto_fix_high,
                                                  size: 14,
                                                  color: Colors.white,
                                            ),
                                                const SizedBox(width: 4),
                                                Text(
                                              'AI Generated',
                                              style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                    letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                            ),
                        ),
                      ),
                      
                        const SizedBox(height: 12),
                      
                        // Podcast Info
                      Text(
                          title,
                        style: const TextStyle(
                            fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                          category,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.textSubDark,
                        ),
                      ),
                      
                        const SizedBox(height: 10),
                      
                      // Progress Bar
                      Column(
                        children: [
                            // Commute Timer
                            Consumer<CommuteProvider>(
                              builder: (context, commuteProvider, _) {
                                if (commuteProvider.commuteTimeMinutes <= 0) {
                                  return const SizedBox.shrink();
                                }
                                
                                final displayTime = _isSynced && _commuteTimeRemainingSeconds != null
                                    ? _commuteTimeRemainingSeconds!
                                    : commuteProvider.commuteTimeMinutes * 60;
                                
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                    color: AppTheme.surfaceDark,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppTheme.primary.withOpacity(0.3),
                                      width: 1,
                                      ),
                                    ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.timer_outlined,
                                        size: 14,
                                        color: AppTheme.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _formatCommuteTime(displayTime),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'of commute left',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textSubDark,
                                    ),
                                  ),
                                ],
                              ),
                                );
                              },
                          ),
                            // Progress Slider
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: AppTheme.primary,
                                inactiveTrackColor: Colors.grey.shade800,
                                thumbColor: Colors.white,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 8,
                                ),
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 16,
                                ),
                                trackHeight: 4,
                              ),
                              child: Slider(
                                value: learningProvider.progress,
                                onChanged: (value) {
                                  learningProvider.seekTo(value);
                                },
                              ),
                            ),
                          // Timestamps
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                learningProvider.currentTimeFormatted,
                                style: TextStyle(
                                  fontSize: 12,
                                      color: AppTheme.textSubDark,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                learningProvider.remainingTimeFormatted,
                                style: TextStyle(
                                  fontSize: 12,
                                      color: AppTheme.textSubDark,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                              ),
                          ),
                        ],
                      ),
                      
                        const SizedBox(height: 12),
                      
                      // Main Controls
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Shuffle
                          IconButton(
                            onPressed: () {},
                              icon: Icon(
                                Icons.shuffle,
                                color: AppTheme.textSubDark,
                                size: 24,
                          ),
                            ),
                          // Rewind 15s
                          IconButton(
                              onPressed: () {
                                learningProvider.skipBackward();
                              },
                              icon: const Icon(
                                Icons.replay_10,
                                size: 36,
                            color: Colors.white,
                              ),
                          ),
                          // Play/Pause
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                              color: AppTheme.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withOpacity(0.3),
                                  blurRadius: 20,
                                    spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: IconButton(
                                onPressed: () {
                                  learningProvider.togglePlayPause();
                                },
                              icon: Icon(
                                learningProvider.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                  size: 44,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          // Forward 15s
                          IconButton(
                              onPressed: () {
                                learningProvider.skipForward();
                              },
                              icon: const Icon(
                                Icons.forward_10,
                                size: 36,
                            color: Colors.white,
                              ),
                          ),
                          // Repeat
                          IconButton(
                            onPressed: () {},
                              icon: Icon(
                                Icons.repeat,
                                color: AppTheme.textSubDark,
                                size: 24,
                              ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Secondary Controls
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            // Transcript Button
                            TextButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => const TranscriptModal(),
                                );
                              },
                              icon: const Icon(Icons.description, size: 18),
                              label: const Text('Transcript'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.textSubDark,
                              ),
                            ),
                            const SizedBox(width: 24),
                          // Speed Control
                          TextButton.icon(
                              onPressed: () {
                                learningProvider.changePlaybackSpeed();
                              },
                            icon: const Icon(Icons.speed, size: 18),
                            label: Text('${learningProvider.playbackSpeed}x'),
                            style: TextButton.styleFrom(
                                foregroundColor: AppTheme.primary,
                              ),
                            ),
                            const SizedBox(width: 24),
                            // Share Button
                          TextButton.icon(
                              onPressed: () {
                                // Share podcast
                              },
                              icon: const Icon(Icons.share, size: 18),
                              label: const Text('Share'),
                            style: TextButton.styleFrom(
                                foregroundColor: AppTheme.textSubDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
            );
            },
          ),
        ),
      ),
    );
  }
}

