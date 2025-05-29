import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/shared/widgets/error_message_widget.dart';
import 'package:immigru/features/home/domain/entities/post.dart';
import 'package:immigru/features/home/presentation/bloc/home_bloc.dart';
import 'package:immigru/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:immigru/features/profile/presentation/bloc/profile_event.dart';
import 'package:immigru/features/profile/presentation/bloc/profile_post_events.dart';
import 'package:immigru/features/profile/presentation/bloc/profile_state.dart';
import 'package:immigru/shared/widgets/post_interaction/unified_post_card.dart';
import 'package:get_it/get_it.dart';

/// Widget for displaying user posts in the profile screen
class ProfilePostsTab extends StatefulWidget {
  /// ID of the user whose posts to display
  final String userId;

  /// Whether to disable scrolling within the tab
  final bool disableScrolling;

  /// Constructor
  const ProfilePostsTab({
    super.key,
    required this.userId,
    this.disableScrolling = false,
  });

  @override
  State<ProfilePostsTab> createState() => _ProfilePostsTabState();
}

class _ProfilePostsTabState extends State<ProfilePostsTab> {
  final ScrollController _scrollController = ScrollController();
  final UnifiedLogger _logger = UnifiedLogger();
  bool _isLoadingMore = false;
  late String _sessionId;
  HomeBloc? _homeBloc;
  Timer? _loadingTimeoutTimer;

  // Track pull-to-refresh actions
  DateTime? _lastRefreshTime;
  static const Duration _doublePullThreshold = Duration(milliseconds: 1500);

  @override
  void initState() {
    super.initState();

    // Generate a unique session ID for this instance
    _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    _logger.d(
        'Initializing ProfilePostsTab with session ID: $_sessionId, userId: ${widget.userId}',
        tag: 'ProfilePostsTab:$_sessionId');

    // Add scroll listener for pagination
    // Always add the listener, we'll check disableScrolling in the onScroll method
    _scrollController.addListener(_onScroll);

    // Try to get HomeBloc from GetIt if it's registered
    try {
      _homeBloc = GetIt.instance<HomeBloc>();
      _logger.d('Successfully obtained HomeBloc from GetIt',
          tag: 'ProfilePostsTab:$_sessionId');
    } catch (e) {
      _logger.w('HomeBloc not available in GetIt: $e',
          tag: 'ProfilePostsTab:$_sessionId');
      // HomeBloc is not required for basic functionality, so we can continue without it
    }

    // Initial load of posts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logger.d('Initializing posts for user: ${widget.userId}',
          tag: 'ProfilePostsTab:$_sessionId');

