import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/ai_podcast_service.dart';
import '../providers/commute_provider.dart';
import '../widgets/podcast_generation_modal.dart';

class CreatePodcastScreen extends StatefulWidget {
  const CreatePodcastScreen({super.key});

  @override
  State<CreatePodcastScreen> createState() => _CreatePodcastScreenState();
}

class _CreatePodcastScreenState extends State<CreatePodcastScreen> {
  final TextEditingController _topicController = TextEditingController();
  final AIPodcastService _aiService = AIPodcastService();
  
  String _selectedDifficulty = 'normal';
  bool _isGenerating = false;
  
  final List<String> _difficulties = ['beginner', 'normal', 'advanced'];
  
  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }
  
  Future<void> _generatePodcast() async {
    if (_topicController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a topic'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Get commute duration from provider
    final commuteProvider = Provider.of<CommuteProvider>(context, listen: false);
    final durationMinutes = commuteProvider.commuteTimeMinutes > 0 
        ? commuteProvider.commuteTimeMinutes 
        : 15;
    
    // Show generation modal
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PodcastGenerationModal(
        topic: _topicController.text.trim(),
        durationMinutes: durationMinutes,
        difficulty: _selectedDifficulty,
      ),
    );
    
    setState(() {
      _isGenerating = true;
    });
    
    // Wait a bit to let the modal show and text update
    await Future.delayed(const Duration(seconds: 3));
    
    try {
      final result = await _aiService.generatePodcast(
        topic: _topicController.text.trim(),
        durationMinutes: durationMinutes,
        difficulty: _selectedDifficulty,
      );
      
      if (mounted) {
        // Close the modal
        Navigator.of(context).pop();
        
        setState(() {
          _isGenerating = false;
        });
        
        if (result['success'] == true) {
          // Navigate to podcast player with generated podcast
          Navigator.pushReplacementNamed(
            context,
            '/podcast-player',
            arguments: {
              'title': result['title'],
              'category': result['category'],
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${result['error'] ?? 'Failed to generate podcast'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Close the modal if still open
        Navigator.of(context).pop();
        
        setState(() {
          _isGenerating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated dot grid background
          Positioned.fill(
            child: _AnimatedDotGrid(),
          ),
          // Main content
          SafeArea(
            child: Column(
          children: [
            // Top App Bar
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade800.withOpacity(0.5),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 5,),
                  const Icon(
                    Icons.auto_fix_high,
                    color: AppTheme.primary,
                    size: 25,
                  ),
                  const SizedBox(width: 7),
                  const Expanded(
                    child: Text(
                      'Create Podcast',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Commute Time Display
            Consumer<CommuteProvider>(
              builder: (context, commuteProvider, _) {
                if (commuteProvider.commuteTimeMinutes <= 0) {
                  return const SizedBox.shrink();
                }
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade800.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: AppTheme.textSubDark, // default text color
                          ),
                          children: [
                            const TextSpan(text: 'You have '),
                            TextSpan(
                              text: '${commuteProvider.commuteTimeMinutes}',
                              style: const TextStyle(
                                color: AppTheme.primary, // only this part colored
                              ),
                            ),
                            const TextSpan(text: ' minutes to destination'),
                          ],
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/commute-setup');
                        },
                        icon: const Icon(Icons.edit, size: 16),
                        color: AppTheme.primary,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minHeight: 0,
                          minWidth: 0,
                        ),
                        splashRadius: 16,
                        tooltip: 'Edit commute',
                      ),
                    ],
                  ),
                );
              },
            ),
            
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const Text(
                      'Generate a Podcast for your Commute',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Tell us what you want to learn, and AI will create a personalized podcast just for you',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSubDark,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Topic Input
                    const Text(
                      'Podcast Topic',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        color: AppTheme.backgroundDark,
                        border: Border.all(
                          color: AppTheme.borderDark,
                          width: 1,
                        )
                      ),
                      child: TextField(
                        controller: _topicController,
                        style: const TextStyle(color: Colors.white),
                        minLines: 4,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText:
                              'What do you want to learn on this trip? \neg. "How Bitcoin actually works"',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontStyle: FontStyle.italic,
                          ),
                          filled: true,
                          fillColor: AppTheme.surfaceDark,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Difficulty Selection
                    const Text(
                      'Difficulty Level',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _difficulties.map((difficulty) {
                        final isSelected = _selectedDifficulty == difficulty;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3), // spacing between buttons
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedDifficulty = difficulty;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSelected ? const Color.fromARGB(255, 231, 230, 229) : AppTheme.surfaceDark,
                                foregroundColor: isSelected ? AppTheme.textMainLight : AppTheme.textSubDark,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                  
                                ),
                              ),
                              child: Text(
                                difficulty[0].toUpperCase() + difficulty.substring(1),
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),
                    
                    // Generate Button
SizedBox(
  width: double.infinity,
  child: InkWell(
    onTap: _isGenerating ? null : _generatePodcast,
    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 255, 172, 18), // bright orange
            Color.fromARGB(255, 228, 114, 0), // medium orange
            Color(0xFFFF4500), // deep orange/red
            Color.fromARGB(255, 194, 107, 0), // lighter orange pop
          ],
          stops: [0.0, 0.3, 0.7, 1.0], // uneven stops for fluid effect
        ),
        boxShadow: [
          const BoxShadow(
            color: Color.fromARGB(142, 254, 90, 19),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: _isGenerating
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_fix_high, size: 24, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Generate Podcast',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    ),
  ),
),
                    const SizedBox(height: 16),
                    
                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceDark.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(
                          color: AppTheme.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'AI will create an engaging, educational podcast tailored to your preferences.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSubDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Navigation
            _buildBottomNav(context),
            ],
          ),
        ),
        ],
      ),
    );
  }
  
  Widget _buildBottomNav(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade800.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, 'Home', false, () {
            Navigator.pushReplacementNamed(context, '/degrees');
          }),
          _buildNavItem(Icons.explore, 'Explore', false, () {
            Navigator.pushReplacementNamed(context, '/explore');
          }),
          _buildNavItem(Icons.auto_fix_high, 'Create', true, () {}),
          _buildNavItem(Icons.library_music, 'Library', false, () {
            Navigator.pushReplacementNamed(context, '/library');
          }),
          _buildNavItem(Icons.person, 'Profile', false, () {
            Navigator.pushReplacementNamed(context, '/profile');
          }),
        ],
      ),
    );
  }
  
  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? AppTheme.primary : AppTheme.textSubDark,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isActive ? AppTheme.primary : AppTheme.textSubDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedDotGrid extends StatefulWidget {
  const _AnimatedDotGrid();

  @override
  State<_AnimatedDotGrid> createState() => _AnimatedDotGridState();
}

