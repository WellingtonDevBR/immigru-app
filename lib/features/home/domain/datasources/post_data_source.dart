import 'package:immigru/features/home/domain/entities/post_media.dart';
import 'package:immigru/features/home/domain/entities/post.dart';

/// Interface for post data source operations
abstract class PostDataSource {
  /// Get posts for the home feed
  ///
  /// [filter] - Filter type: 'all', 'user', 'following', 'my-immigroves'
  /// [category] - Optional category filter
  /// [userId] - Optional user ID to filter posts by
  /// [immigroveId] - Optional ImmiGrove ID to filter posts by
  /// [excludeCurrentUser] - Whether to exclude the current user's posts
  /// [currentUserId] - ID of the current user (needed for some filters)
  /// [limit] - Maximum number of posts to return
  /// [offset] - Pagination offset
  Future<List<dynamic>> getPosts({
    String filter = 'all',
    String? category,
    String? userId,
    String? immigroveId,
    bool excludeCurrentUser = false,
    String? currentUserId,
    int limit = 20,
    int offset = 0,
  });

  /// Get personalized posts for the user
  Future<List<dynamic>> getPersonalizedPosts({
    required String userId,
    int limit = 20,
    int offset = 0,
  });

  /// Create a new post
  Future<Map<String, dynamic>> createPost({
    required String content,
    required String userId,
    required String type,
    List<PostMedia>? media,
    String? imageUrl,
  });

  /// Edit an existing post
  /// Only the post author can edit their own posts
  Future<dynamic> editPost({
    required String postId,
    required String userId,
    required String content,
    required String category,
  });

  /// Delete a post (soft delete by setting DeletedAt)
  /// Only the post author can delete their own posts
  Future<bool> deletePost({
    required String postId,
    required String userId,
  });

  /// Like or unlike a post
  Future<bool> likePost({
    required String postId,
    required String userId,
    required bool like,
  });
  
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
  });
  
  /// Invalidate any cached data for a specific post
  Future<void> invalidatePostCache(String postId);
  
  /// Update like and comment counts for a list of posts
  /// Returns the updated posts
  Future<List<Post>> updatePostCounts({
    required List<Post> posts,
    required String currentUserId,
  });
}
