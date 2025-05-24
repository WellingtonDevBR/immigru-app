import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/features/auth/domain/entities/user.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_event.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_state.dart';
import 'package:immigru/features/home/presentation/bloc/home_bloc.dart';
import 'package:immigru/features/home/presentation/bloc/home_event.dart';
import 'package:immigru/features/home/presentation/bloc/home_state.dart';
import 'package:immigru/features/home/presentation/widgets/home/home_app_bar.dart';
import 'package:immigru/features/home/presentation/widgets/home/home_bottom_navigation.dart';
import 'package:immigru/features/home/presentation/widgets/home/home_drawer.dart';
import 'package:immigru/features/home/presentation/widgets/home/post_creation_modal.dart';
import 'package:immigru/features/home/presentation/widgets/tabs/all_posts_tab.dart';
import 'package:immigru/features/home/presentation/widgets/tabs/immi_groves_tab.dart';
import 'package:immigru/features/home/presentation/widgets/tabs/notifications_tab.dart';
import 'package:immigru/shared/theme/app_colors.dart';

/// Main home screen of the application
/// Displays posts, ImmiGroves, and notifications
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
    with AutomaticKeepAliveClientMixin {
  // Core components
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final UnifiedLogger _logger = UnifiedLogger();

  // UI state
  int _selectedIndex = 0;
  bool hasUnreadMessages = false;
  int unreadMessageCount = 0;
  bool _isNavigating = false;

  @override
  bool get wantKeepAlive => true; // Keep state alive when navigating

  @override
  void initState() {
    super.initState();
    
    // Initialize data after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeHomeData();
      }
    });
    
    // Log initialization
    _logger.d('HomeScreen initialized', tag: 'HomeScreen');
  }

  /// Initialize home screen data using BLoC
  void _initializeHomeData() {
    final homeBloc = BlocProvider.of<HomeBloc>(context);
    final authBloc = BlocProvider.of<AuthBloc>(context);
    final authState = authBloc.state;
    final currentUser = authState.user ?? widget.user;
    final currentState = homeBloc.state;
    final String? currentUserId = currentUser?.id;
    
    // Check if we already have loaded posts
    if (currentState is PostsLoaded && currentState.posts.isNotEmpty) {
      _logger.d('Home screen already has posts, skipping initialization', tag: 'HomeScreen');
      return;
    }
    
    // SAFETY CHECK: Don't proceed with fetching if we don't have a user ID
    // This prevents the issue where posts are fetched without proper filtering
    if (currentUserId == null) {
      _logger.e('ERROR: No authenticated user found, cannot initialize home data safely', tag: 'HomeScreen');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to view posts')),
      );
      return; // Don't initialize without a user ID
    }
    
    _logger.d('Initializing home data with currentUserId: $currentUserId', tag: 'HomeScreen');
    
    // Initialize with no category filtering and a valid user ID
    homeBloc.add(InitializeHomeData(
      userId: currentUserId, // Always use a valid user ID
      category: null, // No category filtering
      forceRefresh: false, // Let the bloc decide if we need to refresh
    ));
  }
  
  @override
  void dispose() {
    super.dispose();
  }

  /// Show the post creation modal
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

    // Capture the HomeBloc before opening the modal
    final homeBloc = BlocProvider.of<HomeBloc>(context);
    
    // Use the extracted component to show the modal
    showPostCreationModal(
      context: context,
      user: currentUser,
      homeBloc: homeBloc,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

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
            endDrawer: HomeDrawer(
              user: widget.user,
              onLogout: () {
                final authBloc = BlocProvider.of<AuthBloc>(context);
                authBloc.add(AuthSignOutEvent());
              },
            ),
            bottomNavigationBar: HomeBottomNavigation(
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              onMenuTap: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
            ),
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
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
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
                              // Get the current user ID to ensure proper filtering
                              final authBloc = BlocProvider.of<AuthBloc>(context);
                              final authState = authBloc.state;
                              final currentUser = authState.user ?? widget.user;
                              final String? currentUserId = currentUser?.id;
                              
                              // SAFETY CHECK: Don't proceed with fetching if we don't have a user ID
                              if (currentUserId == null) {
                                _logger.e('ERROR: No authenticated user found, cannot refresh posts safely', tag: 'HomeScreen');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please sign in to refresh posts')),
                                );
                                return; // Don't refresh without a user ID
                              }
                              
                              _logger.d('Refreshing posts with currentUserId: $currentUserId', tag: 'HomeScreen');
                              
                              // Always include the current user ID when refreshing
                              BlocProvider.of<HomeBloc>(context).add(
                                FetchPosts(
                                  refresh: true,
                                  currentUserId: currentUserId, // CRITICAL: Always include user ID
                                ),
                              );
                            },
                            child: const AllPostsTab(),
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
    );
  }
}