class _AnimatedDotGridState extends State<_AnimatedDotGrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _DotGridPainter(_controller),
        size: Size.infinite,
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  final AnimationController controller;

  _DotGridPainter(this.controller) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    const dotSpacing = 30.0;
    const dotSize = 1.5;
    const opacity = 0.08;

    // 1. Define the amount of "glow" blur
    const glowRadius = 5.0; 

    for (double x = dotSpacing; x < size.width; x += dotSpacing) {
      for (double y = dotSpacing; y < size.height; y += dotSpacing) {
        final offset = (x + y) / dotSpacing;
        final phase = (controller.value * 2 * math.pi) + (offset * 0.5);
        
        // Calculate opacity as before
        final rawOpacity = (0.5 + 0.5 * (1 + math.sin(phase))) * opacity;
        
        // 2. Clamp opacity securely between 0.0 and 1.0
        // Note: Increased the cap slightly so the glow is visible
        final safeOpacity = rawOpacity.clamp(0.0, 1.0);

        final dotPaint = Paint()
          ..color = Colors.white.withOpacity(safeOpacity)
          // 3. Add the MaskFilter
          // BlurStyle.solid draws the circle opaque AND the blur around it
          ..maskFilter = const MaskFilter.blur(BlurStyle.solid, glowRadius);

        canvas.drawCircle(
          Offset(x, y),
          dotSize,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter oldDelegate) => true;
}

