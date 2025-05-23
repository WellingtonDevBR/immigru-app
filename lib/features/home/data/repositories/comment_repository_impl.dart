import 'package:dartz/dartz.dart';
import 'package:immigru/core/logging/logger_interface.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/home/data/datasources/comment_data_source_impl.dart';
import 'package:immigru/features/home/domain/entities/post_comment.dart';
import 'package:immigru/features/home/domain/repositories/comment_repository.dart';

/// Implementation of CommentRepository
class CommentRepositoryImpl implements CommentRepository {
  final CommentDataSource dataSource;
  final LoggerInterface logger;

  /// Create a new CommentRepositoryImpl
  CommentRepositoryImpl({
    required this.dataSource,
    required this.logger,
  });

  @override
  Future<Either<Failure, List<PostComment>>> getComments({
    required String postId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final comments = await dataSource.getComments(
        postId: postId,
        limit: limit,
        offset: offset,
      );
      return Right(comments);
    } catch (e) {
      logger.e('Failed to get comments: $e', tag: 'CommentRepository');
      return Left(Failure(message: 'Failed to get comments'));
    }
  }

  @override
  Future<Either<Failure, PostComment>> createComment({
    required String postId,
    required String userId,
    required String content,
    String? parentCommentId,
    String? rootCommentId,
    int depth = 1,
  }) async {
    try {
      final comment = await dataSource.createComment(
        postId: postId,
        userId: userId,
        content: content,
        parentCommentId: parentCommentId,
        rootCommentId: rootCommentId,
        depth: depth,
      );
      return Right(comment);
    } catch (e) {
      logger.e('Failed to create comment: $e', tag: 'CommentRepository');
      return Left(Failure(message: 'Failed to create comment'));
    }
  }

  @override
  Future<Either<Failure, PostComment>> editComment({
    required String commentId,
    required String postId,
    required String userId,
    required String content,
  }) async {
    try {
      final comment = await dataSource.editComment(
        commentId: commentId,
        postId: postId,
        userId: userId,
        content: content,
      );
      return Right(comment);
    } catch (e) {
      logger.e('Failed to edit comment: $e', tag: 'CommentRepository');
      return Left(Failure(message: 'Failed to edit comment'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteComment({
    required String commentId,
    required String postId,
    required String userId,
  }) async {
    try {
      final result = await dataSource.deleteComment(
        commentId: commentId,
        postId: postId,
        userId: userId,
      );
      return Right(result);
    } catch (e) {
      logger.e('Failed to delete comment: $e', tag: 'CommentRepository');
      return Left(Failure(message: 'Failed to delete comment'));
    }
  }
  
  @override
  Future<Either<Failure, bool>> likeComment({
    required String commentId,
    required String userId,
  }) async {
    try {
      await dataSource.likeComment(
        commentId: commentId,
        userId: userId,
      );
      return const Right(true);
    } catch (e) {
      logger.e('Failed to like comment: $e', tag: 'CommentRepository');
      return Left(Failure(message: 'Failed to like comment'));
    }
  }
  
  @override
  Future<Either<Failure, bool>> unlikeComment({
    required String commentId,
    required String userId,
  }) async {
    try {
      await dataSource.unlikeComment(
        commentId: commentId,
        userId: userId,
      );
      return const Right(true);
    } catch (e) {
      logger.e('Failed to unlike comment: $e', tag: 'CommentRepository');
      return Left(Failure(message: 'Failed to unlike comment'));
    }
  }
  
  @override
  Future<Either<Failure, int>> getCommentLikeCount({
    required String commentId,
  }) async {
    try {
      final count = await dataSource.getCommentLikeCount(
        commentId: commentId,
      );
      return Right(count);
    } catch (e) {
      logger.e('Failed to get comment like count: $e', tag: 'CommentRepository');
      return const Right(0); // Return 0 on error instead of failure
    }
  }
  
  @override
  Future<Either<Failure, bool>> hasUserLikedComment({
    required String commentId,
    required String userId,
  }) async {
    try {
      final hasLiked = await dataSource.hasUserLikedComment(
        commentId: commentId,
        userId: userId,
      );
      return Right(hasLiked);
    } catch (e) {
      logger.e('Failed to check if user has liked comment: $e', tag: 'CommentRepository');
      return const Right(false); // Return false on error instead of failure
    }
  }
}
