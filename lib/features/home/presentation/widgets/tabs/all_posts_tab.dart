import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/home/domain/entities/post.dart';
import 'package:immigru/features/home/presentation/bloc/home_bloc.dart';
import 'package:immigru/features/home/presentation/bloc/home_event.dart';
import 'package:immigru/features/home/presentation/bloc/home_state.dart';
import 'package:immigru/features/home/presentation/widgets/post_card.dart';
import 'package:immigru/shared/widgets/error_message_widget.dart';
import 'package:immigru/shared/widgets/loading_indicator.dart';
import 'package:immigru/core/logging/unified_logger.dart';

/// "All Posts" tab showing posts with category filtering
class AllPostsTab extends StatefulWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const AllPostsTab({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  State<AllPostsTab> createState() => _AllPostsTabState();
}

class _AllPostsTabState extends State<AllPostsTab> {
  final ScrollController _scrollController = ScrollController();
  final _logger = UnifiedLogger();
  bool _isFirstLoad = true;
  int _retryCount = 0;
  static const int _maxRetries = 3;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Add a small delay before triggering the initial fetch to ensure the bloc is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPosts();
    });
  }

  void _fetchPosts() {
    _logger.d('Fetching posts with category: ${widget.selectedCategory}',
        tag: 'AllPostsTab');
    BlocProvider.of<HomeBloc>(context).add(
      FetchPosts(category: widget.selectedCategory, refresh: true),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Handle scroll events for pagination
  void _onScroll() {
    if (_isBottom) {
      final homeBloc = BlocProvider.of<HomeBloc>(context);
      final currentState = homeBloc.state;

      if (currentState is PostsLoaded && !currentState.hasReachedMax) {
        homeBloc.add(const FetchMorePosts());
      }
    }
  }

  /// Check if the user has scrolled to the bottom
  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is PostsError) {
          _logger.e('Post error: ${state.message}', tag: 'AllPostsTab');
          // Show a snackbar with the error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      builder: (context, state) {
        _logger.d('Current state: ${state.runtimeType}', tag: 'AllPostsTab');

        // Handle different states
        if (state is PostsLoading) {
          return _buildLoadingState(state);
        } else if (state is PostsLoaded) {
          return _buildLoadedState(state);
        } else if (state is PostsError) {
          return ErrorMessageWidget(
            message: 'Could not load posts: ${state.message}',
            onRetry: () {
              _retryCount = 0;
              _fetchPosts();
            },
          );
        } else if (state is PostCreated) {
          // After post creation, refresh the feed
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _fetchPosts();
          });
          return _buildLoadingState(null);
        }

        // Initial state or other states
        if (_isFirstLoad && !_isRetrying) {
          _isRetrying = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _fetchPosts();
          });
        }
        return _buildLoadingState(null);
      },
    );
  }

  /// Build the loading state
  Widget _buildLoadingState(PostsLoading? state) {
    _logger.d('Building loading state, isFirstLoad: $_isFirstLoad',
        tag: 'AllPostsTab');

    if (state != null &&
        state.currentPosts != null &&
        state.currentPosts!.isNotEmpty) {
      // Show current posts with loading indicator at bottom
      return _buildPostsList(
        state.currentPosts!,
        showBottomLoader: true,
        hasReachedMax: false,
      );
    }

    // If we've been loading for too long on first load, show retry button
    if (_isFirstLoad && _retryCount < _maxRetries && !_isRetrying) {
      _isRetrying = true;
      // Auto-retry after a short delay
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isFirstLoad) {
          _retryCount++;
          _isRetrying = false;
          _logger.d('Auto-retrying post fetch, attempt: $_retryCount',
              tag: 'AllPostsTab');
          _fetchPosts();
        } else {
          _isRetrying = false;
        }
      });
    }

    // Show loading indicator
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LoadingIndicator(),
          if (_retryCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                'Loading posts... (Attempt $_retryCount)',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
        ],
      ),
    );
  }

  /// Build the loaded state with posts
  Widget _buildLoadedState(PostsLoaded state) {
    // Reset flags since we successfully loaded posts
    _isFirstLoad = false;
    _retryCount = 0;

    _logger.d('Posts loaded: ${state.posts.length}', tag: 'AllPostsTab');

    return state.posts.isEmpty
        ? _buildEmptyState()
        : _buildPostsList(
            state.posts,
            showBottomLoader: !state.hasReachedMax,
            hasReachedMax: state.hasReachedMax,
          );
  }

  /// Build the list of posts
  Widget _buildPostsList(
    List<Post> posts, {
    bool showBottomLoader = false,
    required bool hasReachedMax,
  }) {
    return RefreshIndicator(
      onRefresh: () async {
        BlocProvider.of<HomeBloc>(context).add(
          FetchPosts(category: widget.selectedCategory, refresh: true),
        );
      },
      child: ListView.separated(
        controller: _scrollController,
        itemCount: posts.length + (showBottomLoader ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        padding: const EdgeInsets.only(
            bottom: 72), // Extra padding for bottom nav bar
        itemBuilder: (context, index) {
          if (index >= posts.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: LoadingIndicator(),
              ),
            );
          }

          final post = posts[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: PostCard(
              post: post,
              onLike: () {
                BlocProvider.of<HomeBloc>(context).add(
                  LikePost(
                      postId: post.id,
                      userId: post.userId,
                      like: !post.isLiked),
                );
              },
              onComment: () {
                // Navigate to comments screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Comments coming soon')),
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// Build the empty state when no posts are available
  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.grey.shade800.withValues(alpha: 0.5)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 60,
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Posts Found',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.selectedCategory == 'All'
                  ? 'There are no posts available at the moment.'
                  : 'There are no posts in the "${widget.selectedCategory}" category.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (widget.selectedCategory != 'All')
              ElevatedButton.icon(
                onPressed: () => widget.onCategorySelected('All'),
                icon: const Icon(Icons.refresh),
                label: const Text('View All Posts'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
