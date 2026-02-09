import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/commute_provider.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;
  String _selectedCategory = 'All';
  
  final List<String> _categories = [
    'All',
    'Technology',
    'Science',
    'History',
    'Business',
    'Arts',
    'Health',
  ];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted && _tabController.index != _currentTabIndex) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
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
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.explore,
                        color: AppTheme.primary,
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Explore',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Tabs as Buttons
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: Row(
                      children: [
                      Expanded(
                        child: _buildTabButton(
                          label: 'Micro Degrees',
                          isSelected: _currentTabIndex == 0,
                          onTap: () {
                            setState(() {
                              _currentTabIndex = 0;
                            });
                            _tabController.animateTo(0);
                          },
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _buildTabButton(
                          label: 'Generated Podcasts',
                          isSelected: _currentTabIndex == 1,
                          onTap: () {
                            setState(() {
                              _currentTabIndex = 1;
                            });
                            _tabController.animateTo(1);
                          },
                        ),
                      ),
                      ],
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
            
            // Main Content with Tabs
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Micro Degrees Tab
                  _buildMicroDegreesTab(),
                  // Generated Podcasts Tab
                  _buildGeneratedPodcastsTab(),
                ],
              ),
            ),
            
            // Bottom Navigation
            _buildBottomNav(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTopicCard({
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
            // Image Section
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
            // Content Section
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
  
  Widget _buildTopicTile({
    required String title,
    required IconData icon,
    required Color color,
    required int topicCount,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: Colors.grey.shade800,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '$topicCount podcasts',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSubDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTabButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : AppTheme.textSubDark,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildMicroDegreesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Filter
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: AppTheme.surfaceDark,
                    selectedColor: AppTheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textSubDark,
                      fontWeight: FontWeight.w500,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primary : Colors.grey.shade800,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          
          // Featured Degrees
          const Row(
            children: [
              Icon(
                Icons.school,
                color: AppTheme.primary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'FEATURED DEGREES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildTopicCard(
            title: 'Data Science Fundamentals',
            description: 'Master the essentials of data analysis and machine learning',
            category: 'Technology',
            imageUrl: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800&q=80',
            color: Colors.blue,
            trending: true,
            onTap: () {},
          ),
          
          const SizedBox(height: 12),
          
          _buildTopicCard(
            title: 'Digital Marketing Mastery',
            description: 'Learn modern marketing strategies and analytics',
            category: 'Business',
            imageUrl: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800&q=80',
            color: Colors.green,
            trending: true,
            onTap: () {},
          ),
          
          const SizedBox(height: 32),
          
          // Popular Degrees
          const Text(
            'Popular Degrees',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
            children: [
              _buildTopicTile(
                title: 'Web Development',
                icon: Icons.code,
                color: Colors.purple,
                topicCount: 18,
                onTap: () {},
              ),
              _buildTopicTile(
                title: 'UI/UX Design',
                icon: Icons.design_services,
                color: Colors.orange,
                topicCount: 15,
                onTap: () {},
              ),
              _buildTopicTile(
                title: 'Business Analytics',
                icon: Icons.analytics,
                color: Colors.pink,
                topicCount: 22,
                onTap: () {},
              ),
              _buildTopicTile(
                title: 'Project Management',
                icon: Icons.assignment,
                color: Colors.brown,
                topicCount: 12,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildGeneratedPodcastsTab() {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Filter
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        backgroundColor: AppTheme.surfaceDark,
                        selectedColor: AppTheme.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textSubDark,
                          fontWeight: FontWeight.w500,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppTheme.primary : Colors.grey.shade800,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              
              // Trending Now
              const Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'TRENDING NOW',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildTopicCard(
                title: 'Artificial Intelligence & Ethics',
                description: 'Exploring the moral implications of AI development',
                category: 'Technology',
                imageUrl: 'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=800&q=80',
                color: Colors.blue,
                trending: true,
                onTap: () {},
              ),
              
              const SizedBox(height: 12),
              
              _buildTopicCard(
                title: 'Climate Change Solutions',
                description: 'Innovative approaches to tackling global warming',
                category: 'Science',
                imageUrl: 'https://images.unsplash.com/photo-1569163139394-de4798aa62b6?w=800&q=80',
                color: Colors.green,
                trending: true,
                onTap: () {},
              ),
              
              const SizedBox(height: 32),
              
              // Popular Topics
              const Text(
                'Popular Topics',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
                children: [
                  _buildTopicTile(
                    title: 'Space Exploration',
                    icon: Icons.rocket_launch,
                    color: Colors.purple,
                    topicCount: 24,
                    onTap: () {},
                  ),
                  _buildTopicTile(
                    title: 'Blockchain',
                    icon: Icons.link,
                    color: Colors.orange,
                    topicCount: 18,
                    onTap: () {},
                  ),
                  _buildTopicTile(
                    title: 'Psychology',
                    icon: Icons.psychology,
                    color: Colors.pink,
                    topicCount: 32,
                    onTap: () {},
                  ),
                  _buildTopicTile(
                    title: 'Ancient Rome',
                    icon: Icons.temple_hindu,
                    color: Colors.brown,
                    topicCount: 15,
                    onTap: () {},
                  ),
                  _buildTopicTile(
                    title: 'Neuroscience',
                    icon: Icons.science,
                    color: Colors.teal,
                    topicCount: 21,
                    onTap: () {},
                  ),
                  _buildTopicTile(
                    title: 'Philosophy',
                    icon: Icons.lightbulb_outline,
                    color: Colors.indigo,
                    topicCount: 28,
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
        // Generate Podcast Button - Circular, Bottom Right
        Positioned(
          right: 10,
          bottom: 10, // Above bottom nav (72px) + padding (16px)
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/create');
              },
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              child: const Icon(Icons.auto_fix_high, size: 24),
            ),
          ),
        ),
      ],
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
          _buildNavItem(Icons.home, 'Home', false, () {
            Navigator.pushReplacementNamed(context, '/degrees');
          }),
          _buildNavItem(Icons.explore, 'Explore', true, () {}),
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

