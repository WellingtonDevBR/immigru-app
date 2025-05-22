import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/home/presentation/bloc/post_creation/post_creation_bloc.dart';
import 'package:immigru/features/home/presentation/screens/post_creation_screen.dart';
import 'package:provider/provider.dart';
import 'package:immigru/features/auth/domain/entities/user.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_event.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_state.dart';
import 'package:immigru/features/home/presentation/bloc/home_bloc.dart';
import 'package:immigru/features/home/presentation/bloc/home_event.dart';
import 'package:immigru/features/home/presentation/bloc/home_state.dart';
import 'package:immigru/features/home/presentation/widgets/app_bar_widget.dart';
import 'package:immigru/features/home/presentation/widgets/tabs/all_posts_tab.dart';
import 'package:immigru/features/home/presentation/widgets/tabs/immi_groves_tab.dart';
import 'package:immigru/features/home/presentation/widgets/tabs/notifications_tab.dart';
import 'package:immigru/shared/theme/app_colors.dart';
import 'package:immigru/shared/theme/theme_provider.dart';
import 'package:immigru/core/logging/unified_logger.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.user});

  final User? user;

  static final GlobalKey _singletonKey =
      GlobalKey(debugLabel: 'HomeScreenSingleton');
  static final HomeScreen singleton = HomeScreen(key: _singletonKey);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _logger = UnifiedLogger();

  late PageController _pageController;
  int _selectedIndex = 0;
  bool hasUnreadMessages = true;
  bool hasUnreadNotifications = true;
  int unreadMessageCount = 3;

  String _selectedCategory = 'All';

  bool _hasInitializedData = false;

  bool _isInitializing = false;

  bool _hasSetLoadingTimeout = false;

  bool _isNavigating = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: _selectedIndex);

    _logger.d('Home screen created with key: ${widget.key}', tag: 'HomeScreen');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          !_isInitializing &&
          !_isNavigating &&
          !_hasInitializedData) {
        _initializeOnce();
      } else {
        _logger.d(
            'Skipping initialization - widget already initialized or busy',
            tag: 'HomeScreen');
      }
    });
  }

  void _initializeOnce() {
    if (_isInitializing || !mounted || _isNavigating || _hasInitializedData) {
      _logger.d(
          'HOME SCREEN: Skipping initialization - already initialized or navigating',
          tag: 'HomeScreen');
      return;
    }

    // Set initialization flag to prevent concurrent initialization
    _isInitializing = true;
    _logger.d('HOME SCREEN: Starting initialization', tag: 'HomeScreen');

    try {
      final homeBloc = context.read<HomeBloc>();
      final currentState = homeBloc.state;

      _logger.d(
          'HOME SCREEN: Initializing with state: ${currentState.runtimeType}',
          tag: 'HomeScreen');

      if (currentState is HomeInitial || !_hasInitializedData) {
        _hasInitializedData = true;
        _logger.d('HOME SCREEN: First initialization, fetching initial data',
            tag: 'HomeScreen');

        // Use a single microtask to prevent multiple UI updates
        Future.microtask(() {
          if (mounted && !_isNavigating) {
            _fetchInitialData();
            _logger.d('HOME SCREEN: Data initialization triggered',
                tag: 'HomeScreen');
          }
        });
      } else if (currentState is PostsLoaded) {
        // If posts are already loaded, just make sure we're using the right category
        _selectedCategory = currentState.selectedCategory;
        _hasInitializedData = true; // Mark as initialized
        _logger.d(
            'HOME SCREEN: Already has data with category: $_selectedCategory',
            tag: 'HomeScreen');
      } else {
        _logger.d(
            'HOME SCREEN: Has state ${currentState.runtimeType}, refreshing data',
            tag: 'HomeScreen');
        _hasInitializedData = true; // Mark as initialized

        // Use a single microtask to prevent multiple UI updates
        Future.microtask(() {
          if (mounted && !_isNavigating) {
            _fetchInitialData();
          }
        });
      }
    } catch (e) {
      _logger.e('HOME SCREEN ERROR: Error during initialization: $e',
          tag: 'HomeScreen');
      // Even if there's an error, try to fetch data to avoid a blank screen
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && !_isNavigating && !_hasInitializedData) {
          _logger.d('HOME SCREEN: Attempting recovery after error',
              tag: 'HomeScreen');
          _hasInitializedData =
              true; // Mark as initialized to prevent multiple recovery attempts
          _fetchInitialData();
        }
      });
    } finally {
      // Reset the initialization lock after a shorter delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _isInitializing = false;
          _logger.d('HOME SCREEN: Initialization lock released',
              tag: 'HomeScreen');
        }
      });
    }
  }

  @override
  void dispose() {
    _logger.d('HOME SCREEN: Disposing', tag: 'HomeScreen');
    // Mark as navigating to prevent any further data fetching
    _isNavigating = true;
    _pageController.dispose();
    super.dispose();
  }

  @override
  void updateKeepAlive() {
    super.updateKeepAlive();
  }

  // Flag to track if we've attempted to recover from a failed fetch
  bool _hasAttemptedRecovery = false;

  // Flag to track if we've fetched posts at least once
  bool _hasFetchedPosts = false;

  /// Fetch initial data for the home screen - only called once
  void _fetchInitialData() {
    // Strict one-time execution guard - only allow recovery attempts after first fetch
    if (_hasFetchedPosts && !_hasAttemptedRecovery) {
      _logger.d('HOME SCREEN: Skipping data fetch - already fetched posts once',
          tag: 'HomeScreen');
      return;
    }

    // More robust check to prevent fetches during navigation
    if (_isNavigating) {
      _logger.d('HOME SCREEN: Skipping data fetch - navigation in progress',
          tag: 'HomeScreen');
      return;
    }

    // Mark that we've attempted to fetch posts
    _hasFetchedPosts = true;

    try {
      // Get the bloc instance safely using read to prevent context issues
      final homeBloc = context.read<HomeBloc>();

      // Check current state to avoid duplicate fetches
      final currentState = homeBloc.state;
      _logger.d(
          'HOME SCREEN: Fetching data with state: ${currentState.runtimeType}',
          tag: 'HomeScreen');

      // Clear the recovery flag if we're making a new attempt
      _hasAttemptedRecovery = false;

      // Only fetch posts if we're in initial state or if we need a refresh
      if (currentState is HomeInitial ||
          currentState is PostsError ||
          currentState is PostsLoading) {
        // Mark as initialized to prevent duplicate fetches
        _hasInitializedData = true;

        // Force a refresh to ensure we get fresh data
        if (!homeBloc.isClosed) {
          homeBloc.add(FetchPosts(category: _selectedCategory, refresh: true));
        }

        // Set a timeout to ensure we don't get stuck in loading state
        _setLoadingTimeout();

        // Use a single delayed future for all secondary data fetches to reduce overhead
        Future.delayed(const Duration(milliseconds: 800), () {
          if (!mounted || _isNavigating) return;

          // Fetch personalized posts if user is logged in
          if (widget.user != null) {
            _logger.d(
                'HOME SCREEN: Fetching personalized posts for user: ${widget.user!.id}',
                tag: 'HomeScreen');
            homeBloc.add(FetchPersonalizedPosts(userId: widget.user!.id));
          } else {
            _logger.w('HOME SCREEN: User is null, skipping personalized posts',
                tag: 'HomeScreen');
          }

          // Fetch events after a short delay
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && !_isNavigating) {
              _logger.d('HOME SCREEN: Fetching events', tag: 'HomeScreen');
              homeBloc.add(const FetchEvents());
            }
          });
        });
      } else if (currentState is PostsLoaded) {
        // If posts are already loaded, check if they're for the current category
        if (currentState.selectedCategory != _selectedCategory) {
          _logger.d(
              'HOME SCREEN: Posts loaded for different category, updating to: $_selectedCategory',
              tag: 'HomeScreen');
          homeBloc.add(SelectCategory(category: _selectedCategory));
        } else {
          _logger.d(
              'HOME SCREEN: Posts already loaded for category: $_selectedCategory, skipping fetch',
              tag: 'HomeScreen');
          // No need to emit additional events if data is already loaded
        }
      } else if (currentState is PostsLoading) {
        _logger.d('HOME SCREEN: Posts already loading, setting timeout',
            tag: 'HomeScreen');
        _setLoadingTimeout();
      } else {
        _logger.d(
            'HOME SCREEN: Unexpected state: ${currentState.runtimeType}, fetching posts',
            tag: 'HomeScreen');
        if (!homeBloc.isClosed) {
          homeBloc.add(FetchPosts(category: _selectedCategory, refresh: true));
        }

        _setLoadingTimeout();
      }
    } catch (e) {
      _logger.e('HOME SCREEN ERROR: Failed to initialize data: $e',
          tag: 'HomeScreen');

      // Try to recover by fetching posts after a short delay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          _logger.d('HOME SCREEN: Attempting data recovery after error',
              tag: 'HomeScreen');
          final homeBloc = context.read<HomeBloc>();
          if (!homeBloc.isClosed) {
            homeBloc
                .add(FetchPosts(category: _selectedCategory, refresh: true));
          }
        }
      });
    }
  }

  // Set a timeout to prevent getting stuck in loading state
  void _setLoadingTimeout() {
    // Prevent multiple timeouts from being set
    if (_hasSetLoadingTimeout || _isNavigating) {
      return;
    }

    _hasSetLoadingTimeout = true;
    _logger.d('Setting loading timeout', tag: 'HomeScreen');

    // Use a shorter timeout (6 seconds) for better user experience
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted && !_isNavigating) {
        try {
          final homeBloc = context.read<HomeBloc>();
          final currentState = homeBloc.state;

          // If we're still in a loading state after the timeout, force a recovery
          if (currentState is PostsLoading) {
            // Set recovery flag to allow a retry even if _hasInitializedData is true
            _hasAttemptedRecovery = true;
            _logger.w('HOME SCREEN: Loading timeout reached',
                tag: 'HomeScreen');

            // Try to fetch with a simpler approach
            homeBloc.add(FetchPosts(category: 'All', refresh: true));

            // Set a shorter secondary timeout for the recovery attempt
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted && !_isNavigating) {
                final newState = homeBloc.state;
                if (newState is PostsLoading) {
                  // If still loading after recovery attempt, force an error state
                  // This will show an error message instead of infinite loading
                  _logger.w(
                      'HOME SCREEN: Recovery timeout reached, showing error',
                      tag: 'HomeScreen');
                  homeBloc.add(const HomeError(
                      message:
                          'Unable to load posts. Please check your connection and try again.'));
                }
              }
            });
          }
        } catch (e) {
          _logger.e('Error setting timeout: $e', tag: 'HomeScreen');
        } finally {
          // Reset the timeout flag immediately to allow for future timeouts
          _hasSetLoadingTimeout = false;
        }
      } else {
        // Reset the flag if we're no longer mounted or navigating
        _hasSetLoadingTimeout = false;
      }
    });
  }

  void _showPostCreationModal() {
    final authBloc = BlocProvider.of<AuthBloc>(context);
    final authState = authBloc.state;
    final currentUser = authState.user ?? widget.user;

    if (currentUser == null) {
      authBloc.add(AuthRefreshUserEvent());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preparing post creation...')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) {
        return _PostCreationModalWrapper(
          user: currentUser,
          onPost: (content, category, imageUrl) {
            BlocProvider.of<HomeBloc>(context).add(
              CreatePost(
                content: content,
                userId: currentUser.id,
                category: category,
                imageUrl: imageUrl,
              ),
            );
            HapticFeedback.mediumImpact();
            Navigator.pop(context);
          },
        );
      },
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
            // Theme selection
            ExpansionTile(
              leading: const Icon(Icons.brightness_6),
              title: const Text('Theme'),
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('Light'),
                  value: ThemeMode.light,
                  groupValue: Provider.of<ThemeProvider>(context).themeMode,
                  onChanged: (ThemeMode? value) {
                    if (value != null) {
                      Provider.of<ThemeProvider>(context, listen: false)
                          .setThemeMode(value);
                      Navigator.pop(context);
                    }
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Dark'),
                  value: ThemeMode.dark,
                  groupValue: Provider.of<ThemeProvider>(context).themeMode,
                  onChanged: (ThemeMode? value) {
                    if (value != null) {
                      Provider.of<ThemeProvider>(context, listen: false)
                          .setThemeMode(value);
                      Navigator.pop(context);
                    }
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('System'),
                  value: ThemeMode.system,
                  groupValue: Provider.of<ThemeProvider>(context).themeMode,
                  onChanged: (ThemeMode? value) {
                    if (value != null) {
                      Provider.of<ThemeProvider>(context, listen: false)
                          .setThemeMode(value);
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
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

  // Flag to track if we've logged the first build
  static bool _hasLoggedFirstBuild = false;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    // Only log the first build to reduce console spam
    if (!_hasLoggedFirstBuild) {
      _hasLoggedFirstBuild = true;
    }

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        // Only trigger listener when authentication state actually changes
        // and only for logout events (not login events)
        return previous.isAuthenticated && !current.isAuthenticated;
      },
      listener: (context, state) {
        // Only handle logout events - let AuthWrapper handle login and onboarding navigation
        if (!state.isAuthenticated && !_isNavigating) {
          _logger.d('User logged out, navigating to login from HomeScreen',
              tag: 'HomeScreen');
          _isNavigating = true;

          // Cancel any pending operations
          _hasInitializedData = false;

          // Use a slight delay to prevent UI freezing
          Future.delayed(const Duration(milliseconds: 50), () {
            if (mounted) {
              // Use pushNamedAndRemoveUntil to clear the navigation stack
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false, // Remove all previous routes
              );

              // Reset navigation flag after a delay
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  _isNavigating = false;
                }
              });
            } else {
              // Reset flag even if not mounted to prevent stuck states
              _isNavigating = false;
            }
          });
        }
      },
      child: BlocConsumer<HomeBloc, HomeState>(
        listenWhen: (previous, current) {
          // Only trigger listener when state type actually changes or for specific states
          // Prevent excessive rebuilds by checking if we're navigating
          // Also prevent rebuilds if we're already initialized and just getting more data
          if (_isNavigating) return false;

          if (previous.runtimeType == current.runtimeType) {
            // Only listen for specific state changes even if the type is the same
            return current is PostsError ||
                current is PostCreated ||
                current is PostCreationError;
          }

          // Always listen for state type changes unless we're navigating
          return true;
        },
        listener: (context, state) {
          if (state is PostsError) {
            _logger.e('HOME SCREEN ERROR: ${state.message}', tag: 'HomeScreen');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is PostCreated) {
            _logger.d('HOME SCREEN: Post created successfully',
                tag: 'HomeScreen');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Post created successfully!')),
            );
          } else if (state is PostCreationError) {
            _logger.e(
                'HOME SCREEN ERROR: Error creating post: ${state.message}',
                tag: 'HomeScreen');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error creating post: ${state.message}')),
            );
          } else if (state is PostsLoaded) {
            _logger.d(
                'HOME SCREEN: Posts loaded successfully, count: ${state.posts.length}',
                tag: 'HomeScreen');
          }
        },
        builder: (context, state) {
          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: isDarkMode
                ? AppColors.darkBackground
                : AppColors.backgroundLight,
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
                            theme.colorScheme.primary.withValues(alpha: 0.05),
                            theme.colorScheme.primary.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.2),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                // Journey icon
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: 0.1),
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
                                      color: isDarkMode
                                          ? Colors.white70
                                          : Colors.grey[700],
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
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.3),
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
                  Expanded(
                    child: _selectedIndex == 0
                        ? RefreshIndicator(
                            onRefresh: () async {
                              BlocProvider.of<HomeBloc>(context).add(
                                const FetchPosts(refresh: true),
                              );
                            },
                            child: AllPostsTab(
                              selectedCategory: _selectedCategory,
                            ),
                          )
                        : _selectedIndex == 1
                            ? const ImmiGrovesTab()
                            : NotificationsTab(user: widget.user),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ); // <-- Closing BlocListener
  }
}

class _PostCreationModalWrapper extends StatelessWidget {
  final User user;
  final Function(String, String, String?) onPost;

  const _PostCreationModalWrapper({
    required this.user,
    required this.onPost,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // Adapt the onPost callback to handle the new PostMedia list parameter
    void handlePost(String content, String category, List<dynamic> media) {
      // For backward compatibility, we extract the first media URL if available
      final String? firstMediaUrl = media.isNotEmpty ? media.first.path : null;
      onPost(content, category, firstMediaUrl);
    }

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(bottom: keyboardHeight),
      curve: Curves.easeOut,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 400, // prevents it from taking full screen
            minHeight: 250,
          ),
          // Provide the PostCreationBloc to the PostCreationScreen
          child: BlocProvider(
            create: (context) => PostCreationBloc(),
            child: PostCreationScreen(
              user: user,
              scrollController: ScrollController(),
              onPost: handlePost,
            ),
          ),
        ),
      ),
    );
  }
}
