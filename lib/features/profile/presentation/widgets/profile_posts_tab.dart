import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/shared/widgets/error_message_widget.dart';
import 'package:immigru/shared/widgets/loading_indicator.dart';
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

  /// Constructor
  const ProfilePostsTab({
    super.key,
    required this.userId,
  });

  @override
  State<ProfilePostsTab> createState() => _ProfilePostsTabState();
}

class _ProfilePostsTabState extends State<ProfilePostsTab> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  late final UnifiedLogger _logger = GetIt.instance<UnifiedLogger>();
  String _sessionId = DateTime.now().millisecondsSinceEpoch.toString().substring(5);
  HomeBloc? _homeBloc;

  @override
  void initState() {
    super.initState();

    // Set up scroll controller for pagination
    _scrollController.addListener(_onScroll);
    
    // Try to get HomeBloc from GetIt if it's registered
    try {
      _homeBloc = GetIt.instance<HomeBloc>();
      _logger.d('Successfully obtained HomeBloc from GetIt', tag: 'ProfilePostsTab:$_sessionId');
    } catch (e) {
      _logger.w('HomeBloc not available in GetIt: $e', tag: 'ProfilePostsTab:$_sessionId');
      // HomeBloc is not required for basic functionality, so we can continue without it
    }

    // Initial load of posts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final requestId =
          DateTime.now().millisecondsSinceEpoch.toString().substring(5);
      debugPrint(
          '[PROFILE_POSTS_TAB:$requestId] Initializing posts for user: ${widget.userId}');

      // Force a fresh load of posts
      _loadPosts(forceRefresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
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
          'Current state: postsCount=${state.userPosts?.length}, ' +
              'isLoading=${state.isPostsLoading}, hasError=${state.postsError != null}',
          tag: 'ProfilePostsTab:$_sessionId');

      // Don't load if already loading
      if (state.isPostsLoading) {
        _logger.d('Already loading posts, skipping request', tag: 'ProfilePostsTab:$_sessionId');
        return;
      }

      // Only load posts if they're not already loaded or if forceRefresh is true
      if (forceRefresh || state.userPosts == null || state.userPosts!.isEmpty) {
        if (state.userPosts != null && state.userPosts!.isNotEmpty) {
          _logger.d('First post ID: ${state.userPosts![0].id}, content: ${state.userPosts![0].content.substring(0, min(20, state.userPosts![0].content.length))}...',
              tag: 'ProfilePostsTab:$_sessionId');
        } else {
          _logger.d('No posts in current state, will force a fresh load', tag: 'ProfilePostsTab:$_sessionId');
        }

        // Make sure we're using the correct userId and force a fresh load
        context.read<ProfileBloc>().add(LoadUserPosts(
              userId: widget.userId,
              bypassCache: forceRefresh, // Only bypass cache if explicitly requested
              limit: 20, // Increase limit to ensure we get all posts
            ));

        _logger.d('LoadUserPosts event dispatched', tag: 'ProfilePostsTab:$_sessionId');
      } else {
        _logger.d('Posts already loaded, skipping load request', tag: 'ProfilePostsTab:$_sessionId');
      }
    } catch (e) {
      _logger.e('Error loading posts: $e', tag: 'ProfilePostsTab:$_sessionId');
    }
  }

  /// Handle scroll events for pagination
  void _onScroll() {
    if (_isLoadingMore) return;

    final state = context.read<ProfileBloc>().state;
    if (!state.hasMorePosts) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // Load more posts when user scrolls to 80% of the list
    if (currentScroll >= (maxScroll * 0.8)) {
      _loadMorePosts();
    }
  }

  /// Load more posts for pagination
  void _loadMorePosts() {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final state = context.read<ProfileBloc>().state;
      final currentPosts = state.userPosts ?? [];

      // Make sure we're using the correct userId for pagination
      context.read<ProfileBloc>().add(LoadUserPosts(
            userId: widget.userId,
            offset: currentPosts.length,
          ));

      // Set a timeout to reset loading state in case of errors
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted && _isLoadingMore) {
          setState(() {
            _isLoadingMore = false;
          });
        }
      });
    } catch (e) {
      debugPrint('Error loading more posts: $e');
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  /// Handle pull-to-refresh
  Future<void> _onRefresh() async {
    context.read<ProfileBloc>().add(LoadUserPosts(
          userId: widget.userId,
          bypassCache: true,
        ));

    // Wait for a short time to simulate the refresh
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    // Don't update session ID on every build to avoid unnecessary rebuilds
    _logger.d('Building widget with userId=${widget.userId}', tag: 'ProfilePostsTab:$_sessionId');

    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) =>
          previous.userPosts != current.userPosts ||
          previous.isPostsLoading != current.isPostsLoading ||
          previous.postsError != current.postsError,
      listener: (context, state) {
        // Debug information when state changes
        _logger.d('State changed: ' +
            'postsCount=${state.userPosts?.length}, ' +
            'isLoading=${state.isPostsLoading}, ' +
            'hasError=${state.postsError != null}',
            tag: 'ProfilePostsTab:$_sessionId');
        
        // Log the first few posts if available
        if (state.userPosts != null && state.userPosts!.isNotEmpty) {
          for (int i = 0; i < min(3, state.userPosts!.length); i++) {
            final post = state.userPosts![i];
            _logger.d('Post $i: id=${post.id}, content=${post.content.substring(0, min(20, post.content.length))}...',
                tag: 'ProfilePostsTab:$_sessionId');
          }
        } else {
          _logger.d('No posts available in state', tag: 'ProfilePostsTab:$_sessionId');
        }
        
        // Reset loading more flag when loading completes
        if (!state.isPostsLoading && _isLoadingMore) {
          setState(() {
            _isLoadingMore = false;
          });
        }
      },
      buildWhen: (previous, current) =>
          previous.userPosts != current.userPosts ||
          previous.isPostsLoading != current.isPostsLoading ||
          previous.postsError != current.postsError ||
          previous.hasMorePosts != current.hasMorePosts,
      builder: (context, state) {
        // Debug information
        _logger.d('Building content: '
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

  /// Build the appropriate content based on the current state
  Widget _buildContent(
      BuildContext context, ProfileState state, String requestId) {
    // Show loading indicator for initial load
    if (state.isPostsLoading &&
        (state.userPosts == null || state.userPosts!.isEmpty)) {
      _logger.d('Showing loading indicator', tag: 'ProfilePostsTab:$requestId');
      return const Center(
        child: LoadingIndicator(),
      );
    }

    // Show error message if there's an error
    if (state.postsError != null &&
        (state.userPosts == null || state.userPosts!.isEmpty)) {
      _logger.e('Showing error message: ${state.postsError!.message}', 
          tag: 'ProfilePostsTab:$requestId');
      return Center(
        child: ErrorMessageWidget(
          message: state.postsError!.message,
          onRetry: () {
            // Force a fresh load on retry
            _loadPosts(forceRefresh: true);
          },
        ),
      );
    }
    
    // Debug the state
    _logger.d('State in _buildContent: postsCount=${state.userPosts?.length}, ' +
        'isLoading=${state.isPostsLoading}, hasError=${state.postsError != null}',
        tag: 'ProfilePostsTab:$requestId');

    // Check if we have posts to display
    if (state.userPosts != null && state.userPosts!.isNotEmpty) {
      _logger.d('Displaying ${state.userPosts!.length} posts', 
          tag: 'ProfilePostsTab:$requestId');

      // Debug each post
      for (int i = 0; i < min(state.userPosts!.length, 3); i++) {
        final post = state.userPosts![i];
        final contentPreview = post.content.isEmpty
            ? 'No content'
            : post.content.substring(0, min(20, post.content.length)) + '...';
        _logger.d('Post $i: id=${post.id}, content=$contentPreview', 
            tag: 'ProfilePostsTab:$requestId');
      }

      // Return a ListView with the posts
      return ListView.separated(
        key: ValueKey('profile-posts-${state.userPosts!.length}-$requestId'),
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.userPosts!.length + (state.hasMorePosts ? 1 : 0),
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          // Show loading indicator at the bottom for pagination
          if (index == state.userPosts!.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final post = state.userPosts![index];
          _logger.d('Building post at index $index: ${post.id}', 
              tag: 'ProfilePostsTab:$requestId');

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: UnifiedPostCard(
              key: ValueKey('post-card-${post.id}-$requestId'),
              post: post,
              userId: widget.userId,
              tag: 'ProfilePostsTab:$requestId',
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
        },
      );
    }

    // Show empty state if there are no posts
    _logger.d('Showing empty state', tag: 'ProfilePostsTab:$requestId');
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
      final postIndex = state.userPosts!.indexWhere((p) => p.id == updatedPost.id);
      
      if (postIndex == -1) {
        _logger.w('Post not found in state: ${updatedPost.id}', tag: 'ProfilePostsTab:$_sessionId');
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
        _logger.d('Dispatched UpdateUserPostCommentStatus event for post: ${updatedPost.id}', 
            tag: 'ProfilePostsTab:$_sessionId');
      }
    } catch (e) {
      _logger.e('Error updating post in state: $e', tag: 'ProfilePostsTab:$_sessionId');
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
      _logger.e('Error removing post from state: $e', tag: 'ProfilePostsTab:$_sessionId');
    }
  }
}
