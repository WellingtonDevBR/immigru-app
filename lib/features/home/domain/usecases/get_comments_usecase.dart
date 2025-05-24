import 'package:dartz/dartz.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/home/domain/entities/post_comment.dart';
import 'package:immigru/features/home/domain/repositories/comment_repository.dart';

/// Use case for getting comments for a post
class GetCommentsUseCase {
  final CommentRepository repository;

  GetCommentsUseCase(this.repository);

  /// Get comments for a post
  /// 
  /// [postId] - ID of the post to get comments for
  /// [limit] - Maximum number of comments to return
  /// [offset] - Pagination offset
  Future<Either<Failure, List<PostComment>>> call({
    required String postId,
    int limit = 20,
    int offset = 0,
  }) {
    return repository.getComments(
      postId: postId,
      limit: limit,
      offset: offset,
    );
  }
}
