import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/home/domain/entities/post.dart';
import 'package:immigru/features/home/presentation/bloc/home_bloc.dart';
import 'package:immigru/features/home/presentation/bloc/home_event.dart';
import 'package:immigru/features/home/presentation/bloc/home_state.dart';
import 'package:immigru/features/home/presentation/screens/post_comments_screen.dart';
import 'package:immigru/features/home/presentation/widgets/post_card.dart';
import 'package:immigru/shared/widgets/error_message_widget.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// "All Posts" tab showing posts with category filtering
class AllPostsTab extends StatefulWidget {
  final String selectedCategory;

  const AllPostsTab({
    super.key,
    required this.selectedCategory,
  });

  @override
  State<AllPostsTab> createState() => _AllPostsTabState();
}

class _AllPostsTabState extends State<AllPostsTab>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final _logger = UnifiedLogger();

  // State tracking variables
  bool _isLoadingMore = false;

  // Local posts list to manage likes without relying on bloc state
  List<Post> _localPosts = [];

  // Add a timeout to prevent getting stuck in loading state
  Timer? _loadingTimeoutTimer;

  @override
  bool get wantKeepAlive => true; // Keep state alive when navigating

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _logger.d('AllPostsTab initialized', tag: 'AllPostsTab');

    // Set a timeout to prevent getting stuck in loading state
    _startLoadingTimeout();
  }

  // Start a timeout to prevent getting stuck in loading state
  void _startLoadingTimeout() {
    // Cancel any existing timer
    _loadingTimeoutTimer?.cancel();

    // Set a new timer to check if we're still loading after 10 seconds
    _loadingTimeoutTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        final homeBloc = context.read<HomeBloc>();
        final currentState = homeBloc.state;

        // If we're still in a loading state after the timeout, force a refresh
        if (currentState is PostsLoading) {
          _logger.w('Loading timeout reached, forcing refresh',
              tag: 'AllPostsTab');
          _isLoadingMore = false;
          _fetchPosts();
        }
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
    // Comprehensive guard clause to prevent excessive calls
    if (!_scrollController.hasClients || _isLoadingMore) {
      return;
    }

    // Only load more if we're near the bottom
    if (_isNearBottom()) {
      final state = context.read<HomeBloc>().state;

      if (state is PostsLoaded && !state.hasReachedMax) {
        // Add a small delay to prevent multiple calls when scrolling quickly
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && !_isLoadingMore) {
            _loadMorePosts();
          }
        });
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
    _logger.d('Loading more posts for category: ${widget.selectedCategory}',
        tag: 'AllPostsTab');

    try {
      // Use read instead of watch to prevent unnecessary rebuilds
      final homeBloc = context.read<HomeBloc>();
      final currentState = homeBloc.state;

      // Additional check to prevent loading more if we're not in a loaded state
      if (currentState is! PostsLoaded) {
        _logger.d('Not in a loaded state, skipping load more',
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

      // Always exclude current user's posts when loading more
      final supabase = Supabase.instance.client;
      final currentUserId = supabase.auth.currentUser?.id;
      
      homeBloc.add(FetchMorePosts(
        filter: currentState.filter,
        category: currentState.selectedCategory,
        userId: currentState.userId,
        immigroveId: currentState.immigroveId,
        excludeCurrentUser: true, // Always exclude current user's posts
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
          _logger.d('Reset loading flag via timeout', tag: 'AllPostsTab');
        });
      }
    });
  }

  /// Check if the user has scrolled to the bottom
  bool _isNearBottom() {
    if (!_scrollController.hasClients) return false;

    // Add more comprehensive checks to prevent false positives
    if (_scrollController.position.outOfRange) return false;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    // Consider we're at the bottom when we're within 200 pixels of the end
    // This is more reliable than using a percentage
    return maxScroll - currentScroll <= 200;
  }

  void _fetchPosts() {
    // Prevent multiple fetches with comprehensive guard clause
    if (!mounted || _isLoadingMore) {
      _logger.d('Skipping fetch: widget not mounted or already loading',
          tag: 'AllPostsTab');
      return;
    }

    _logger.d('Fetching posts with category: ${widget.selectedCategory}',
        tag: 'AllPostsTab');

    _isLoadingMore = true;

    try {
      // Use context.read for one-time access to the bloc
      final homeBloc = context.read<HomeBloc>();

      // Check current state to avoid duplicate fetches
      final currentState = homeBloc.state;

      // More comprehensive state checking
      if (currentState is PostsLoading) {
        _logger.d('Posts already loading, skipping fetch', tag: 'AllPostsTab');
        _isLoadingMore = false;
        return;
      }

      // If we're in a loaded state and just refreshing, use the current filter parameters
      if (currentState is PostsLoaded) {
        _logger.d(
            'Refreshing posts with existing filter: ${currentState.filter}, category: ${currentState.selectedCategory}',
            tag: 'AllPostsTab');
        homeBloc.add(FetchPosts(
          filter: currentState.filter,
          category: currentState.selectedCategory,
          userId: currentState.userId,
          immigroveId: currentState.immigroveId,
          excludeCurrentUser: currentState.excludeCurrentUser,
          currentUserId: currentState.currentUserId,
          refresh: true,
        ));
      } else {
        // For other states, use the widget's category with default filter
        _logger.d(
            'Fetching posts with widget category: ${widget.selectedCategory}',
            tag: 'AllPostsTab');
        // Get the current user ID from Supabase
        final supabase = Supabase.instance.client;
        final currentUserId = supabase.auth.currentUser?.id;
        
        homeBloc.add(FetchPosts(
          filter: 'all',  // Default filter for the main feed
          category: widget.selectedCategory,
          excludeCurrentUser: true,  // Exclude current user's posts
          currentUserId: currentUserId,  // Pass current user ID
          refresh: true,
        ));
      }

      _logger.d('FetchPosts event dispatched', tag: 'AllPostsTab');
    } catch (e) {
      _logger.e('Error dispatching FetchPosts event: $e', tag: 'AllPostsTab');
      _isLoadingMore = false; // Reset immediately on error
    }

    // Reset loading flag after a longer delay to ensure completion
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _isLoadingMore = false;
        _logger.d('Reset loading flag after fetch', tag: 'AllPostsTab');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return BlocConsumer<HomeBloc, HomeState>(
      listenWhen: (previous, current) {
        // Only listen for specific state transitions to prevent excessive callbacks
        if (current is PostsLoaded && previous is PostsLoading) {
          return true; // Listen when posts finish loading
        }
        if (current is PostsError) {
          return true; // Always listen for errors
        }
        return false; // Ignore other state transitions
      },
      listener: (context, state) {
        if (state is PostsLoaded) {
          // Always reset loading flag when posts are loaded
          _isLoadingMore = false;
          _loadingTimeoutTimer?.cancel(); // Cancel any pending timeout
          
          _logger.d('Posts loaded successfully: ${state.posts.length} posts',
              tag: 'AllPostsTab');

          // Update our local posts list with the new data from the bloc
          // but preserve any local like state changes
          if (_localPosts.isEmpty) {
            setState(() {
              _localPosts = List.from(state.posts);
            });
          } else {
            // Check if this is a pagination update (more posts added)
            if (state.posts.length > _localPosts.length) {
              _logger.d('Pagination update detected, adding ${state.posts.length - _localPosts.length} new posts',
                  tag: 'AllPostsTab');
            }
            // Merge new posts with our local state
            _updateLocalPostsFromState(state.posts);
          }
        } else if (state is PostsError) {
          _isLoadingMore = false;
          _loadingTimeoutTimer?.cancel(); // Cancel any pending timeout
          _logger.e('Post loading error: ${state.message}', tag: 'AllPostsTab');

          // Show error message to user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      buildWhen: (previous, current) {
        // Strict conditions to prevent unnecessary rebuilds

        // For PostsLoading, only rebuild if coming from a non-loading state
        if (current is PostsLoading && previous is! PostsLoading) {
          _logger.d('Rebuilding for PostsLoading state', tag: 'AllPostsTab');
          return true;
        }

        // Always rebuild for PostsLoaded state
        if (current is PostsLoaded) {
          _logger.d('Rebuilding for PostsLoaded state', tag: 'AllPostsTab');
          return true;
        }

        // Always rebuild for PostsError state
        if (current is PostsError) {
          return true;
        }

        return false;
      },
      builder: (context, state) {
        _logger.d('Building AllPostsTab with state: ${state.runtimeType}',
            tag: 'AllPostsTab');

        if (state is HomeInitial ||
            (state is PostsLoading && state.currentPosts == null)) {
          _logger.d('Building loading state, isFirstLoad: true',
              tag: 'AllPostsTab');
          return _buildLoadingState(isFirstLoad: true);
        } else if (state is PostsLoading) {
          _logger.d('Rebuilding for PostsLoading state', tag: 'AllPostsTab');
          return _buildLoadingState(isFirstLoad: false);
        } else if (state is PostsLoaded) {
          return _buildPostsList(
              _localPosts.isEmpty ? state.posts : _localPosts,
              state.hasReachedMax,
              state.isLoadingMore);
        } else if (state is PostsError) {
          return ErrorMessageWidget(
            message: state.message,
            onRetry: _refreshPosts,
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  void _updateLocalPostsFromState(List<Post> newPosts) {
    // Create a map of existing posts by ID for quick lookup
    final existingPostsMap = {for (var post in _localPosts) post.id: post};

    // Update local posts list with new posts, preserving like state for existing posts
    setState(() {
      _localPosts = newPosts.map((newPost) {
        // If we have this post locally and its like state is different from the new one,
        // preserve our local like state (user's recent interactions)
        final existingPost = existingPostsMap[newPost.id];
        if (existingPost != null) {
          return newPost.copyWith(
            isLiked: existingPost.isLiked,
            likeCount: existingPost.likeCount,
          );
        }
        return newPost;
      }).toList();
    });
  }

  Widget _buildLoadingState({bool isFirstLoad = false}) {
    _logger.d('Building loading state, isFirstLoad: $isFirstLoad',
        tag: 'AllPostsTab');

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            isFirstLoad ? 'Loading posts...' : 'Refreshing...',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList(
      List<Post> posts, bool hasReachedMax, bool isLoadingMore) {
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.article_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No posts found. Be the first to share your journey!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshPosts,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _refreshPosts();
      },
      child: Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 80), // Add padding for FAB
            itemCount: posts.length + (hasReachedMax ? 0 : 1),
            itemBuilder: (context, index) {
              if (index == posts.length) {
                if (isLoadingMore) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _isLoadingMore = false;
                          });
                          _loadMorePosts();
                        },
                        child: const Text('Load More'),
                      ),
                    ),
                  );
                }
              }

              final post = posts[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                child: PostCard(
                  post: post,
                  onComment: () {
                    // Navigate to the comments screen
                    final currentState = context.read<HomeBloc>().state;
                    String userId = '';
                    
                    // Get the current user ID from the state if available
                    if (currentState is PostsLoaded && currentState.currentUserId != null) {
                      userId = currentState.currentUserId!;
                    }
                    
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PostCommentsScreen(
                          post: post,
                          userId: userId,
                        ),
                      ),
                    ).then((_) {
                      // Refresh posts when returning from comments screen
                      // to get updated comment counts
                      _refreshPosts();
                    });
                  },
                  onLike: () {
                    // Handle like action locally without using LikePost event
                    // This is a temporary solution until the LikePost event handler is implemented
                    final updatedPost = post.copyWith(
                      isLiked: !post.isLiked,
                      likeCount: post.isLiked
                          ? post.likeCount - 1
                          : post.likeCount + 1,
                    );

                    // Update the local posts list with the updated post
                    setState(() {
                      final index =
                          _localPosts.indexWhere((p) => p.id == post.id);
                      if (index != -1) {
                        _localPosts[index] = updatedPost;
                      }
                    });

                    // Show a temporary message for feedback
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(updatedPost.isLiked
                            ? 'Post liked'
                            : 'Post unliked'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _refreshPosts() {
    if (mounted) {
      _fetchPosts();
    }
  }
}
