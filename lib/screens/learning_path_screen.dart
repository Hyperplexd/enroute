import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/commute_provider.dart';
import '../providers/learning_provider.dart';
import '../providers/profile_provider.dart';
import '../models/podcast.dart';

class LearningPathScreen extends StatelessWidget {
  const LearningPathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final commuteProvider = Provider.of<CommuteProvider>(context);
    final learningProvider = Provider.of<LearningProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              padding: const EdgeInsets.all(16),
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
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    iconSize: 24,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.shade800,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Learning Path',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),
            
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Commute Status Indicator
                    Row(
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
                            const TextSpan(text: ' minutes'),
                          ],
                        ),
                      ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Headline
                    const Text(
                      'What\'s the goal today?',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Select a path to generate your custom podcast for this ride.',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSubDark,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Card 1: Explore Topics
                    _buildLearningCard(
                      context: context,
                      imageUrl: 'https://images.unsplash.com/photo-1557683316-973673baf926?w=800&q=80',
                      badge: 'Flexible Learning',
                      title: 'Explore Topics',
                      icon: Icons.explore,
                      description: 'Dive into casual interests like History, Tech, or Science. Perfect for a relaxed ride.',
                      avatars: const [
                        {'color': Colors.blue, 'label': 'H'},
                        {'color': Colors.purple, 'label': 'T'},
                        {'color': Colors.orange, 'label': 'S'},
                      ],
                      buttonText: 'Start',
                      onPressed: () async {
                        learningProvider.selectPath(
                          LearningPathType.exploreTopic,
                          'Explore Topics',
                        );
                        
                        // Show generating dialog
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => _buildGeneratingDialog(),
                        );
                        
                        await learningProvider.generatePodcast(
                          commuteProvider.commuteTimeMinutes,
                        );
                        
                        // Add to podcast history
                        final podcast = Podcast(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: learningProvider.podcastTitle,
                          category: learningProvider.podcastCategory,
                          durationSeconds: learningProvider.totalTimeSeconds,
                          createdAt: DateTime.now(),
                          type: PodcastType.exploreTopic,
                          topic: 'Explore Topics',
                        );
                        profileProvider.addPodcastToHistory(podcast);
                        
                        if (context.mounted) {
                          Navigator.pop(context); // Close dialog
                          Navigator.pushNamed(context, '/podcast-player');
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // Card 2: Micro-Degrees
                    _buildLearningCard(
                      context: context,
                      imageUrl: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800&q=80',
                      badge: 'Certificate Ready',
                      title: 'Micro-Degrees',
                      icon: Icons.school,
                      description: 'Follow a curriculum like LinkedIn Assessments or edX. Earn certificates on the go.',
                      footer: const Row(
                        children: [
                          Icon(Icons.timer, size: 14, color: AppTheme.textSubDark),
                          SizedBox(width: 4),
                          Text(
                            '~30m left in module',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSubDark,
                            ),
                          ),
                        ],
                      ),
                      buttonText: 'Resume',
                      isPrimary: false,
                      onPressed: () async {
                        learningProvider.selectPath(
                          LearningPathType.microDegree,
                          'Micro-Degrees',
                        );
                        
                        // Show generating dialog
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => _buildGeneratingDialog(),
                        );
                        
                        await learningProvider.generatePodcast(
                          commuteProvider.commuteTimeMinutes,
                        );
                        
                        // Add to podcast history
                        final podcast = Podcast(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: learningProvider.podcastTitle,
                          category: learningProvider.podcastCategory,
                          durationSeconds: learningProvider.totalTimeSeconds,
                          createdAt: DateTime.now(),
                          type: PodcastType.microDegree,
                          topic: 'Micro-Degrees',
                        );
                        profileProvider.addPodcastToHistory(podcast);
                        
                        if (context.mounted) {
                          Navigator.pop(context); // Close dialog
                          Navigator.pushNamed(context, '/podcast-player');
                        }
                      },
                    ),
                    
                    // Footer Text
                    const SizedBox(height: 24),
                    const Center(
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSubDark,
                          ),
                          children: [
                            TextSpan(text: 'Your preferences help AI curate better content. '),
                            TextSpan(
                              text: 'Edit Preferences',
                              style: TextStyle(
                                color: AppTheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Navigation
            Container(
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
                  _buildNavItem(Icons.home, 'Home', true, () {
                    Navigator.pushReplacementNamed(context, '/degrees');
                  }),
                  _buildNavItem(Icons.explore, 'Explore', false, () {
                    Navigator.pushReplacementNamed(context, '/explore');
                  }),
                  _buildNavItem(Icons.create, 'Create', false, () {
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
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLearningCard({
    required BuildContext context,
    required String imageUrl,
    required String badge,
    required String title,
    required IconData icon,
    required String description,
    List<Map<String, dynamic>>? avatars,
    Widget? footer,
    required String buttonText,
    bool isPrimary = true,
    required VoidCallback onPressed,
  }) {
    return Container(
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
          // Image Section
          Container(
            height: 160,
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
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          
          // Content Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Icon(
                      icon,
                      color: AppTheme.primary,
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSubDark,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Footer Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Avatars or Footer Widget
                    Expanded(
                      child: avatars != null
                          ? Row(
                              children: avatars
                                  .map((avatar) => Container(
                                        margin: const EdgeInsets.only(right: 4),
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: avatar['color'] as Color,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppTheme.surfaceDark,
                                            width: 2,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          avatar['label'] as String,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            )
                          : (footer ?? const SizedBox()),
                    ),
                    
                    // Button
                    ElevatedButton(
                      onPressed: onPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPrimary ? AppTheme.primary : Colors.transparent,
                        foregroundColor: isPrimary ? Colors.white : AppTheme.primary,
                        side: isPrimary
                            ? null
                            : const BorderSide(color: AppTheme.primary),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        elevation: isPrimary ? 4 : 0,
                        shadowColor: isPrimary ? AppTheme.primary.withOpacity(0.2) : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                      ),
                      child: Text(
                        buttonText,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
  
  Widget _buildGeneratingDialog() {
    return Dialog(
      backgroundColor: AppTheme.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppTheme.primary,
            ),
            SizedBox(height: 24),
            Text(
              'Generating Your Podcast',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'AI is crafting the perfect learning experience for your commute...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSubDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

