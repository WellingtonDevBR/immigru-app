import 'package:dartz/dartz.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/home/domain/entities/post.dart';
import 'package:immigru/features/home/domain/entities/post_media.dart';

/// Repository interface for post-related operations
abstract class PostRepository {
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
  Future<Either<Failure, List<Post>>> getPosts({
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
  Future<Either<Failure, List<Post>>> getPersonalizedPosts({
    required String userId,
    int limit = 20,
    int offset = 0,
  });

  /// Create a new post
  /// 
  /// Returns a [Post] entity on success or a [Failure] on error
  Future<Either<Failure, Post>> createPost({
    required String userId,
    required String content,
    required String category,
    List<PostMedia>? media,
  });

  /// Edit an existing post
  /// Only the post author can edit their own posts
  Future<Either<Failure, Post>> editPost({
    required String postId,
    required String userId,
    required String content,
    required String category,
  });

  /// Delete a post (soft delete by setting DeletedAt)
  /// Only the post author can delete their own posts
  Future<Either<Failure, bool>> deletePost({
    required String postId,
    required String userId,
  });

  /// Like or unlike a post
  Future<Either<Failure, bool>> likePost({
    required String postId,
    required String userId,
    required bool like,
  });
}