      // Force a fresh load of posts
      _loadPosts(forceRefresh: true);
    });
  }

  @override
  void didUpdateWidget(ProfilePostsTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If scrolling was disabled and is now enabled, we need to handle the transition
    if (oldWidget.disableScrolling && !widget.disableScrolling) {
      _logger.d('Scrolling enabled in posts container',
          tag: 'ProfilePostsTab:$_sessionId');
      // Re-add the scroll listener when scrolling is enabled
      _scrollController.addListener(_onScroll);
    }

    // If scrolling was enabled and is now disabled, we need to handle the transition
    if (!oldWidget.disableScrolling && widget.disableScrolling) {
      _logger.d('Scrolling disabled in posts container',
          tag: 'ProfilePostsTab:$_sessionId');
      // Remove the scroll listener when scrolling is disabled
      _scrollController.removeListener(_onScroll);
      // Reset scroll position to top when transitioning back to profile scrolling
      if (_scrollController.hasClients && _scrollController.offset > 0) {
        _scrollController.jumpTo(0);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _loadingTimeoutTimer?.cancel();
    super.dispose();
  }

  /// Load the user's posts
  void _loadPosts({bool forceRefresh = false}) {
    try {
      _logger.d(
          'Loading posts for user: ${widget.userId}, forceRefresh: $forceRefresh',
          tag: 'ProfilePostsTab:$_sessionId');

      // Check the current state of posts
      final state = context.read<ProfileBloc>().state;
      _logger.d(
          'Current state: postsCount=${state.userPosts?.length}, hasMore=${state.hasMorePosts}',
          tag: 'ProfilePostsTab:$_sessionId');

      // First, refresh user stats to get the latest post count
      if (forceRefresh) {
        context.read<ProfileBloc>().add(LoadUserStats(
              userId: widget.userId,
              bypassCache: true,
            ));
      }

      // Only load posts if they're not already loaded, if forceRefresh is true, or if hasMorePosts is true
      if (forceRefresh || state.userPosts == null || state.userPosts!.isEmpty) {
        if (state.userPosts != null && state.userPosts!.isNotEmpty) {
          _logger.d(
              'First post ID: ${state.userPosts![0].id}, content: ${state.userPosts![0].content.substring(0, min(20, state.userPosts![0].content.length))}...',
              tag: 'ProfilePostsTab:$_sessionId');
        } else {
          _logger.d('No posts in current state, will force a fresh load',
              tag: 'ProfilePostsTab:$_sessionId');
        }

        // Use a more reasonable batch size for initial load to avoid timeouts
        // while still getting a good number of posts
        context.read<ProfileBloc>().add(LoadUserPosts(
              userId: widget.userId,
              bypassCache:
                  forceRefresh, // Only bypass cache if explicitly requested
              limit: 30, // More reasonable initial batch size to avoid timeouts
            ));

        _logger.d('LoadUserPosts event dispatched with limit 30',
            tag: 'ProfilePostsTab:$_sessionId');
      } else if (state.hasMorePosts && !state.isPostsLoading) {
        // If posts are already loaded but hasMorePosts is true, try to load more
        _logger.d(
            'Posts already loaded but hasMorePosts is true. Trying to load more posts.',
            tag: 'ProfilePostsTab:$_sessionId');

        // Get the current post count to use as offset
        final currentPostCount = state.userPosts?.length ?? 0;

        context.read<ProfileBloc>().add(LoadUserPosts(
              userId: widget.userId,
              offset: currentPostCount,
              limit: 20, // Use a reasonable batch size for pagination
              bypassCache:
                  forceRefresh, // Only bypass cache if explicitly requested
            ));
      } else {
        _logger.d(
            'Posts already loaded and hasMorePosts is false. Skipping load request.',
            tag: 'ProfilePostsTab:$_sessionId');
      }
    } catch (e) {
      _logger.e('Error in _loadPosts: $e', tag: 'ProfilePostsTab:$_sessionId');
    }
  }

  /// Handle scroll events for pagination with debouncing
  void _onScroll() {
    // If scrolling is disabled, don't process scroll events
    if (widget.disableScrolling) {
      return;
    }

    // Make sure we have a valid scroll position
    if (!_scrollController.hasClients) {
      return;
    }

    // Simple scroll detection matching home feed implementation
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoadingMore &&
        mounted) {
      // Check if we need to load more posts
      final profileBloc = context.read<ProfileBloc>();
      final currentState = profileBloc.state;

      _logger.d(
          'Scroll position: ${_scrollController.position.pixels}/${_scrollController.position.maxScrollExtent}, '
                  'isLoadingMore: $_isLoadingMore, '
                  'hasMorePosts: ${currentState.hasMorePosts}, '
                  'isPostsLoading: ${currentState.isPostsLoading}, ' +
              'currentPostCount: ${currentState.userPosts?.length ?? 0}',
          tag: 'ProfilePostsTab:$_sessionId');

      if (currentState.hasMorePosts && !currentState.isPostsLoading) {
        _logger.d('Reached 80% scroll threshold, loading more posts',
            tag: 'ProfilePostsTab:$_sessionId');
        _loadMorePosts();
      }
    }
  }

  /// Load more posts for pagination when scrolling
  void _loadMorePosts() {
    // Guard clause to prevent multiple simultaneous loads
    if (_isLoadingMore) {
      _logger.d('Already loading more posts, ignoring request',
          tag: 'ProfilePostsTab:$_sessionId');
      return;
    }

    _isLoadingMore = true;
    _logger.d('Loading more posts - PAGINATION TRIGGERED',
        tag: 'ProfilePostsTab:$_sessionId');

    try {
      // Use read instead of watch to prevent unnecessary rebuilds
      final profileBloc = context.read<ProfileBloc>();
      final currentState = profileBloc.state;

      // More comprehensive state check - ensure we're not currently loading posts
      if (currentState.isPostsLoading) {
        _logger.d(
            'Already loading posts in bloc state, skipping duplicate request',
            tag: 'ProfilePostsTab:$_sessionId');
        _isLoadingMore = false;
        return;
      }

      // Check if we've already reached max
      if (!currentState.hasMorePosts) {
        _logger.d('Already reached max posts, skipping load more',
            tag: 'ProfilePostsTab:$_sessionId');
        _isLoadingMore = false;
        return;
      }

      final currentPosts = currentState.userPosts ?? [];

      _logger.d(
          'Proceeding with loading more posts, current count: ${currentPosts.length}',
          tag: 'ProfilePostsTab:$_sessionId');

      // Use a fixed batch size of 10 for simplicity and consistency
      const int batchSize = 10;

      // Load more posts with the current count as offset
      _logger.d(
          'Requesting more posts with offset=${currentPosts.length}, limit=$batchSize',
          tag: 'ProfilePostsTab:$_sessionId');

      profileBloc.add(LoadUserPosts(
        userId: widget.userId,
        offset: currentPosts.length,
        limit: batchSize,
        bypassCache: true, // Force bypass cache for pagination
      ));

      // Start a timeout to prevent getting stuck in loading state
      _startLoadingMoreTimeout();
    } catch (e) {
      _logger.e('Error loading more posts: $e',
          tag: 'ProfilePostsTab:$_sessionId');
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
          _logger.d('Reset loading flag via timeout',
              tag: 'ProfilePostsTab:$_sessionId');
        });
      }
    });
  }

  /// Handle pull-to-refresh
  Future<void> _onRefresh() async {
    _logger.d('Pull-to-refresh triggered', tag: 'ProfilePostsTab:$_sessionId');

    // Check if this is a double pull (two pulls within the threshold time)
    final now = DateTime.now();
    final isDoublePull = _lastRefreshTime != null &&
        now.difference(_lastRefreshTime!) < _doublePullThreshold;

    if (isDoublePull && !widget.disableScrolling) {
      _logger.d(
          'Double pull-to-refresh detected, switching to profile scrolling',
          tag: 'ProfilePostsTab:$_sessionId');

      // Notify parent to enable profile scrolling and disable posts scrolling
      // We need to use a callback to communicate with the parent widget
      if (mounted) {
        // Reset the refresh time
        _lastRefreshTime = null;

        // Notify the parent through a callback or event
        _notifyProfileToScroll();
        return;
      }
    }

    // Update the last refresh time
    _lastRefreshTime = now;

    // Force a fresh load of posts
    _loadPosts(forceRefresh: true);

    // Wait for a reasonable time to complete the refresh
    await Future.delayed(const Duration(seconds: 2));

    _logger.d('Pull-to-refresh completed', tag: 'ProfilePostsTab:$_sessionId');
    return;
  }

  /// Notify the profile screen to take over scrolling
  void _notifyProfileToScroll() {
    try {
      // Use the ProfileBloc to notify the profile screen
      final profileBloc = context.read<ProfileBloc>();
      profileBloc.add(const EnableProfileScrolling());

      // Prevent immediate scroll back by adding a small delay
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients && mounted) {
          // Ensure we're at the top when transferring control
          _scrollController.jumpTo(0);
        }
      });

      _logger.d('Notified profile screen to take over scrolling',
          tag: 'ProfilePostsTab:$_sessionId');
    } catch (e) {
      _logger.e('Error notifying profile to scroll: $e',
          tag: 'ProfilePostsTab:$_sessionId');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (previous, current) =>
          previous.userPosts != current.userPosts ||
          previous.isPostsLoading != current.isPostsLoading ||
          previous.postsError != current.postsError,
      builder: (context, state) {
        // Debug the state
        _logger.d(
            'Building ProfilePostsTab with state: '
            'postsCount=${state.userPosts?.length}, '
            'isLoading=${state.isPostsLoading}, '
            'hasError=${state.postsError != null}',
            tag: 'ProfilePostsTab:$_sessionId');

        // Create a stack with refresh indicator for all states
        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: _buildContent(context, state, _sessionId),
        );
      },
    );
  }

  /// Build the content based on the current state
  Widget _buildContent(
      BuildContext context, ProfileState state, String requestId) {
    // Debug post counts
    final postCount = state.userPosts?.length ?? 0;
    _logger.d(
        'Building content with $postCount posts, hasMore=${state.hasMorePosts}',
        tag: 'ProfilePostsTab:$_sessionId');

    // Log each post in the state for debugging
    if (state.userPosts != null && state.userPosts!.isNotEmpty) {
      _logger.d('===== POST LIST DEBUG START =====',
          tag: 'ProfilePostsTab:$_sessionId');
      for (int i = 0; i < state.userPosts!.length; i++) {
        final post = state.userPosts![i];
        _logger.d(
            'Post[$i]: ID=${post.id}, UserId=${post.userId}, Content=${post.content.substring(0, min(20, post.content.length))}...',
            tag: 'ProfilePostsTab:$_sessionId');
      }
      _logger.d('===== POST LIST DEBUG END =====',
          tag: 'ProfilePostsTab:$_sessionId');
    }

    // Show loading indicator for initial load
    if (state.isPostsLoading &&
        (state.userPosts == null || state.userPosts!.isEmpty)) {
      _logger.d('Showing loading indicator',
          tag: 'ProfilePostsTab:$_sessionId');
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading posts...',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Show error message if there's an error and no posts
    if (state.postsError != null &&
        (state.userPosts == null || state.userPosts!.isEmpty)) {
      _logger.e('Showing error message: ${state.postsError!.message}',
          tag: 'ProfilePostsTab:$requestId');
      return Center(
        child: ErrorMessageWidget(
          message: state.postsError!.message,
          onRetry: () {
            // Clear error state first
            context.read<ProfileBloc>().add(const ClearPostsError());

            // Force a fresh load on retry after a short delay
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                _loadPosts(forceRefresh: true);
              }
            });
          },
        ),
      );
    }

    // No posts to display
    if (state.userPosts == null || state.userPosts!.isEmpty) {
      _logger.d('Showing empty state', tag: 'ProfilePostsTab:$requestId');
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.post_add,
                  size: 64,
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No posts yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'This user hasn\'t posted anything yet.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _loadPosts(forceRefresh: true),
                  child: const Text('Refresh'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // We have posts to display
    _logger.d('Displaying ${state.userPosts!.length} posts',
        tag: 'ProfilePostsTab:$_sessionId');

    // Create the ListView with appropriate physics based on disableScrolling flag
    return RefreshIndicator(
      onRefresh: _onRefresh,
      // Use custom colors to match the app's theme
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      // Adjust displacement for better UX
      displacement: 40.0,
      // Use a more responsive stroke width
      strokeWidth: 2.5,
      child: ListView.builder(
        controller: _scrollController,
        // Apply the appropriate physics based on disableScrolling flag
        physics: widget.disableScrolling
            ? const NeverScrollableScrollPhysics()
            : const AlwaysScrollableScrollPhysics(),
        // Add cacheExtent to preload items for smoother scrolling
        cacheExtent: 500.0,
        // Remove any padding to eliminate the white gap
        padding: EdgeInsets.zero,
        itemCount: state.userPosts!.length + (state.hasMorePosts ? 1 : 0),
        // Use addAutomaticKeepAlives to prevent rebuilding off-screen items
        addAutomaticKeepAlives: true,
        itemBuilder: (context, index) {
          // Show loading indicator at the bottom
          if (index == state.userPosts!.length) {
            _logger.d('Rendering loading indicator at bottom (index $index)',
                tag: 'ProfilePostsTab:$_sessionId');
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

          // Build a regular post item
          final post = state.userPosts![index];
          _logger.d('Rendering post at index $index: ID=${post.id}',
              tag: 'ProfilePostsTab:$_sessionId');
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: _buildPostItem(context, post, index),
          );
        },
      ),
    );
  }

  /// Updates a post in the state
  void _updatePostInState(Post updatedPost) {
    try {
      // Get the current state
      final state = context.read<ProfileBloc>().state;

      // Check if we have posts
      if (state.userPosts == null || state.userPosts!.isEmpty) {
        _logger.w('No posts to update', tag: 'ProfilePostsTab:$_sessionId');
        return;
      }

      // Find the post index
      final postIndex =
          state.userPosts!.indexWhere((p) => p.id == updatedPost.id);

      if (postIndex == -1) {
        _logger.w('Post not found in state: ${updatedPost.id}',
            tag: 'ProfilePostsTab:$_sessionId');
        return;
      }

      // If this is a like action, dispatch the appropriate event
      final currentPost = state.userPosts![postIndex];
      if (currentPost.isLiked != updatedPost.isLiked) {
        context.read<ProfileBloc>().add(LikeUserPost(
              postId: updatedPost.id,
              isLiked: updatedPost.isLiked,
            ));
        _logger.d('Dispatched LikeUserPost event for post: ${updatedPost.id}',
            tag: 'ProfilePostsTab:$_sessionId');
      }

      // If this is a content update, dispatch the appropriate event
      if (currentPost.content != updatedPost.content) {
        context.read<ProfileBloc>().add(UpdateUserPost(
              postId: updatedPost.id,
              content: updatedPost.content,
            ));
        _logger.d('Dispatched UpdateUserPost event for post: ${updatedPost.id}',
            tag: 'ProfilePostsTab:$_sessionId');
      }

      // If comment status changed, dispatch the appropriate event
      if (currentPost.hasUserComment != updatedPost.hasUserComment) {
        context.read<ProfileBloc>().add(UpdateUserPostCommentStatus(
              postId: updatedPost.id,
              hasUserComment: updatedPost.hasUserComment,
            ));
        _logger.d(
            'Dispatched UpdateUserPostCommentStatus event for post: ${updatedPost.id}',
            tag: 'ProfilePostsTab:$_sessionId');
      }
    } catch (e) {
      _logger.e('Error updating post in state: $e',
          tag: 'ProfilePostsTab:$_sessionId');
    }
  }

  /// Removes a post from the state
  void _removePostFromState(Post deletedPost) {
    try {
      context.read<ProfileBloc>().add(DeleteUserPost(
            postId: deletedPost.id,
          ));
      _logger.d('Dispatched DeleteUserPost event for post: ${deletedPost.id}',
          tag: 'ProfilePostsTab:$_sessionId');
    } catch (e) {
      _logger.e('Error removing post from state: $e',
          tag: 'ProfilePostsTab:$_sessionId');
    }
  }

  /// Build an individual post item
  Widget _buildPostItem(BuildContext context, Post post, int index) {
    _logger.d(
        'Building post item for post ID: ${post.id} at index $index, content: ${post.content.substring(0, min(20, post.content.length))}...',
        tag: 'ProfilePostsTab:$_sessionId');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: UnifiedPostCard(
        key: ValueKey('post-card-${post.id}-$_sessionId'),
        post: post,
        userId: widget.userId,
        tag: 'ProfilePostsTab:$_sessionId',
        showShareButton: false, // Hide share button in profile posts
        homeBloc: _homeBloc, // Pass the HomeBloc for comment navigation
        onPostUpdated: (updatedPost) {
          // Update the post in the state
          _updatePostInState(updatedPost);
        },
        onPostDeleted: (deletedPost) {
          // Remove the post from the state
          _removePostFromState(deletedPost);
        },
      ),
    );
  }
}
