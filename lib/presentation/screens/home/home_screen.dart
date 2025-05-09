import 'package:flutter/material.dart';
import 'package:immigru/core/di/injection_container.dart';
import 'package:immigru/core/services/logger_service.dart';
import 'package:immigru/domain/entities/user.dart';
import 'package:immigru/domain/usecases/auth_usecases.dart';
import 'package:immigru/domain/usecases/post_usecases.dart';
import 'package:immigru/presentation/screens/auth/login_screen.dart';
import 'package:immigru/presentation/screens/home/widgets/feature_grid.dart';
import 'package:immigru/presentation/theme/app_colors.dart';
import 'package:immigru/presentation/widgets/app_logo.dart';
import 'package:immigru/presentation/widgets/community/community_feed_item.dart';
import 'package:immigru/presentation/widgets/community/create_post_card.dart';
import 'package:immigru/presentation/widgets/navigation/tab_navigation.dart';

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
  
  // Use cases
  final SignOutUseCase _signOutUseCase = sl<SignOutUseCase>();
  final GetPostsUseCase _getPostsUseCase = sl<GetPostsUseCase>();
  final CreatePostUseCase _createPostUseCase = sl<CreatePostUseCase>();
  final GetEventsUseCase _getEventsUseCase = sl<GetEventsUseCase>();
  final CreateEventUseCase _createEventUseCase = sl<CreateEventUseCase>();
  
  late TabController _tabController;
  late PageController _pageController;
  int _currentIndex = 0;
  
  // Data states
  String _selectedCategory = 'All Posts';
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
    try {
      _logger.info('HomeScreen', 'Signing out user');
      await _signOutUseCase.call();
      if (!mounted) return;
      
      // Navigate to login screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      _logger.error('HomeScreen', 'Error signing out', error: e);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to sign out. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fetch posts from the repository
  Future<void> _fetchPosts() async {
    if (_isLoadingPosts) return;
    
    setState(() {
      _isLoadingPosts = true;
    });
    
    try {
      _logger.info('HomeScreen', 'Fetching posts with category: $_selectedCategory');
      
      // Try to get posts from the repository
      List<Map<String, dynamic>> posts = [];
      
      try {
        posts = await _getPostsUseCase.call(
          category: _selectedCategory != 'All Posts' ? _selectedCategory : null,
          limit: 20,
        ).timeout(const Duration(seconds: 5));
      } catch (e) {
        // If error or timeout, use sample data
        _logger.info('HomeScreen', 'Using sample posts data as fallback', error: e);
        posts = _samplePosts;
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Using sample data. Real data will be available when backend is ready.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
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
      _logger.info('HomeScreen', 'Fetching upcoming events');
      
      // Try to get events from the repository
      List<Map<String, dynamic>> events = [];
      
      try {
        events = await _getEventsUseCase.call(
          upcoming: true,
          limit: 10,
        ).timeout(const Duration(seconds: 5));
      } catch (e) {
        // If error or timeout, use sample data
        _logger.info('HomeScreen', 'Using sample events data as fallback', error: e);
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width >= 768;
    final isDesktop = screenSize.width >= 1200;
    
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: _buildAppBar(context),
      floatingActionButton: _buildFloatingActionButton(),
      body: SafeArea(
        child: Column(
          children: [
            // Tab navigation
            HomeTabNavigation(
              tabController: _tabController,
              currentIndex: _currentIndex,
            ),
            
            // Main content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                    _tabController.animateTo(index);
                  });
                },
                children: [
                  _buildForYouTab(isTablet, isDesktop),
                  _buildAllPostsTab(isTablet, isDesktop),
                  _buildMyImmiGrovesTab(isTablet, isDesktop),
                  _buildEventsTab(isTablet, isDesktop),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const AppLogo(),
      elevation: 0,
      actions: [
        // Search button
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: 'Search',
          onPressed: () {
            // TODO: Implement search
            _logger.debug('HomeScreen', 'Search button pressed');
          },
        ),
        
        // Notifications button
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          tooltip: 'Notifications',
          onPressed: () {
            // TODO: Implement notifications
            _logger.debug('HomeScreen', 'Notifications button pressed');
          },
        ),
        
        // Profile button with popup menu
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: PopupMenuButton<String>(
            offset: const Offset(0, 56),
            onSelected: (value) {
              if (value == 'logout') {
                _signOut();
              } else if (value == 'profile') {
                // TODO: Navigate to profile screen
                _logger.debug('HomeScreen', 'Profile option selected');
              } else if (value == 'settings') {
                // TODO: Navigate to settings screen
                _logger.debug('HomeScreen', 'Settings option selected');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            child: Hero(
              tag: 'user-avatar',
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                backgroundImage: widget.user?.photoUrl != null 
                    ? NetworkImage(widget.user!.photoUrl!) 
                    : null,
                child: widget.user?.photoUrl == null
                    ? Icon(
                        Icons.person,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        // Show different actions based on current tab
        switch (_currentIndex) {
          case 0: // For You
          case 1: // All Posts
            _showCreatePostDialog();
            break;
          case 2: // My ImmiGroves
            // TODO: Implement create new ImmiGrove
            _logger.debug('HomeScreen', 'Create new ImmiGrove');
            break;
          case 3: // Events
            // TODO: Implement create new event
            _logger.debug('HomeScreen', 'Create new event');
            break;
        }
      },
      tooltip: 'Create new content',
      child: const Icon(Icons.add),
    );
  }
  
  void _showCreatePostDialog() {
    // TODO: Implement create post dialog
    _logger.debug('HomeScreen', 'Create post dialog shown');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Create post feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  Widget _buildForYouTab(bool isTablet, bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24 : 16,
            vertical: 16,
          ),
          children: [
            // Create post card
            CreatePostCard(user: widget.user),
            const SizedBox(height: 16),
            
            // Feed items
            ..._posts.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CommunityFeedItem(
                category: item['category'],
                userName: item['userName'],
                timeAgo: item['timeAgo'],
                location: item['location'],
                content: item['content'],
                commentCount: item['commentCount'],
                imageUrl: item['imageUrl'],
              ),
            )).toList(),
          ],
        );
      },
    );
  }
  
  Widget _buildAllPostsTab(bool isTablet, bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // For desktop, show a multi-column layout
        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Categories sidebar (1/4 width)
              SizedBox(
                width: constraints.maxWidth * 0.25,
                child: Card(
                  margin: const EdgeInsets.all(16),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        'Categories',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildCategoryItem('All Posts', isSelected: true),
                      _buildCategoryItem('Immigration News'),
                      _buildCategoryItem('Legal Advice'),
                      _buildCategoryItem('Community Events'),
                      _buildCategoryItem('Success Stories'),
                    ],
                  ),
                ),
              ),
              
              // Posts (3/4 width)
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Show all posts without filtering
                    ..._posts.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: CommunityFeedItem(
                        category: item['category'],
                        userName: item['userName'],
                        timeAgo: item['timeAgo'],
                        location: item['location'],
                        content: item['content'],
                        commentCount: item['commentCount'],
                        imageUrl: item['imageUrl'],
                      ),
                    )).toList(),
                  ],
                ),
              ),
            ],
          );
        }
        
        // For mobile and tablet, show a single column layout
        return ListView(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24 : 16,
            vertical: 16,
          ),
          children: [
            // Categories horizontal list
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryChip('All Posts', isSelected: true),
                  _buildCategoryChip('Immigration News'),
                  _buildCategoryChip('Legal Advice'),
                  _buildCategoryChip('Community Events'),
                  _buildCategoryChip('Success Stories'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Show all posts without filtering
            ..._posts.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CommunityFeedItem(
                category: item['category'],
                userName: item['userName'],
                timeAgo: item['timeAgo'],
                location: item['location'],
                content: item['content'],
                commentCount: item['commentCount'],
                imageUrl: item['imageUrl'],
              ),
            )).toList(),
          ],
        );
      },
    );
  }
  
  Widget _buildCategoryItem(String name, {bool isSelected = false}) {
    return ListTile(
      title: Text(
        name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
      leading: Icon(
        Icons.folder_outlined,
        color: isSelected ? Theme.of(context).colorScheme.primary : null,
      ),
      selected: isSelected,
      onTap: () {
        setState(() {
          _selectedCategory = name;
        });
        _fetchPosts();
      },
    );
  }
  
  Widget _buildCategoryChip(String name, {bool isSelected = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(name),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = name;
          });
          _fetchPosts();
        },
      ),
    );
  }
  
  Widget _buildMyImmiGrovesTab(bool isTablet, bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24 : 16,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'My ImmiGroves',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Access your immigration tools and resources',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 24),
              
              // Feature grid showing immigration tools
              FeatureGrid(
                selectedIndex: 2, // Community/ImmiGroves is selected
                onFeatureSelected: (index) {
                  // Handle feature selection
                  _logger.debug('HomeScreen', 'Feature selected: $index');
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildEventsTab(bool isTablet, bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // For desktop, use a grid layout
        if (isDesktop) {
          return GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _events.length,
            itemBuilder: (context, index) {
              final event = _events[index];
              return _buildEventCard(event);
            },
          );
        }
        
        // For tablet, use a grid with one column
        if (isTablet) {
          return GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: 3.5,
              mainAxisSpacing: 16,
            ),
            itemCount: _events.length,
            itemBuilder: (context, index) {
              final event = _events[index];
              return _buildEventCard(event);
            },
          );
        }
        
        // For mobile, use a list
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Events header
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Upcoming Events',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Event list
            ..._events.map((event) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildEventListItem(event),
            )).toList(),
          ],
        );
      },
    );
  }
  
  Widget _buildEventCard(Map<String, dynamic> event) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    event['icon'] as IconData,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['title'] as String,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${event['event_date']} • ${event['location']}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    // TODO: Navigate to event details
                    _logger.debug('HomeScreen', 'Event selected: ${event['title']}');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEventListItem(Map<String, dynamic> event) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            event['icon'] as IconData,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          event['title'] as String,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text('${event['event_date']} • ${event['location']}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Navigate to event details
          _logger.debug('HomeScreen', 'Event selected: ${event['title']}');
        },
      ),
    );
  }
}
