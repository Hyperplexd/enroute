import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class DialogueEntry {
  final String speaker;
  final String text;
  final bool isMan;

  DialogueEntry({
    required this.speaker,
    required this.text,
    required this.isMan,
  });
}

class TranscriptModal extends StatefulWidget {
  const TranscriptModal({super.key});

  @override
  State<TranscriptModal> createState() => _TranscriptModalState();
}

class _TranscriptModalState extends State<TranscriptModal> 
    with SingleTickerProviderStateMixin {
  int _currentDialogueIndex = 0;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isMovingForward = true;
  final Map<int, GlobalKey> _dialogueKeys = {};
  
  // Parsed transcript data from the markdown file
  final List<DialogueEntry> _dialogues = [
    DialogueEntry(
      speaker: 'Host',
      text: 'You know, every time I see a photo of the pyramids, it just blows my mind. What do you think draws people to them so much?',
      isMan: true,
    ),
    DialogueEntry(
      speaker: 'Expert',
      text: 'Honestly, I think it\'s the mystery. I mean, you\'ve got these massive stone structures, perfectly aligned and built without modern machines—something about that just makes you want to know more. Plus, they\'re practically a symbol of ancient Egypt at this point.',
      isMan: false,
    ),
    DialogueEntry(
      speaker: 'Host',
      text: 'Totally. It almost feels like they\'re from another world, even though they\'re right there near busy Cairo. The fact that they\'ve lasted so long just adds to that legendary feel.',
      isMan: true,
    ),
    DialogueEntry(
      speaker: 'Expert',
      text: 'Exactly—it\'s like standing at the edge of two different eras. And that ties right into all the questions people have: who built them, how, and why? Those questions keep people curious generation after generation.',
      isMan: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller first
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    
    // Initialize fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Initialize slide animation
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _focusNode.requestFocus();
    _animationController.forward();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _updateSlideAnimation() {
    setState(() {
      _slideAnimation = Tween<Offset>(
        begin: _isMovingForward 
            ? const Offset(0.0, 0.15) 
            : const Offset(0.0, -0.15),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutCubic,
        ),
      );
    });
  }

  void _nextDialogue() {
    if (_currentDialogueIndex < _dialogues.length - 1) {
      _isMovingForward = true;
      _updateSlideAnimation();
      _animateTransition(() {
        setState(() {
          _currentDialogueIndex++;
        });
        _scrollToActive();
      });
    }
  }

  void _previousDialogue() {
    if (_currentDialogueIndex > 0) {
      _isMovingForward = false;
      _updateSlideAnimation();
      _animateTransition(() {
        setState(() {
          _currentDialogueIndex--;
        });
        _scrollToActive();
      });
    }
  }

  void _animateTransition(VoidCallback onComplete) {
    _animationController.reverse().then((_) {
      onComplete();
      _animationController.forward();
    });
  }

  void _scrollToActive() {
    // Scroll to center the active dialogue after a brief delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final key = _dialogueKeys[_currentDialogueIndex];
        if (key?.currentContext != null) {
          // Use Scrollable.ensureVisible to center the active dialogue
          Scrollable.ensureVisible(
            key!.currentContext!,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            alignment: 0.5, // Center the widget (0.0 = top, 0.5 = center, 1.0 = bottom)
          );
        } else {
          // Fallback: approximate calculation
          final lineHeight = 150.0; // Approximate height per dialogue line
          final totalHeightBeforeActive = _currentDialogueIndex * lineHeight;
          final viewportHeight = _scrollController.position.viewportDimension;
          final targetOffset = totalHeightBeforeActive - (viewportHeight / 2) + (lineHeight / 2);
          
          _scrollController.animateTo(
            targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }
  
  GlobalKey _getDialogueKey(int index) {
    if (!_dialogueKeys.containsKey(index)) {
      _dialogueKeys[index] = GlobalKey();
    }
    return _dialogueKeys[index]!;
  }

  @override
  Widget build(BuildContext context) {
    final currentDialogue = _dialogues[_currentDialogueIndex];
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(11),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(
            color: AppTheme.borderDark,
            width: 1,
          ),
        ),
        child: KeyboardListener(
          focusNode: _focusNode,
          onKeyEvent: (event) {
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.space) {
                _nextDialogue();
              } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                _previousDialogue();
              } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                _nextDialogue();
              }
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 5, bottom: 5),
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
                    Icon(
                      Icons.description,
                      color: AppTheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 7),
                    const Expanded(
                      child: Text(
                        'Transcript',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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
              
              // Lyrics-style Transcript Area
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Stack(
                    children: [
                      Center(
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                            // Previous dialogues (faded, smaller)
                            if (_currentDialogueIndex > 0)
                              ...List.generate(
                                _currentDialogueIndex,
                                (index) => _buildLyricsLine(
                                  _dialogues[index],
                                  isActive: false,
                                  isPrevious: true,
                                ),
                              ),
                            
                            // Current active dialogue (highlighted, large) with animation
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: SlideTransition(
                                position: _slideAnimation,
                                child: _buildLyricsLine(
                                  currentDialogue,
                                  isActive: true,
                                  key: _getDialogueKey(_currentDialogueIndex),
                                ),
                              ),
                            ),
                            
                            // Upcoming dialogues (faded, smaller)
                            if (_currentDialogueIndex < _dialogues.length - 1)
                              ...List.generate(
                                _dialogues.length - _currentDialogueIndex - 1,
                                (index) => _buildLyricsLine(
                                  _dialogues[_currentDialogueIndex + index + 1],
                                  isActive: false,
                                  isUpcoming: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ),
                      // Bottom fade gradient
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 160,
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppTheme.surfaceDark.withOpacity(0.0),
                                  AppTheme.surfaceDark,
                                ],
                              ),
                            ),
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
    );
  }

  Widget _buildLyricsLine(
    DialogueEntry dialogue, {
    required bool isActive,
    bool isPrevious = false,
    bool isUpcoming = false,
    Key? key,
  }) {
    final opacity = isActive ? 1.0 : (isUpcoming ? 0.3 : 0.4);
    final fontSize = isActive ? 18.0 : 14.0;
    final fontWeight = isActive ? FontWeight.w600 : FontWeight.w400;
    final isHost = dialogue.isMan; // Host = isMan = true, Expert = isMan = false
    final textAlign = isHost ? TextAlign.right : TextAlign.left;
    final barColor = isActive ? AppTheme.primary : Colors.grey.shade800;
    final speakerColor = isHost ? AppTheme.primary : Colors.purple;
    
    return Padding(
      key: key,
      padding: EdgeInsets.only(
        bottom: isActive ? 12 : 18,
        top: isActive ? 0 : 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vertical bar segment on the left
          Container(
            width: 4,
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Text content with background
          Expanded(
            child: Opacity(
              opacity: opacity,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isHost ? 20 : 20,
                  vertical: isActive ? 16 : 12,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? (isHost 
                          ? AppTheme.primary.withOpacity(0.1)
                          : Colors.purple.withOpacity(0.1))
                      : Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(12),
                    topRight: const Radius.circular(12),
                    bottomLeft: Radius.circular(isHost ? 12 : 4),
                    bottomRight: Radius.circular(isHost ? 4 : 12),
                  ),
                  border: isActive
                      ? Border.all(
                          color: speakerColor.withOpacity(0.3),
                          width: 1,
                        )
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: isHost ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    // Speaker name (always visible, more prominent)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: speakerColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          dialogue.speaker.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: speakerColor,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Dialogue text (aligned based on speaker)
                    Text(
                      dialogue.text,
                      textAlign: textAlign,
                      style: TextStyle(
                        fontSize: fontSize,
                        color: Colors.white,
                        height: 1.6,
                        fontWeight: fontWeight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

