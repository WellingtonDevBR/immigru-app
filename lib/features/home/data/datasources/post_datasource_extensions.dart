import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/features/home/domain/entities/post.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'post_datasource.dart';

/// Extension methods for PostDataSource to handle efficient refreshing
extension PostDataSourceRefreshExtensions on PostDataSource {
  // Use a getter instead of a field for the logger
  UnifiedLogger get _logger => UnifiedLogger();

  /// Check for new posts since a given timestamp
  /// Returns the count of new posts
  Future<int> checkForNewPosts({
    required DateTime since,
    String filter = 'all',
    String? category,
    String? userId,
    String? immigroveId,
    bool excludeCurrentUser = false,
    String? currentUserId,
  }) async {
    try {
      _logger.d('Checking for new posts since ${since.toIso8601String()}', tag: 'PostDataSource');
      
      // Build query to count posts newer than the given timestamp
      var query = Supabase.instance.client
          .from('Post')
          .select('count')
          .filter('CreatedAt', 'gt', since.toIso8601String())
          .filter('DeletedAt', 'is', null);
      
      // Apply filters based on parameters (same logic as getPosts)
      if (filter == 'user' && userId != null) {
        query = query.eq('UserId', userId);
      } else if (filter == 'following' && currentUserId != null) {
        // For the 'following' filter, we need to get the users that the current user is following
        // Using the UserConnection table with the correct column names
        final followingResponse = await Supabase.instance.client
            .from('UserConnection')
            .select('ReceiverId')
            .eq('SenderId', currentUserId)
            .eq('Status', 'accepted');
        
        final followingIds = (followingResponse as List)
            .map((item) => item['ReceiverId'] as String)
            .toList();
        
        if (followingIds.isEmpty) {
          return 0; // No following users, so no posts
        }
        
        // Use 'in' operator correctly for Supabase query
        query = query.filter('UserId', 'in', followingIds);
      } else if (filter == 'immigrove' && immigroveId != null) {
        query = query.eq('ImmigroveId', immigroveId);
      }
      
      // Apply category filter if provided
      if (category != null && category.isNotEmpty) {
        query = query.eq('Category', category);
      }
      
      // Apply user filter if requested
      if (excludeCurrentUser && currentUserId != null) {
        query = query.neq('UserId', currentUserId);
      }
      
      // Execute the count query
      final response = await query.count();
      final newPostsCount = response.count;
      
      _logger.d('Found $newPostsCount new posts since ${since.toIso8601String()}', 
          tag: 'PostDataSource');
      
      return newPostsCount;
    } catch (e) {
      _logger.e('Error checking for new posts: $e', tag: 'PostDataSource');
      return 0; // Return 0 on error to avoid false positives
    }
  }
  
  /// Update like and comment counts for a list of posts
  /// Returns the updated posts
  Future<List<Post>> updatePostCounts({
    required List<Post> posts,
    required String currentUserId,
  }) async {
    try {
      _logger.d('Updating counts for ${posts.length} posts', tag: 'PostDataSource');
      
      final updatedPosts = <Post>[];
      
      // Process posts in batches to avoid overwhelming the database
      // This is more efficient than updating each post individually
      final batches = <List<Post>>[];
      for (var i = 0; i < posts.length; i += 5) {
        final end = (i + 5 < posts.length) ? i + 5 : posts.length;
        batches.add(posts.sublist(i, end));
      }
      
      for (final batch in batches) {
        final batchFutures = <Future<Post>>[];
        
        for (final post in batch) {
          batchFutures.add(_updateSinglePostCounts(post, currentUserId));
        }
        
        // Wait for all futures in this batch to complete
        final batchResults = await Future.wait(batchFutures);
        updatedPosts.addAll(batchResults);
      }
      
      _logger.d('Successfully updated counts for ${updatedPosts.length} posts', 
          tag: 'PostDataSource');
      
      return updatedPosts;
    } catch (e) {
      _logger.e('Error updating post counts: $e', tag: 'PostDataSource');
      return posts; // Return original posts on error
    }
  }
  
  /// Helper method to update counts for a single post
  Future<Post> _updateSinglePostCounts(Post post, String currentUserId) async {
    try {
      // Get like count
      final likeCountResponse = await Supabase.instance.client
          .from('PostLike')
          .select('count')
          .eq('PostId', post.id)
          .count();
      
      // Get comment count
      final commentCountResponse = await Supabase.instance.client
          .from('PostComment')
          .select('count')
          .eq('PostId', post.id)
          .count();
      
      // Check if user has liked the post
      final isLikedResponse = await Supabase.instance.client
          .from('PostLike')
          .select()
          .eq('PostId', post.id)
          .eq('UserId', currentUserId)
          .maybeSingle();
      
      // Check if user has commented on the post
      final hasCommentedResponse = await Supabase.instance.client
          .from('PostComment')
          .select()
          .eq('PostId', post.id)
          .eq('UserId', currentUserId)
          .maybeSingle();
      
      // Create updated post with new counts
      return Post(
        id: post.id,
        content: post.content,
        category: post.category,
        userId: post.userId,
        imageUrl: post.imageUrl,
        createdAt: post.createdAt,
        likeCount: likeCountResponse.count,
        commentCount: commentCountResponse.count,
        isLiked: isLikedResponse != null,
        hasUserComment: hasCommentedResponse != null,
        userName: post.userName,
        userAvatar: post.userAvatar,
      );
    } catch (e) {
      _logger.e('Error updating counts for post ${post.id}: $e', tag: 'PostDataSource');
      return post; // Return original post on error
    }
  }
}
