import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PodcastGenerationModal extends StatefulWidget {
  final String topic;
  final int durationMinutes;
  final String difficulty;

  const PodcastGenerationModal({
    super.key,
    required this.topic,
    required this.durationMinutes,
    required this.difficulty,
  });

  @override
  State<PodcastGenerationModal> createState() => _PodcastGenerationModalState();
}

class _PodcastGenerationModalState extends State<PodcastGenerationModal> 
    with SingleTickerProviderStateMixin {
  int _currentTextIndex = 0;
  Timer? _textUpdateTimer;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  // Fake generated text chunks that will be shown progressively
  final List<String> _generatedTextChunks = [
    'Welcome to today\'s podcast. We\'re diving deep into the fascinating world of',
    'Welcome to today\'s podcast. We\'re diving deep into the fascinating world of technology and innovation. Today, we\'ll explore how',
    'Welcome to today\'s podcast. We\'re diving deep into the fascinating world of technology and innovation. Today, we\'ll explore how modern systems work and the principles behind them. Understanding these concepts',
    'Welcome to today\'s podcast. We\'re diving deep into the fascinating world of technology and innovation. Today, we\'ll explore how modern systems work and the principles behind them. Understanding these concepts is crucial for anyone looking to stay ahead in our rapidly evolving digital landscape. Let\'s begin by examining',
    'Welcome to today\'s podcast. We\'re diving deep into the fascinating world of technology and innovation. Today, we\'ll explore how modern systems work and the principles behind them. Understanding these concepts is crucial for anyone looking to stay ahead in our rapidly evolving digital landscape. Let\'s begin by examining the fundamental building blocks that make everything possible. These core principles',
    'Welcome to today\'s podcast. We\'re diving deep into the fascinating world of technology and innovation. Today, we\'ll explore how modern systems work and the principles behind them. Understanding these concepts is crucial for anyone looking to stay ahead in our rapidly evolving digital landscape. Let\'s begin by examining the fundamental building blocks that make everything possible. These core principles form the foundation upon which all advanced technologies are built. As we progress through this episode, you\'ll discover',
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
    
    // Start updating text every 1.5 seconds
    _textUpdateTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (mounted && _currentTextIndex < _generatedTextChunks.length - 1) {
        // Fade out, update text, fade in
        _fadeController.reverse().then((_) {
          if (mounted) {
            setState(() {
              _currentTextIndex++;
            });
            _fadeController.forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _textUpdateTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
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
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.borderDark,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Gemini Icon/Badge
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF4285F4),
                          const Color(0xFF34A853),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Generating with Gemini 3',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.durationMinutes} min • ${widget.difficulty[0].toUpperCase()}${widget.difficulty.substring(1)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSubDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppTheme.textSubDark),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            
            // Topic Display
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundDark,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(
                    color: AppTheme.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.topic,
                      color: AppTheme.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.topic,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Generated Text Preview
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Generating content...',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSubDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    constraints: const BoxConstraints(
                      minHeight: 120,
                      maxHeight: 180,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundDark,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(
                        color: AppTheme.borderDark,
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Text content with fade animation
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              _generatedTextChunks[_currentTextIndex],
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSubDark,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                        // Gradient fade at bottom to suggest more content
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(AppTheme.radiusMedium),
                                bottomRight: Radius.circular(AppTheme.radiusMedium),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppTheme.backgroundDark.withOpacity(0.0),
                                  AppTheme.backgroundDark,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

