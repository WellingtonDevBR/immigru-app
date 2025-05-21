import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/home/presentation/bloc/home_bloc.dart';
import 'package:immigru/features/home/presentation/bloc/home_event.dart';
import 'package:immigru/features/home/presentation/bloc/home_state.dart';
import 'package:immigru/features/home/presentation/widgets/post_card.dart';
import 'package:immigru/shared/widgets/error_message_widget.dart';
import 'package:immigru/core/logging/unified_logger.dart';

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

class _AllPostsTabState extends State<AllPostsTab> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final _logger = UnifiedLogger();
  
  // State tracking variables
  bool _isFirstLoad = true;
  bool _isLoadingMore = false;
  
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
          _logger.w('Loading timeout reached, forcing refresh', tag: 'AllPostsTab');
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
        _loadMorePosts();
      }
    }
  }
  
  void _loadMorePosts() {
    // Guard clause to prevent multiple simultaneous loads
    if (_isLoadingMore) {
      _logger.d('Already loading more posts, ignoring request', tag: 'AllPostsTab');
      return;
    }
    
    _isLoadingMore = true;
    _logger.d('Loading more posts for category: ${widget.selectedCategory}', tag: 'AllPostsTab');
    
    try {
      // Use read instead of watch to prevent unnecessary rebuilds
      final homeBloc = context.read<HomeBloc>();
      final currentState = homeBloc.state;
      
      // Additional check to prevent loading more if we're not in a loaded state
      if (currentState is! PostsLoaded) {
        _logger.d('Not in a loaded state, skipping load more', tag: 'AllPostsTab');
        _isLoadingMore = false;
        return;
      }
      
      // Check if we've already reached max
      if (currentState.hasReachedMax) {
        _logger.d('Already reached max posts, skipping load more', tag: 'AllPostsTab');
        _isLoadingMore = false;
        return;
      }
      
      homeBloc.add(FetchMorePosts());
    } catch (e) {
      _logger.e('Error loading more posts: $e', tag: 'AllPostsTab');
      _isLoadingMore = false; // Reset flag immediately on error
    }
    
    // Reset loading flag after a delay to prevent rapid consecutive calls
    // Using a longer delay to ensure the request has time to complete
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _isLoadingMore = false;
        _logger.d('Reset loading flag', tag: 'AllPostsTab');
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
    
    // Only trigger when we're at 80% of the way down to give more time for loading
    // This helps prevent multiple triggers when scrolling quickly
    return currentScroll >= (maxScroll * 0.8);
  }

  void _fetchPosts() {
    // Prevent multiple fetches with comprehensive guard clause
    if (!mounted || _isLoadingMore) {
      _logger.d('Skipping fetch: widget not mounted or already loading', tag: 'AllPostsTab');
      return;
    }
    
    _logger.d('Fetching posts with category: ${widget.selectedCategory}', tag: 'AllPostsTab');
    
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
      
      // If we're in a loaded state and just refreshing, use the current category
      if (currentState is PostsLoaded) {
        _logger.d('Refreshing posts with existing category: ${currentState.selectedCategory}', tag: 'AllPostsTab');
        homeBloc.add(FetchPosts(
          category: currentState.selectedCategory,
          refresh: true,
        ));
      } else {
        // For other states, use the widget's category
        _logger.d('Fetching posts with widget category: ${widget.selectedCategory}', tag: 'AllPostsTab');
        homeBloc.add(FetchPosts(
          category: widget.selectedCategory,
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
          _isFirstLoad = false;
          _isLoadingMore = false;
          _logger.d('Posts loaded successfully: ${state.posts.length} posts', tag: 'AllPostsTab');
        } else if (state is PostsError) {
          _isLoadingMore = false;
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
          _logger.d('Rebuilding for PostsError state', tag: 'AllPostsTab');
          return true;
        }
        
        _logger.d('Skipping rebuild for state transition: ${previous.runtimeType} -> ${current.runtimeType}', tag: 'AllPostsTab');
        return false; // Skip all other state transitions
      },
      builder: (context, state) {
        _logger.d('Building AllPostsTab with state: ${state.runtimeType}', tag: 'AllPostsTab');
        
        if (state is PostsLoading) {
          return _buildLoadingState();
        } else if (state is PostsLoaded) {
          return _buildLoadedState(state);
        } else if (state is PostsError) {
          return _buildErrorState(state);
        }
        
        // For any other state, show loading but don't trigger data fetching
        // This prevents infinite loops with HomeInitial state
        return _buildLoadingState();
      },
    );
  }

  Widget _buildLoadingState() {
    _logger.d('Building loading state, isFirstLoad: $_isFirstLoad', tag: 'AllPostsTab');
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            _isFirstLoad ? 'Loading posts...' : 'Refreshing...',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(PostsLoaded state) {
    final posts = state.posts;
    
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
              onPressed: _fetchPosts,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        _fetchPosts();
      },
      child: Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 80), // Add padding for FAB
            itemCount: posts.length + (state.hasReachedMax ? 0 : 1),
            itemBuilder: (context, index) {
              // Show loading indicator at the bottom when loading more
              if (index == posts.length) {
                if (state.isLoadingMore) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else {
                  // Show "Load More" button instead of automatic loading
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: OutlinedButton(
                        onPressed: _loadMorePosts,
                        child: const Text('Load More'),
                      ),
                    ),
                  );
                }
              }
              
              final post = posts[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                child: PostCard(
                  post: post,
                  onLike: () {
                    // Handle like action
                    context.read<HomeBloc>().add(
                      LikePost(
                        postId: post.id,
                        userId: post.userId,
                        like: !post.isLiked,
                      ),
                    );
                  },
                  onComment: () {
                    // Show comment UI
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Comments coming soon')),
                    );
                  },
                ),
              );
            },
          ),
          
          // Show a top loading indicator when refreshing
          if (state.isLoadingMore)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 4,
                child: const LinearProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(PostsError state) {
    return ErrorMessageWidget(
      message: 'Could not load posts: ${state.message}',
      onRetry: () {
        _fetchPosts();
      },
    );
  }
}
