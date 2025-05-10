import 'package:flutter/material.dart';
import 'package:immigru/core/di/injection_container.dart';
import 'package:immigru/core/services/logger_service.dart';
import 'package:immigru/domain/entities/user.dart';
import 'package:immigru/domain/usecases/auth_usecases.dart';
import 'package:immigru/domain/usecases/post_usecases.dart';
import 'package:immigru/presentation/screens/home/widgets/app_bar_widget.dart';
import 'package:immigru/presentation/screens/home/widgets/bottom_navigation.dart';
import 'package:immigru/presentation/screens/home/widgets/create_post_dialog.dart';
import 'package:immigru/presentation/screens/home/widgets/floating_action_button_widget.dart';
import 'package:immigru/presentation/screens/home/widgets/tab_navigation.dart';
import 'package:immigru/presentation/screens/home/widgets/all_posts_tab.dart';
import 'package:immigru/presentation/screens/home/widgets/events_tab.dart';
import 'package:immigru/presentation/screens/home/widgets/for_you_tab.dart';
import 'package:immigru/presentation/screens/home/widgets/immi_groves_tab.dart';
import 'package:immigru/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:immigru/presentation/theme/app_colors.dart';
import 'package:immigru/presentation/theme/app_theme.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final User? user;
  
  const HomeScreen({
    Key? key,
    this.user,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final LoggerService _logger = LoggerService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Use cases
  final SignOutUseCase _signOutUseCase = sl<SignOutUseCase>();
  final GetPostsUseCase _getPostsUseCase = sl<GetPostsUseCase>();
  final CreatePostUseCase _createPostUseCase = sl<CreatePostUseCase>();
  final GetEventsUseCase _getEventsUseCase = sl<GetEventsUseCase>();
  
  late TabController _tabController;
  late PageController _pageController;
  int _currentIndex = 0;
  
  // Data states
  String _selectedCategory = 'All';
  bool _isLoadingPosts = false;
  bool _isLoadingEvents = false;
  List<Map<String, dynamic>> _posts = [];
  List<Map<String, dynamic>> _events = [];
  
  // Sample data for demonstration (will be replaced with real data when backend is ready)
  final List<Map<String, dynamic>> _samplePosts = [
    {
      'category': 'Immigration News',
      'userName': 'Jane Doe',
      'timeAgo': '2h ago',
      'location': 'New York, USA',
      'content': 'Just got my green card approved! The process was smoother than I expected. Happy to share my experience with anyone going through the same process.',
      'commentCount': 12,
      'imageUrl': null,
    },
    {
      'category': 'Legal Advice',
      'userName': 'John Smith',
      'timeAgo': '5h ago',
      'location': 'Los Angeles, USA',
      'content': 'If you\'re applying for citizenship, make sure to double-check all your documentation. I made a small mistake that delayed my application by months.',
      'commentCount': 8,
      'imageUrl': 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8ZG9jdW1lbnRzfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=500&q=60',
    },
    {
      'category': 'Community',
      'userName': 'Maria Garcia',
      'timeAgo': '1d ago',
      'location': 'Chicago, USA',
      'content': 'Hosting a cultural exchange event next weekend. Everyone is welcome! We\'ll have food, music, and activities from around the world.',
      'commentCount': 24,
      'imageUrl': 'https://images.unsplash.com/photo-1511632765486-a01980e01a18?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTB8fGN1bHR1cmFsJTIwZXZlbnR8ZW58MHx8MHx8&auto=format&fit=crop&w=500&q=60',
    },
  ];
  
  final List<Map<String, dynamic>> _sampleEvents = [
    {
      'title': 'Immigration Workshop',
      'event_date': '2025-05-15T10:00:00.000Z',
      'location': 'Online',
      'icon': Icons.video_call,
    },
    {
      'title': 'Citizenship Application Seminar',
      'event_date': '2025-05-20T14:00:00.000Z',
      'location': 'New York Community Center',
      'icon': Icons.location_on,
    },
    {
      'title': 'Cultural Exchange Festival',
      'event_date': '2025-06-05T12:00:00.000Z',
      'location': 'Central Park, NY',
      'icon': Icons.celebration,
    },
    {
      'title': 'Legal Aid Clinic',
      'event_date': '2025-06-12T15:00:00.000Z',
      'location': 'Online',
      'icon': Icons.gavel,
    },
  ];
  
  @override
  void initState() {
    super.initState();
    
    // Initialize tab controller
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentIndex = _tabController.index;
          _pageController.animateToPage(
            _currentIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      }
    });
    
    // Initialize page controller
    _pageController = PageController(initialPage: _currentIndex);
    
    // Fetch initial data
    _fetchPosts();
    _fetchEvents();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // Sign out the user
  Future<void> _signOut() async {
    _logger.debug('HomeScreen', 'User signing out');
    try {
      await _signOutUseCase.call();
      // TODO: Navigate to login screen after sign out
    } catch (e) {
      _logger.error('HomeScreen', 'Error signing out', error: e);
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to sign out. Please try again.'))
        );
      }
    }
  }
  
  // Fetch posts from the repository
  Future<void> _fetchPosts() async {
    if (_isLoadingPosts) return;
    
    setState(() {
      _isLoadingPosts = true;
    });
    
    try {
      _logger.debug('HomeScreen', 'Fetching posts with category: $_selectedCategory');
      
      // Try to get posts from the repository
      List<Map<String, dynamic>> posts = [];
      
      try {
        posts = await _getPostsUseCase.call(
          category: _selectedCategory != 'All' ? _selectedCategory : null,
          limit: 20,
        ).timeout(const Duration(seconds: 5));
      } catch (e) {
        // If error or timeout, use sample data
        _logger.debug('HomeScreen', 'Using sample posts data as fallback');
        posts = _samplePosts;
      }
      
      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoadingPosts = false;
        });
      }
    } catch (e) {
      _logger.error('HomeScreen', 'Error fetching posts', error: e);
      
      // Use sample data as fallback
      if (mounted) {
        setState(() {
          _posts = _samplePosts;
          _isLoadingPosts = false;
        });
      }
    }
  }
  
  // Fetch events from the repository
  Future<void> _fetchEvents() async {
    if (_isLoadingEvents) return;
    
    setState(() {
      _isLoadingEvents = true;
    });
    
    try {
      _logger.debug('HomeScreen', 'Fetching upcoming events');
      
      // Try to get events from the repository
      List<Map<String, dynamic>> events = [];
      
      try {
        events = await _getEventsUseCase.call(
          upcoming: true,
          limit: 10,
        ).timeout(const Duration(seconds: 5));
      } catch (e) {
        // If error or timeout, use sample data
        _logger.debug('HomeScreen', 'Using sample events data as fallback');
        events = _sampleEvents;
      }
      
      if (mounted) {
        setState(() {
          _events = events;
          _isLoadingEvents = false;
        });
      }
    } catch (e) {
      _logger.error('HomeScreen', 'Error fetching events', error: e);
      
      // Use sample data as fallback
      if (mounted) {
        setState(() {
          _events = _sampleEvents;
          _isLoadingEvents = false;
        });
      }
    }
  }
  
  // Show create post dialog
  void _showCreatePostDialog() {
    _logger.debug('HomeScreen', 'Showing create post dialog');
    CreatePostDialog.show(context, widget.user, _createPost);
  }
  
  // Create a new post
  Future<void> _createPost(String content, String? category) async {
    _logger.debug('HomeScreen', 'Creating post: $content, category: $category');
    try {
      await _createPostUseCase.call(
        content: content,
        userId: widget.user?.id ?? '',
        category: category ?? 'General',
      );
      
      // Refresh posts after creating a new one
      _fetchPosts();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully!'))
        );
      }
    } catch (e) {
      _logger.error('HomeScreen', 'Error creating post', error: e);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create post. Please try again.'))
        );
      }
    }
  }
  
  // Add a new document to ImmiGroves
  Future<void> _addDocument() async {
    _logger.debug('HomeScreen', 'Adding document to ImmiGroves');
    // TODO: Implement document upload functionality
  }
  
  
  // Build the menu drawer
  Widget _buildMenuDrawer(BuildContext context, bool isDarkMode) {
    final themeProvider = Provider.of<AppThemeProvider>(context);
    
    return Drawer(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight,
      width: MediaQuery.of(context).size.width * 0.75, // 75% of screen width
      child: SafeArea(
        child: Column(
          children: [
            // Drawer header with theme toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  // Theme toggle button
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      onPressed: () {
                        themeProvider.setThemeMode(
                          isDarkMode ? ThemeMode.light : ThemeMode.dark
                        );
                      },
                      icon: Icon(
                        isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        size: 20,
                      ),
                      tooltip: isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ),
            
            // Menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.person_outline,
                    title: 'Profile',
                    onTap: () {
                      _logger.debug('Menu', 'Profile selected');
                      Navigator.pop(context);
                      // TODO: Navigate to profile screen
                    },
                    isDarkMode: isDarkMode,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {
                      _logger.debug('Menu', 'Settings selected');
                      Navigator.pop(context);
                      // TODO: Navigate to settings screen
                    },
                    isDarkMode: isDarkMode,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      _logger.debug('Menu', 'Help selected');
                      Navigator.pop(context);
                      // TODO: Navigate to help screen
                    },
                    isDarkMode: isDarkMode,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.info_outline,
                    title: 'About',
                    onTap: () {
                      _logger.debug('Menu', 'About selected');
                      Navigator.pop(context);
                      // TODO: Navigate to about screen
                    },
                    isDarkMode: isDarkMode,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.flight_takeoff_outlined,
                    title: 'Immigration Journey',
                    onTap: () {
                      _logger.debug('Menu', 'Immigration Journey selected');
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OnboardingScreen(user: widget.user),
                        ),
                      );
                    },
                    isDarkMode: isDarkMode,
                  ),
                  const Divider(),
                  _buildMenuItem(
                    context,
                    icon: Icons.logout,
                    title: 'Sign Out',
                    onTap: () {
                      _logger.debug('Menu', 'Sign out selected');
                      Navigator.pop(context);
                      _signOut();
                    },
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),
            
            // App version at bottom
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Immigru v1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.white54 : Colors.black45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper method to build menu items
  Widget _buildMenuItem(BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDarkMode ? AppColors.iconDark : AppColors.iconLight,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      onTap: onTap,
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width >= 768;
    final isDesktop = screenSize.width >= 1200;
    
    return Scaffold(
      key: _scaffoldKey,
      // Use proper theme colors for background
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: HomeAppBar(
        user: widget.user,
        onSignOut: _signOut,
        logger: _logger,
        onSearchPressed: () {
          // Handle search action
          _logger.debug('HomeScreen', 'Search button pressed');
        },
        onChatPressed: () {
          // Handle chat action
          _logger.debug('HomeScreen', 'Chat button pressed');
        },
      ),
      // Add drawer for menu
      endDrawer: _buildMenuDrawer(context, isDarkMode),
      drawerEdgeDragWidth: 0, // Disable edge drag to only open via menu button
      floatingActionButton: HomeFloatingActionButton(
        currentIndex: _currentIndex,
        onCreatePost: _showCreatePostDialog,
        logger: _logger,
      ),
      bottomNavigationBar: HomeBottomNavigation(
        currentIndex: _currentIndex,
        onTabSelected: _onTabSelected,
        logger: _logger,
        onMenuPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
      ),
      // Already set the background color above
      body: SafeArea(
        // Use a container with proper theme background color
        child: Column(
          children: [
            // Tab navigation with no bottom padding or margin
            HomeTabNavigation(
              tabController: _tabController,
              currentIndex: _currentIndex,
            ),
            
            // Main content with proper theme background color
            Expanded(
              child: Container(
                color: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
                child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                    _tabController.animateTo(index);
                  });
                },
                children: [
                  ForYouTab(
                    user: widget.user,
                    posts: _posts,
                    onCreatePost: _createPost,
                    isTablet: isTablet,
                    isDesktop: isDesktop,
                  ),
                  AllPostsTab(
                    posts: _posts,
                    selectedCategory: _selectedCategory,
                    onCategorySelected: _selectCategory,
                    isTablet: isTablet,
                    isDesktop: isDesktop,
                  ),
                  ImmiGrovesTab(
                    isTablet: isTablet,
                    isDesktop: isDesktop,
                    onAddDocument: _addDocument,
                  ),
                  EventsTab(
                    events: _events,
                    logger: _logger,
                    isTablet: isTablet,
                    isDesktop: isDesktop,
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
  
  // Handle tab selection
  void _onTabSelected(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
      
      // Update tab controller and page controller
      _tabController.animateTo(index);
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Helper methods for tab actions
  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _fetchPosts();
  }
  

}
