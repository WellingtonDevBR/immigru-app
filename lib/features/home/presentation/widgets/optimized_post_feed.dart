import 'package:flutter/material.dart';
import 'package:immigru/core/cache/image_cache_service.dart';
import 'package:immigru/features/home/domain/entities/post.dart';
import 'package:immigru/features/home/presentation/widgets/post_card.dart';
import 'package:immigru/shared/widgets/skeleton_loaders.dart';
import 'package:immigru/shared/widgets/virtualized_list.dart';

/// An optimized post feed that uses virtualization and skeleton loading
/// for improved performance
class OptimizedPostFeed extends StatefulWidget {
  /// The list of posts to display
  final List<Post> posts;
  
  /// Whether more posts are being loaded
  final bool isLoadingMore;
  
  /// Whether this is the initial loading state
  final bool isInitialLoading;
  
  /// Callback when the end of the list is reached
  final VoidCallback? onEndReached;
  
  /// Callback when a post is liked
  final VoidCallback? onLikePost;
  
  /// Callback when a post is deleted
  final VoidCallback? onDeletePost;
  
  /// Callback when a post is edited
  final Function(String)? onEditPost;
  
  /// Callback when a post is commented on
  final VoidCallback? onCommentPost;
  
  /// Callback when pull-to-refresh is triggered
  final VoidCallback? onRefresh;
  
  /// Filter to apply to the posts
  final String filter;
  
  /// Category to filter by
  final String? category;
  
  const OptimizedPostFeed({
    super.key,
    required this.posts,
    this.isLoadingMore = false,
    this.isInitialLoading = false,
    this.onEndReached,
    this.onLikePost,
    this.onDeletePost,
    this.onEditPost,
    this.onCommentPost,
    this.onRefresh,
    this.filter = 'all',
    this.category,
  });

  @override
  State<OptimizedPostFeed> createState() => _OptimizedPostFeedState();
}

class _OptimizedPostFeedState extends State<OptimizedPostFeed> {
  final ScrollController _scrollController = ScrollController();
  final ImageCacheService _imageCacheService = ImageCacheService();
  
  @override
  void initState() {
    super.initState();
    // Prefetch images for visible posts
    _prefetchVisiblePostImages();
  }
  
  @override
  void didUpdateWidget(OptimizedPostFeed oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Prefetch images when posts change
    if (widget.posts != oldWidget.posts) {
      _prefetchVisiblePostImages();
    }
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  // Prefetch images for the first few posts that will be visible
  void _prefetchVisiblePostImages() {
    if (widget.posts.isEmpty) return;
    
    // Only prefetch the first 5 posts to avoid excessive network usage
    final visiblePosts = widget.posts.take(5).toList();
    final imagesToPrefetch = <String>[];
    
    for (final post in visiblePosts) {
      if (post.imageUrl != null && post.imageUrl!.isNotEmpty) {
        imagesToPrefetch.add(post.imageUrl!);
      }
      
      if (post.author?.avatarUrl != null && post.author!.avatarUrl!.isNotEmpty) {
        imagesToPrefetch.add(post.author!.avatarUrl!);
      }
    }
    
    if (imagesToPrefetch.isNotEmpty) {
      _imageCacheService.prefetchImages(imagesToPrefetch);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Show skeleton loaders during initial loading
    if (widget.isInitialLoading) {
      return SkeletonLoaders.postsList(context);
    }
    
    // Show empty state if no posts
    if (widget.posts.isEmpty) {
      return _buildEmptyState();
    }
    
    // Use RefreshIndicator for pull-to-refresh functionality
    return RefreshIndicator(
      onRefresh: () async {
        if (widget.onRefresh != null) {
          widget.onRefresh!();
        }
      },
      child: VirtualizedList<Post>(
        items: widget.posts,
        scrollController: _scrollController,
        estimatedItemHeight: 400, // Estimated average height of a post card
        preloadItemCount: 2, // Preload 2 items outside the viewport
        onEndReached: widget.onEndReached,
        isLoading: widget.isLoadingMore,
        padding: const EdgeInsets.only(bottom: 16.0),
        physics: const AlwaysScrollableScrollPhysics(),
        placeholderBuilder: (context, index) {
          return SkeletonLoaders.postCard(context);
        },
        itemBuilder: (context, post, index) {
          return PostCard(
            post: post,
            onLike: widget.onLikePost ?? () {},
            onComment: widget.onCommentPost ?? () {},
            onDelete: widget.onDeletePost,
            onEdit: widget.onEditPost,
          );
        },
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.post_add,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            _getEmptyStateMessage(),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: widget.onRefresh,
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
  
  String _getEmptyStateMessage() {
    if (widget.filter == 'user') {
      return 'You haven\'t created any posts yet.\nShare your journey with the community!';
    } else if (widget.filter == 'liked') {
      return 'You haven\'t liked any posts yet.\nExplore the community to find posts you like!';
    } else if (widget.category != null) {
      return 'No posts found in the ${widget.category} category.\nBe the first to post!';
    } else {
      return 'No posts found.\nCheck back later or be the first to post!';
    }
  }
}
