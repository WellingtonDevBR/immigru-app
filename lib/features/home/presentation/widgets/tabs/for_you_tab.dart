import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/auth/domain/entities/user.dart';
import 'package:immigru/features/home/domain/entities/post.dart';
import 'package:immigru/features/home/presentation/bloc/home_bloc.dart';
import 'package:immigru/features/home/presentation/bloc/home_event.dart';
import 'package:immigru/features/home/presentation/bloc/home_state.dart';
import 'package:immigru/features/home/presentation/widgets/post_card.dart';
import 'package:immigru/shared/widgets/error_message_widget.dart';
import 'package:immigru/shared/widgets/loading_indicator.dart';

/// "For You" tab showing personalized content
class ForYouTab extends StatefulWidget {
  final User? user;
  final VoidCallback onCreatePost;

  const ForYouTab({
    super.key,
    this.user,
    required this.onCreatePost,
  });

  @override
  State<ForYouTab> createState() => _ForYouTabState();
}

class _ForYouTabState extends State<ForYouTab> {
  final ScrollController _scrollController = ScrollController();

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

      if (currentState is PersonalizedPostsLoaded && !currentState.hasReachedMax) {
        if (widget.user != null) {
          homeBloc.add(FetchMorePersonalizedPosts(userId: widget.user!.id));
        }
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
        // If user is not logged in, show welcome screen
        if (widget.user == null) {
          return _buildWelcomeScreen(context);
        }

        // Handle different states
        if (state is PersonalizedPostsLoading) {
          return _buildLoadingState(state);
        } else if (state is PersonalizedPostsLoaded) {
          return _buildLoadedState(state);
        } else if (state is PersonalizedPostsError) {
          return ErrorMessageWidget(
            message: state.message,
            onRetry: () {
              if (widget.user != null) {
                BlocProvider.of<HomeBloc>(context).add(
                  FetchPersonalizedPosts(userId: widget.user!.id, refresh: true),
                );
              }
            },
          );
        } else if (state is PostCreated) {
          // After post creation, refresh the feed
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (widget.user != null) {
              BlocProvider.of<HomeBloc>(context).add(
                FetchPersonalizedPosts(userId: widget.user!.id, refresh: true),
              );
            }
          });
          return _buildLoadingState(null);
        }

        // Initial state or other states
        return _buildLoadingState(null);
      },
    );
  }

  /// Build the loading state
  Widget _buildLoadingState(PersonalizedPostsLoading? state) {
    if (state != null && state.currentPosts != null && state.currentPosts!.isNotEmpty) {
      // Show current posts with loading indicator at bottom
      return _buildPostsList(
        state.currentPosts!,
        showBottomLoader: true,
        hasReachedMax: false,
      );
    }

    // Show full loading indicator
    return const Center(
      child: LoadingIndicator(),
    );
  }

  /// Build the loaded state with posts
  Widget _buildLoadedState(PersonalizedPostsLoaded state) {
    if (state.posts.isEmpty) {
      return _buildEmptyState();
    }

    return _buildPostsList(
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
        if (widget.user != null) {
          BlocProvider.of<HomeBloc>(context).add(
            FetchPersonalizedPosts(userId: widget.user!.id, refresh: true),
          );
        }
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
                if (widget.user != null) {
                  BlocProvider.of<HomeBloc>(context).add(
                    LikePost(
                      postId: post.id,
                      userId: widget.user!.id,
                      like: !post.isLiked,
                    ),
                  );
                }
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
                Icons.feed_outlined,
                size: 60,
                color: theme.colorScheme.primary.withValues(alpha:0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Posts Yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Be the first to share something with the community!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: widget.onCreatePost,
              icon: const Icon(Icons.add),
              label: const Text('Create Post'),
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

  /// Build the welcome screen for non-logged in users
  Widget _buildWelcomeScreen(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
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
                Icons.person_outline,
                size: 60,
                color: theme.colorScheme.primary.withValues(alpha:0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to Immigru',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Sign in to see personalized content, join communities, and connect with others on similar immigration journeys.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to login screen
              },
              icon: const Icon(Icons.login),
              label: const Text('Sign In'),
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
