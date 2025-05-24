import 'package:dartz/dartz.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/home/domain/entities/post_comment.dart';

/// Repository for comment-related operations
abstract class CommentRepository {
  /// Get comments for a post
  ///
  /// [postId] - ID of the post to get comments for
  /// [limit] - Maximum number of comments to return
  /// [offset] - Pagination offset
  Future<Either<Failure, List<PostComment>>> getComments({
    required String postId,
    int limit = 20,
    int offset = 0,
  });

  /// Create a new comment on a post
  ///
  /// [postId] - ID of the post to comment on
  /// [userId] - ID of the user creating the comment
  /// [content] - Content of the comment
  /// [parentCommentId] - Optional ID of the parent comment (for replies)
  /// [rootCommentId] - Optional ID of the root comment in the thread (for nested replies)
  /// [depth] - Depth level of the comment (1 = direct post comment, 2 = reply to comment, 3 = reply to reply)
  Future<Either<Failure, PostComment>> createComment({
    required String postId,
    required String userId,
    required String content,
    String? parentCommentId,
    String? rootCommentId,
    int depth = 1,
  });

  /// Edit an existing comment
  ///
  /// [commentId] - ID of the comment to edit
  /// [postId] - ID of the post the comment belongs to
  /// [userId] - ID of the user editing the comment (must be the author)
  /// [content] - New content for the comment
  Future<Either<Failure, PostComment>> editComment({
    required String commentId,
    required String postId,
    required String userId,
    required String content,
  });

  /// Delete a comment
  ///
  /// [commentId] - ID of the comment to delete
  /// [postId] - ID of the post the comment belongs to
  /// [userId] - ID of the user deleting the comment (must be the author)
  Future<Either<Failure, bool>> deleteComment({
    required String commentId,
    required String postId,
    required String userId,
  });
}
