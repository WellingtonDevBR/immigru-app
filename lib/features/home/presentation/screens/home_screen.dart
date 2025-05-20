import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/auth/domain/entities/user.dart';
import 'package:immigru/features/home/presentation/bloc/home_bloc.dart';
import 'package:immigru/features/home/presentation/bloc/home_event.dart';
import 'package:immigru/features/home/presentation/widgets/app_bar_widget.dart';
import 'package:immigru/features/home/presentation/widgets/bottom_navigation.dart';
import 'package:immigru/features/home/presentation/widgets/create_post_dialog.dart';
import 'package:immigru/features/home/presentation/widgets/floating_action_button.dart';
import 'package:immigru/features/home/presentation/widgets/tab_navigation.dart';
import 'package:immigru/features/home/presentation/widgets/tabs/all_posts_tab.dart';
import 'package:immigru/features/home/presentation/widgets/tabs/events_tab.dart';
import 'package:immigru/features/home/presentation/widgets/tabs/for_you_tab.dart';
import 'package:immigru/features/home/presentation/widgets/tabs/immi_groves_tab.dart';
import 'package:immigru/shared/theme/app_colors.dart';

/// Modern home screen for the Immigru app
class HomeScreen extends StatefulWidget {
  final User? user;
  
  const HomeScreen({
    super.key,
    this.user,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  late TabController _tabController;
  late PageController _pageController;
  int _currentIndex = 0;
  
  // Category selection for posts
  String _selectedCategory = 'All';
  
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
    _fetchInitialData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }
  
  /// Fetch initial data for the home screen
  void _fetchInitialData() {
    final homeBloc = BlocProvider.of<HomeBloc>(context);
    
    // Fetch posts
    homeBloc.add(const FetchPosts());
    
    // Fetch personalized posts if user is logged in
    if (widget.user != null) {
      homeBloc.add(FetchPersonalizedPosts(userId: widget.user!.id));
    }
    
    // Fetch events
    homeBloc.add(const FetchEvents());
  }
  
  /// Show create post dialog
  void _showCreatePostDialog() {
    if (widget.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to create a post')),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => CreatePostDialog(
        user: widget.user!,
        onPost: (content, category, imageUrl) {
          BlocProvider.of<HomeBloc>(context).add(
            CreatePost(
              content: content,
              userId: widget.user!.id,
              category: category,
              imageUrl: imageUrl,
            ),
          );
        },
      ),
    );
  }
  
  /// Handle category selection
  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
    
    BlocProvider.of<HomeBloc>(context).add(
      SelectCategory(category: category),
    );
  }
  
  /// Build the drawer for the home screen
  Widget _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Drawer(
      backgroundColor: isDarkMode ? AppColors.darkSurface : Colors.white,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // User profile section
            if (widget.user != null)
              UserAccountsDrawerHeader(
                accountName: Text(widget.user!.displayName ?? 'User'),
                accountEmail: Text(widget.user!.email ?? ''),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: widget.user!.photoUrl != null
                      ? NetworkImage(widget.user!.photoUrl!)
                      : null,
                  child: widget.user!.photoUrl == null
                      ? Text(
                          widget.user!.displayName?[0] ?? 'U',
                          style: const TextStyle(fontSize: 24),
                        )
                      : null,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                ),
              )
            else
              DrawerHeader(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Immigru',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to login screen
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: theme.colorScheme.primary,
                      ),
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
              ),
            
            // Menu items
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              selected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to profile screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.flight_takeoff),
              title: const Text('Immigration Journey'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to immigration journey screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings screen
              },
            ),
            const Divider(),
            if (widget.user != null)
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign Out'),
                onTap: () {
                  Navigator.pop(context);
                  // Sign out
                },
              ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.backgroundLight,
      appBar: HomeAppBar(
        user: widget.user,
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      drawer: _buildDrawer(context),
      floatingActionButton: HomeFloatingActionButton(
        currentIndex: _currentIndex,
        onCreatePost: _showCreatePostDialog,
      ),
      bottomNavigationBar: HomeBottomNavigation(
        currentIndex: _currentIndex,
        onTabSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
          
          _tabController.animateTo(index);
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
      ),
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
                  // For You tab
                  ForYouTab(
                    user: widget.user,
                    onCreatePost: _showCreatePostDialog,
                  ),
                  
                  // All Posts tab
                  AllPostsTab(
                    selectedCategory: _selectedCategory,
                    onCategorySelected: _selectCategory,
                  ),
                  
                  // ImmiGroves tab
                  const ImmiGrovesTab(),
                  
                  // Events tab
                  const EventsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
