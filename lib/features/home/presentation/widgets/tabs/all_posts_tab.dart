import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/home/domain/entities/post.dart';
import 'package:immigru/features/home/presentation/bloc/home_bloc.dart';
import 'package:immigru/features/home/presentation/bloc/home_event.dart';
import 'package:immigru/features/home/presentation/bloc/home_state.dart';
import 'package:immigru/features/home/presentation/screens/post_comments_screen.dart';
import 'package:immigru/features/home/presentation/widgets/post_card.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// "All Posts" tab showing all posts without category filtering
class AllPostsTab extends StatefulWidget {
  const AllPostsTab({
    super.key,
  });

  @override
  State<AllPostsTab> createState() => _AllPostsTabState();
}

class _AllPostsTabState extends State<AllPostsTab>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final UnifiedLogger _logger = UnifiedLogger();
  final supabase = Supabase.instance.client;

  // State variables
  bool _isLoadingMore = false;
  Timer? _loadingTimeoutTimer;

  // Request ID for logging
  late final String _requestId;

  @override
  bool get wantKeepAlive => true; // Keep state alive when navigating

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _requestId = Random().nextInt(1000000).toString();
    _logger.d('[ALL_POSTS_TAB:$_requestId] Widget initialized',
        tag: 'AllPostsTab');

    // Schedule a post-frame callback to check the HomeBloc state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _logger.d('[ALL_POSTS_TAB:$_requestId] Post-frame callback executing',
            tag: 'AllPostsTab');

        // Check the current state of the HomeBloc
        final homeBloc = context.read<HomeBloc>();
        final currentState = homeBloc.state;

        if (currentState is PostsLoaded && currentState.posts.isNotEmpty) {
          // If we already have posts, use them
          _logger.d(
              '[ALL_POSTS_TAB:$_requestId] Using ${currentState.posts.length} posts from HomeBloc',
              tag: 'AllPostsTab');
        }
        // IMPORTANT: We no longer fetch posts here. This is now handled centrally by HomeScreen._initializeHomeData
        // This eliminates duplicate fetches and provides a single source of truth
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _loadingTimeoutTimer?.cancel();
    super.dispose();
  }

  /// Handle scroll events for pagination with debouncing
  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoadingMore &&
        mounted) {
      // Check if we need to load more posts
      final homeBloc = context.read<HomeBloc>();
      final currentState = homeBloc.state;

      if (currentState is PostsLoaded &&
          !currentState.hasReachedMax &&
          !currentState.isLoadingMore) {
        _loadMorePosts();
      }
    }
  }

  void _loadMorePosts() {
    // Guard clause to prevent multiple simultaneous loads
    if (_isLoadingMore) {
      _logger.d('Already loading more posts, ignoring request',
          tag: 'AllPostsTab');
      return;
    }

    _isLoadingMore = true;
    _logger.d('Loading more posts', tag: 'AllPostsTab');

    try {
      // Use read instead of watch to prevent unnecessary rebuilds
      final homeBloc = context.read<HomeBloc>();
      final currentState = homeBloc.state;

      // More comprehensive state check - ensure we're in a PostsLoaded state
      // that's not currently loading more posts
      if (currentState is! PostsLoaded) {
        _logger.d('Not in a loaded state, skipping load more',
            tag: 'AllPostsTab');
        _isLoadingMore = false;
        return;
      }

      // Don't attempt to load more if we're already loading
      if (currentState.isLoadingMore) {
        _logger.d(
            'Already loading more in bloc state, skipping duplicate request',
            tag: 'AllPostsTab');
        _isLoadingMore = false;
        return;
      }

      // Check if we've already reached max
      if (currentState.hasReachedMax) {
        _logger.d('Already reached max posts, skipping load more',
            tag: 'AllPostsTab');
        _isLoadingMore = false;
        return;
      }

      _logger.d(
          'Proceeding with loading more posts, current count: ${currentState.posts.length}',
          tag: 'AllPostsTab');

      // Get current user ID from Supabase for proper filtering
      final currentUserId = supabase.auth.currentUser?.id;

      if (currentUserId == null) {
        _logger.w('No authenticated user found when loading more posts',
            tag: 'AllPostsTab');
        // Don't proceed with loading more if we don't have a user ID
        _isLoadingMore = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to load more posts')),
        );
        return;
      } else {
        _logger.d('Loading more posts for user: $currentUserId',
            tag: 'AllPostsTab');
      }

      // Simplified pagination with no category filtering
      homeBloc.add(FetchMorePosts(
        category: null, // No category filtering
        currentUserId: currentUserId, // Pass current user ID
      ));

      // Start a timeout to prevent getting stuck in loading state
      _startLoadingMoreTimeout();
    } catch (e) {
      _logger.e('Error loading more posts: $e', tag: 'AllPostsTab');
      _isLoadingMore = false; // Reset flag immediately on error
    }
  }

  // Start a timeout specifically for loading more posts
  void _startLoadingMoreTimeout() {
    // Cancel any existing timer first
    _loadingTimeoutTimer?.cancel();

    // Set a new timer that will force reset the loading state after 5 seconds
    _loadingTimeoutTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _isLoadingMore) {
        setState(() {
          _isLoadingMore = false;
          _logger.d(
              '[ALL_POSTS_TAB:$_requestId] Reset loading flag via timeout',
              tag: 'AllPostsTab');
        });
      }
    });
  }

  /// Method to refresh posts using the efficient refresh mechanism
  Future<void> _refreshPosts() async {
    _logger.d('Refreshing posts efficiently', tag: 'AllPostsTab');

    // Get current user ID from Supabase
    final currentUserId = supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      _logger.e(
          '[ALL_POSTS_TAB:$_requestId] ERROR: No authenticated user found, cannot refresh posts safely',
          tag: 'AllPostsTab');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to refresh posts')),
      );
      return; // Don't refresh without a user ID
    }
    
    // Get the HomeBloc
    final homeBloc = context.read<HomeBloc>();
    
    // Check if we're already in a loading state to prevent duplicate refreshes
    if (homeBloc.state is PostsLoading) {
      _logger.d('Already refreshing posts, ignoring duplicate request', tag: 'AllPostsTab');
      return;
    }
    
    // Add a small delay to make the refresh indicator more visible
    // This improves the user experience by showing the refresh animation
    await Future.delayed(const Duration(milliseconds: 300));
    
    // For now, use the regular FetchPosts event with refresh=true
    // This ensures compatibility with the current architecture
    homeBloc.add(FetchPosts(
      currentUserId: currentUserId,
      category: null, // No category filtering
      refresh: true, // Always refresh to get the latest data
    ));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return BlocConsumer<HomeBloc, HomeState>(
      listenWhen: (previous, current) {
        // Only listen for state changes we care about
        if (previous.runtimeType != current.runtimeType) {
          return true;
        }

        // Listen for changes in the posts list
        if (previous is PostsLoaded && current is PostsLoaded) {
          return previous.posts != current.posts ||
              previous.hasReachedMax != current.hasReachedMax ||
              previous.isLoadingMore != current.isLoadingMore;
        }

        return false;
      },
      listener: (context, state) {
        if (state is PostsLoaded) {
          _logger.d(
              '[ALL_POSTS_TAB:$_requestId] PostsLoaded state received with ${state.posts.length} posts',
              tag: 'AllPostsTab');

          setState(() {
            _isLoadingMore = false; // Reset loading flag when we get new posts
          });
        } else if (state is PostsError) {
          _logger.e('[ALL_POSTS_TAB:$_requestId] Error: ${state.message}',
              tag: 'AllPostsTab');
        }
      },
      builder: (context, state) {
        _logger.d('Rebuilding for ${state.runtimeType} state',
            tag: 'AllPostsTab');

        // Handle different states with proper conditional logic
        if (state is PostsLoading) {
          return _buildLoadingState();
        } else if (state is PostsError) {
          return _buildErrorState(state.message);
        } else if (state is PostsLoaded) {
          _logger.d('Building AllPostsTab with state: PostsLoaded',
              tag: 'AllPostsTab');
          return _buildPostsList(
            state.posts,
            state.hasReachedMax,
            isLoadingMore: state.isLoadingMore,
          );
        } else {
          // Default to loading state for any other state
          return _buildLoadingState(isFirstLoad: true);
        }
      },
    );
  }

  Widget _buildLoadingState({bool isFirstLoad = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isFirstLoad) ...[
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Loading posts...'),
          ] else ...[
            const CircularProgressIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _buildPostsList(List<Post> posts, bool hasReachedMax,
      {bool isLoadingMore = false}) {
    _logger.d('Building posts list with ${posts.length} posts',
        tag: 'AllPostsTab');

    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No posts yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Be the first to share your journey!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshPosts,
      // Use custom colors to match the app's theme
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      // Adjust displacement for better UX
      displacement: 40.0,
      // Use a more responsive stroke width
      strokeWidth: 2.5,
      // Optimize ListView with better caching
      child: ListView.builder(
        controller: _scrollController,
        // Always allow scrolling for pull-to-refresh even when content is short
        physics: const AlwaysScrollableScrollPhysics(),
        // Add cacheExtent to preload items for smoother scrolling
        cacheExtent: 500.0,
        itemCount: posts.length + (hasReachedMax ? 0 : 1),
        // Use addAutomaticKeepAlives to prevent rebuilding off-screen items
        addAutomaticKeepAlives: true,
        itemBuilder: (context, index) {
          if (index >= posts.length) {
            // Show enhanced loading indicator at the bottom when loading more
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Loading more posts...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final post = posts[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: PostCard(
              post: post,
              onLike: () {
                // Handle like action
                _logger.d('Like button pressed for post: ${post.id}',
                    tag: 'AllPostsTab');
                
                // Get current user ID from Supabase
                final currentUserId = supabase.auth.currentUser?.id;
                if (currentUserId != null) {
                  // Dispatch LikePost event to the HomeBloc
                  context.read<HomeBloc>().add(LikePost(
                    postId: post.id,
                    userId: currentUserId,
                    like: !post.isLiked, // Toggle the current like state
                  ));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('You need to be logged in to like posts'),
                    ),
                  );
                }
              },
              onComment: () {
                // Navigate to comments screen when comment button is pressed
                final currentUserId = supabase.auth.currentUser?.id;
                if (currentUserId != null) {
                  // Get the HomeBloc from the current context
                  final homeBloc =
                      BlocProvider.of<HomeBloc>(context, listen: false);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostCommentsScreen(
                        post: post,
                        userId: currentUserId,
                        homeBloc:
                            homeBloc, // Pass the HomeBloc to the PostCommentsScreen
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please sign in to view comments')),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }

  /// Build the error state widget with a retry button
  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading posts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Use the centralized refresh mechanism
              _refreshPosts();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
