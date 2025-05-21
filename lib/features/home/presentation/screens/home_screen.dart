import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/auth/domain/entities/user.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_event.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_state.dart';
import 'package:immigru/features/home/presentation/bloc/home_bloc.dart';
import 'package:immigru/features/home/presentation/bloc/home_event.dart';
import 'package:immigru/features/home/presentation/screens/post_creation_screen.dart';
import 'package:immigru/features/home/presentation/widgets/app_bar_widget.dart';
import 'package:immigru/features/home/presentation/widgets/tabs/all_posts_tab.dart';
import 'package:immigru/features/home/presentation/widgets/tabs/immi_groves_tab.dart';
import 'package:immigru/features/home/presentation/widgets/tabs/notifications_tab.dart';
import 'package:immigru/shared/theme/app_colors.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/shared/widgets/pulsing_fab.dart';

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
  final _logger = UnifiedLogger();

  late PageController _pageController;
  int _selectedIndex = 0;
  bool hasUnreadMessages = true;
  bool hasUnreadNotifications = true;
  int unreadMessageCount = 3;

  // Category selection for posts
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();

    // Initialize page controller
    _pageController = PageController(initialPage: _selectedIndex);

    // Fetch initial data
    _fetchInitialData();

    _logger.d('Home screen initialized', tag: 'HomeScreen');
  }

  @override
  void dispose() {
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

  /// Show post creation modal that slides up from the bottom
  void _showPostCreationModal() {
    if (widget.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to create a post')),
      );
      return;
    }

    _logger.d('Opening post creation modal', tag: 'HomeScreen');
    HapticFeedback.mediumImpact();

    // Use a custom animation for the modal to slide up from the bottom
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7, // Start with more screen coverage
        minChildSize: 0.4,     // Minimum size when dragged down
        maxChildSize: 0.95,    // Almost full screen when expanded
        builder: (_, controller) => PostCreationScreen(
          user: widget.user!,
          scrollController: controller,
          onPost: (content, category, imageUrl) {
            BlocProvider.of<HomeBloc>(context).add(
              CreatePost(
                content: content,
                userId: widget.user!.id,
                category: category,
                imageUrl: imageUrl,
              ),
            );
            // Add haptic feedback on post submission
            HapticFeedback.mediumImpact();
            Navigator.pop(context);
          },
        ),
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
                    const Text(
                      'Welcome to Immigru',
                      style: TextStyle(
                        color: Colors.white70,
                      ),
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
            // Always show sign-out button
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () {
                Navigator.pop(context);
                // Sign out using AuthBloc
                BlocProvider.of<AuthBloc>(context).add(AuthSignOutEvent());
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build the bottom navigation bar
  Widget _buildBottomNavigationBar() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Regular bottom navigation bar
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      backgroundColor: isDarkMode ? AppColors.darkSurface : Colors.white,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: isDarkMode ? Colors.white70 : Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      onTap: (index) {
        HapticFeedback.lightImpact();
        setState(() => _selectedIndex = index);

        if (index == 3) {
          // Menu button opens drawer from bottom
          _scaffoldKey.currentState?.openEndDrawer();
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.groups),
          label: 'ImmiGroves',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu),
          label: 'Menu',
        ),
      ],
    );
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Check if user is not authenticated and not loading
        if (state.isAuthenticated == false && !state.isLoading) {
          // Navigate to login screen if user is not authenticated
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor:
            isDarkMode ? AppColors.darkBackground : AppColors.backgroundLight,
        appBar: HomeAppBar(
          user: widget.user,
          hasUnreadMessages: hasUnreadMessages,
          unreadMessageCount: unreadMessageCount,
        ),
        endDrawer: _buildDrawer(
            context), // Changed to endDrawer for bottom menu access
        bottomNavigationBar: _buildBottomNavigationBar(),

        body: SafeArea(
          child: Column(
            children: [
              // Migration-themed post creation widget
              if (_selectedIndex == 0)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.05),
                        theme.colorScheme.primary.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      width: 1.0,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        _showPostCreationModal();
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            // Journey icon
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.flight_takeoff,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Share your journey text
                            Expanded(
                              child: Text(
                                'Share your immigration journey...',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white70 : Colors.grey[700],
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Add photo icon
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.colorScheme.primary.withOpacity(0.3),
                                  width: 1.0,
                                ),
                              ),
                              child: Icon(
                                Icons.add_photo_alternate_outlined,
                                color: theme.colorScheme.primary,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Main content
              // Main content
              Expanded(
                child: _selectedIndex == 0
                    ? RefreshIndicator(
                        onRefresh: () async {
                          BlocProvider.of<HomeBloc>(context)
                              .add(const FetchPosts());
                          await Future.delayed(const Duration(seconds: 1));
                        },
                        child: AllPostsTab(
                          selectedCategory: _selectedCategory,
                          onCategorySelected: _selectCategory,
                        ),
                      )
                    : _selectedIndex == 1
                        ? const ImmiGrovesTab()
                        : NotificationsTab(user: widget.user),
              ),
            ],
          ), // <-- Closing Column
        ),
      ), // <-- Closing Scaffold
    ); // <-- Closing BlocListener
  }
}
