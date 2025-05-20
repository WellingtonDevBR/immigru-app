import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/home/domain/entities/post.dart';
import 'package:immigru/features/home/presentation/bloc/home_bloc.dart';
import 'package:immigru/features/home/presentation/bloc/home_event.dart';
import 'package:immigru/features/home/presentation/bloc/home_state.dart';
import 'package:immigru/features/home/presentation/widgets/post_card.dart';
import 'package:immigru/shared/theme/app_colors.dart';
import 'package:immigru/shared/widgets/error_message_widget.dart';
import 'package:immigru/shared/widgets/loading_indicator.dart';

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
  
  // Available post categories
  final List<String> _categories = [
    'All',
    'Immigration News',
    'Legal Advice',
    'Community',
    'Question',
    'Experience',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        // Handle different states
        if (state is PostsLoading) {
          return _buildLoadingState(state);
        } else if (state is PostsLoaded) {
          return _buildLoadedState(state);
        } else if (state is PostsError) {
          return ErrorMessageWidget(
            message: state.message,
            onRetry: () {
              BlocProvider.of<HomeBloc>(context).add(
                FetchPosts(category: widget.selectedCategory, refresh: true),
              );
            },
          );
        } else if (state is PostCreated) {
          // After post creation, refresh the feed
          WidgetsBinding.instance.addPostFrameCallback((_) {
            BlocProvider.of<HomeBloc>(context).add(
              FetchPosts(category: widget.selectedCategory, refresh: true),
            );
          });
          return _buildLoadingState(null);
        }

        // Initial state or other states
        return _buildLoadingState(null);
      },
    );
  }

  /// Build the loading state
  Widget _buildLoadingState(PostsLoading? state) {
    if (state != null && state.currentPosts != null && state.currentPosts!.isNotEmpty) {
      // Show current posts with loading indicator at bottom
      return Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: _buildPostsList(
              state.currentPosts!,
              showBottomLoader: true,
              hasReachedMax: false,
            ),
          ),
        ],
      );
    }

    // Show full loading indicator
    return Column(
      children: [
        _buildCategoryFilter(),
        const Expanded(
          child: Center(
            child: LoadingIndicator(),
          ),
        ),
      ],
    );
  }

  /// Build the loaded state with posts
  Widget _buildLoadedState(PostsLoaded state) {
    return Column(
      children: [
        _buildCategoryFilter(),
        Expanded(
          child: state.posts.isEmpty
              ? _buildEmptyState()
              : _buildPostsList(
                  state.posts,
                  showBottomLoader: !state.hasReachedMax,
                  hasReachedMax: state.hasReachedMax,
                ),
        ),
      ],
    );
  }

  /// Build the category filter
  Widget _buildCategoryFilter() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == widget.selectedCategory;
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  widget.onCategorySelected(category);
                }
              },
              backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
              selectedColor: theme.colorScheme.primary.withValues(alpha:0.2),
              checkmarkColor: theme.colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected
                    ? theme.colorScheme.primary
                    : isDarkMode
                        ? Colors.white
                        : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: isSelected
                    ? BorderSide(color: theme.colorScheme.primary, width: 1)
                    : BorderSide.none,
              ),
            ),
          );
        },
      ),
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
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: posts.length + (showBottomLoader ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= posts.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: LoadingIndicator(size: 24),
              ),
            );
          }

          final post = posts[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: PostCard(
              post: post,
              onLike: () {
                // Handle like action
              },
              onComment: () {
                // Navigate to comments screen
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
                    ? Colors.grey.shade800.withValues(alpha:0.5)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 60,
                color: theme.colorScheme.primary.withValues(alpha:0.7),
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
