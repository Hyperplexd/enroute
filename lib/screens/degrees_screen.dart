import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/commute_provider.dart';
import '../services/ai_podcast_service.dart';
import '../widgets/podcast_generation_modal.dart';

class DegreesScreen extends StatefulWidget {
  const DegreesScreen({super.key});

  @override
  State<DegreesScreen> createState() => _DegreesScreenState();
}

class _DegreesScreenState extends State<DegreesScreen> {
  final TextEditingController _promptController = TextEditingController();
  final FocusNode _promptFocusNode = FocusNode();
  final AIPodcastService _aiService = AIPodcastService();
  bool _isGenerating = false;
  
  final List<String> _examplePrompts = [
    'The dark web',
    'Stoic philosophy',
    'How rockets work',
    'Anything…',
  ];
  
  @override
  void dispose() {
    _promptController.dispose();
    _promptFocusNode.dispose();
    super.dispose();
  }
  
  Future<void> _generatePodcast(String prompt) async {
    if (prompt.isEmpty || prompt == 'Anything…') {
      if (_promptController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a topic'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      prompt = _promptController.text.trim();
    }
    
    // Get commute duration from provider
      final commuteProvider = Provider.of<CommuteProvider>(context, listen: false);
      final durationMinutes = commuteProvider.commuteTimeMinutes > 0 
          ? commuteProvider.commuteTimeMinutes 
          : 23;
      
    // Show generation modal
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PodcastGenerationModal(
        topic: prompt,
        durationMinutes: durationMinutes,
        difficulty: 'intermediate',
      ),
    );
    
    setState(() {
      _isGenerating = true;
    });
    
    // Wait a bit to let the modal show and text update
    await Future.delayed(const Duration(seconds: 3));
    
    try {
      final result = await _aiService.generatePodcast(
        topic: prompt,
        durationMinutes: durationMinutes,
        difficulty: 'intermediate',
      );
      
      if (mounted) {
        // Close the modal
        Navigator.of(context).pop();
        
        setState(() {
          _isGenerating = false;
        });
        
        if (result['success'] == true) {
          Navigator.pushNamed(
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
    final commuteProvider = Provider.of<CommuteProvider>(context);
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              padding: const EdgeInsets.all(7),
              child: Row(
                children: [
                  const Icon(
                    Icons.home,
                    color: AppTheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Home',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Search
                    },
                    icon: const Icon(Icons.search),
                    iconSize: 24,
                  ),
                ],
              ),
            ),
            
            // Commute Time Display
            if (commuteProvider.commuteTimeMinutes > 0)
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
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
                              text: '${commuteProvider.commuteTimeMinutes} mins',
                              style: const TextStyle(
                                color: AppTheme.primary, // only this part colored
                              ),
                            ),
                            const TextSpan(text: ' to destination'),
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
                ),
            
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AI Podcast Input Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                        border: Border.all(
                          color: AppTheme.primary.withOpacity(0.3),
                          width: 1.5,
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.surfaceDark, // base color
                            const Color.fromARGB(255, 115, 60, 37).withOpacity(0.01), // faint primary color
                            AppTheme.surfaceDark.withOpacity(0.95), // very subtle tint
                            const Color.fromARGB(255, 115, 60, 37).withOpacity(0.01), // faint primary color
                          ],
                          stops: [0.0, 0.2, 0.7, 1.0],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Question Text
                        Text.rich(
                          TextSpan(
                            // 1. Define the default style (White)
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            children: [
                              const TextSpan(text: 'Create Your '),
                              
                              // 2. Define the highlighted style
                              TextSpan(
                                text: '${commuteProvider.commuteTimeMinutes} minute',
                                style: const TextStyle(
                                  color: AppTheme.primary, // <--- Change this to your desired highlight color
                                  // Optional: Add glow or shadow if you want it to pop more
                                ),
                              ),
                              
                              const TextSpan(text: ' Podcast about:'),
                            ],
                          ),
                        ),
                          const SizedBox(height: 7),
                          
                          // Example Prompt Cards
                          SizedBox(
                            height: 40,
                            child: ShaderMask(
                              shaderCallback: (rect) {
                                return LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.transparent,
                                    Colors.white,
                                    Colors.white,
                                    Colors.transparent,
                                  ],
                                  stops: [0.0, 0.05, 0.95, 1.0], // adjust how much fades at edges
                                ).createShader(rect);
                              },
                              blendMode: BlendMode.dstIn, // this makes the edges fade
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: _examplePrompts.map((prompt) {
                                  final isLast = prompt == _examplePrompts.last;
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      right: isLast ? 0 : 6,
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        if (isLast) {
                                          _promptFocusNode.requestFocus();
                                        } else {
                                          _generatePodcast(prompt);
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(255, 23, 23, 23).withOpacity(1),
                                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                          border: Border.all(
                                            color: Colors.grey.shade800,
                                            width: 1,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            prompt,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: isLast ? AppTheme.textSubDark : Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          
                          // Text Input Field
                          TextField(
                            controller: _promptController,
                            focusNode: _promptFocusNode,
                            enabled: !_isGenerating,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Enter any topic...',
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              filled: true,
                              fillColor: Colors.black.withOpacity(1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                borderSide: BorderSide(
                                  color: AppTheme.primary.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade800,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                borderSide: BorderSide(
                                  color: AppTheme.primary,
                                  width: 1.5,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              suffixIcon: _isGenerating
                                  ? const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                                        ),
                                      ),
                                    )
                                  : IconButton(
                                      icon: Transform.rotate(
                                        angle: -0.8, // rotation in radians (~5.7 degrees)
                                        child: const Icon(
                                          Icons.arrow_forward,
                                          size: 25,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                      onPressed: () => _generatePodcast(''),
                                    ),
                            ),
                            onSubmitted: (value) {
                              if (value.trim().isNotEmpty) {
                                _generatePodcast('');
                              }
                            },
                          ),
                          const SizedBox(height: 8),
                          
                          // Reassuring Message
                          Consumer<CommuteProvider>(
                            builder: (context, commuteProvider, _) {
                              final minutes = commuteProvider.commuteTimeMinutes > 0
                                  ? commuteProvider.commuteTimeMinutes
                                  : 23;
                              return RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSubDark,
                                  ),
                                  children: [
                                    TextSpan(text: '✨ We\'ll generate a podcast that fits your '),
                                    TextSpan(
                                      text: '$minutes minute',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(text: ' commute'),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    // Perfect for your trip section
                    Consumer<CommuteProvider>(
                      builder: (context, commuteProvider, _) {
                        final minutes = commuteProvider.commuteTimeMinutes > 0
                            ? commuteProvider.commuteTimeMinutes
                            : 23;
                        
                        // Mock data for podcasts and assessments that fit the commute time
                        final items = _getPerfectFitItems(minutes);
                        
                        if (items.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: AppTheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Perfect for your $minutes min trip',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 190,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: items.map((item) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      right: item == items.last ? 0 : 12,
                                    ),
                                    child: item['type'] == 'podcast'
                                        ? _buildPerfectFitPodcastCard(
                                            title: item['title'] as String,
                                            category: item['category'] as String,
                                            duration: item['duration'] as int,
                                            imageUrl: item['imageUrl'] as String,
                                            onTap: () {},
                                          )
                                        : _buildPerfectFitAssessmentCard(
                                            title: item['title'] as String,
                                            skill: item['skill'] as String,
                                            duration: item['duration'] as int,
                                            difficulty: item['difficulty'] as String,
                                            onTap: () {},
                                          ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        );
                      },
                    ),
                    
                    // Continue Listening Section
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.fiber_smart_record_outlined,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Continue Listening',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8,),
                    
                    SizedBox(
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildContinueListeningCard(
                            title: 'The History of Ancient Rome',
                            author: 'Dan Carlin',
                            progress: 0.65,
                            imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80',
                            onTap: () {},
                          ),
                          const SizedBox(width: 12),
                          _buildContinueListeningCard(
                            title: 'AI and the Future',
                            author: 'Lex Fridman',
                            progress: 0.42,
                            imageUrl: 'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=400&q=80',
                            onTap: () {},
                          ),
                          const SizedBox(width: 12),
                          _buildContinueListeningCard(
                            title: 'Quantum Physics Explained',
                            author: 'Sean Carroll',
                            progress: 0.78,
                            imageUrl: 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=400&q=80',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Trending Podcasts Section
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.trending_up,
                              color: AppTheme.primary,
                              size: 20,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Trending Podcasts',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    
                    _buildTrendingPodcastCard(
                      title: 'Artificial Intelligence & Ethics',
                      description: 'Exploring the moral implications of AI development',
                      category: 'Technology',
                      imageUrl: 'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=800&q=80',
                      color: Colors.blue,
                      trending: true,
                      onTap: () {},
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildTrendingPodcastCard(
                      title: 'Climate Change Solutions',
                      description: 'Innovative approaches to tackling global warming',
                      category: 'Science',
                      imageUrl: 'https://images.unsplash.com/photo-1569163139394-de4798aa62b6?w=800&q=80',
                      color: Colors.green,
                      trending: true,
                      onTap: () {},
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Recently Played
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.history_toggle_off,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Recently Generated',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    
                    _buildRecentPodcastCard(
                      title: 'The Psychology of Decision Making',
                      author: 'Dr. Robert Cialdini',
                      duration: '45 min',
                      imageUrl: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&q=80',
                      onTap: () {},
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildRecentPodcastCard(
                      title: 'Blockchain Revolution',
                      author: 'Don & Alex Tapscott',
                      duration: '52 min',
                      imageUrl: 'https://images.unsplash.com/photo-1639762681485-074b7f938ba0?w=400&q=80',
                      onTap: () {},
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Recommended for You
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.check_circle_outline,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Recommended Topics For You',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    
                    SizedBox(
                      height: 180,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildRecommendedCard(
                            title: 'Neuroscience Basics',
                            author: 'Dr. Andrew Huberman',
                            imageUrl: 'https://images.unsplash.com/photo-1559757175-0eb30cd8c063?w=400&q=80',
                            onTap: () {},
                          ),
                          const SizedBox(width: 12),
                          _buildRecommendedCard(
                            title: 'Philosophy of Mind',
                            author: 'Sam Harris',
                            imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&q=80',
                            onTap: () {},
                          ),
                          const SizedBox(width: 12),
                          _buildRecommendedCard(
                            title: 'Space Exploration',
                            author: 'Neil deGrasse Tyson',
                            imageUrl: 'https://images.unsplash.com/photo-1446776653964-20c1d3a81b06?w=400&q=80',
                            onTap: () {},
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
    );
  }
  
  List<Map<String, dynamic>> _getPerfectFitItems(int commuteMinutes) {
    // Return podcasts and assessments that fit within the commute time
    // In a real app, this would come from a service/API
    final items = <Map<String, dynamic>>[];
    
    // Add podcasts that match the commute time (within 2 minutes tolerance)
    if (commuteMinutes >= 15) {
      items.add({
        'type': 'podcast',
        'title': 'Introduction to Machine Learning',
        'category': 'Technology',
        'duration': commuteMinutes.clamp(15, commuteMinutes),
        'imageUrl': 'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=400&q=80',
      });
    }
    
    if (commuteMinutes >= 20) {
      items.add({
        'type': 'podcast',
        'title': 'The History of Ancient Rome',
        'category': 'History',
        'duration': commuteMinutes.clamp(20, commuteMinutes),
        'imageUrl': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80',
      });
    }
    
    // Add skill assessments
    if (commuteMinutes >= 10) {
      items.add({
        'type': 'assessment',
        'title': 'Python Basics Quiz',
        'skill': 'Programming',
        'duration': commuteMinutes.clamp(10, commuteMinutes),
        'difficulty': 'Beginner',
      });
    }
    
    if (commuteMinutes >= 15) {
      items.add({
        'type': 'assessment',
        'title': 'Data Structures Challenge',
        'skill': 'Computer Science',
        'duration': commuteMinutes.clamp(15, commuteMinutes),
        'difficulty': 'Intermediate',
      });
    }
    
    // Always show at least one item if commute time is set
    if (items.isEmpty && commuteMinutes > 0) {
      items.add({
        'type': 'podcast',
        'title': 'Quick Learning Session',
        'category': 'General',
        'duration': commuteMinutes,
        'imageUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&q=80',
      });
    }
    
    return items;
  }
  
  Widget _buildPerfectFitPodcastCard({
    required String title,
    required String category,
    required int duration,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: AppTheme.borderDark,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusMedium),
                  topRight: Radius.circular(AppTheme.radiusMedium),
                ),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.radiusMedium),
                    topRight: Radius.circular(AppTheme.radiusMedium),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PODCAST',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$duration min',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPerfectFitAssessmentCard({
    required String title,
    required String skill,
    required int duration,
    required String difficulty,
    required VoidCallback onTap,
  }) {
    Color difficultyColor;
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        difficultyColor = Colors.green;
        break;
      case 'intermediate':
        difficultyColor = Colors.orange;
        break;
      case 'advanced':
        difficultyColor = Colors.red;
        break;
      default:
        difficultyColor = AppTheme.primary;
    }
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: AppTheme.borderDark,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusMedium),
                  topRight: Radius.circular(AppTheme.radiusMedium),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    difficultyColor.withOpacity(0.3),
                    difficultyColor.withOpacity(0.1),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.quiz,
                          size: 16,
                          color: difficultyColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ASSESSMENT',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: difficultyColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$duration min',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Horizontal scrollable row with fade
                SizedBox(
                  height: 20, // adjust height to fit your content
                  child: ShaderMask(
                    shaderCallback: (rect) {
                      return LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.white,      // fully visible at start
                          Colors.white,      // fully visible
                          Colors.transparent, // fade at end
                        ],
                        stops: [0.0, 0.85, 1.0], // adjust how much fades
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.dstIn,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // Difficulty / Category
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: difficultyColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              difficulty.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                color: difficultyColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Skill Rank
                          Text(
                            skill,
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.textSubDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
          ],
        ),
      ),
    );
  }
  
  Widget _buildContinueListeningCard({
    required String title,
    required String author,
    required double progress,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: Colors.grey.shade800,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusMedium),
                  bottomLeft: Radius.circular(AppTheme.radiusMedium),
                ),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          author,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSubDark,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey.shade800,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                            minHeight: 4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(progress * 40).toInt()} mins remaining',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.textSubDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTrendingPodcastCard({
    required String title,
    required String description,
    required String category,
    required String imageUrl,
    required Color color,
    required bool trending,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: Colors.grey.shade800,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 140,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusMedium),
                  bottomLeft: Radius.circular(AppTheme.radiusMedium),
                ),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.radiusMedium),
                    bottomLeft: Radius.circular(AppTheme.radiusMedium),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 10,
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (trending) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.local_fire_department,
                            color: Colors.orange,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSubDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecentPodcastCard({
    required String title,
    required String author,
    required String duration,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: Colors.grey.shade800,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    author,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSubDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        duration,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onTap,
              icon: const Icon(
                Icons.play_circle_outline,
                color: AppTheme.primary,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecommendedCard({
    required String title,
    required String author,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: Colors.grey.shade800,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusMedium),
                  topRight: Radius.circular(AppTheme.radiusMedium),
                ),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    author,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSubDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBottomNav(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
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
          _buildNavItem(Icons.home, 'Home', true, () {}),
          _buildNavItem(Icons.explore, 'Explore', false, () {
            Navigator.pushReplacementNamed(context, '/explore');
          }),
          _buildNavItem(Icons.auto_fix_high, 'Create', false, () {
            Navigator.pushReplacementNamed(context, '/create');
          }),
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

