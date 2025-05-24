import 'package:dartz/dartz.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/home/domain/repositories/comment_repository.dart';

/// Parameters for the LikeCommentUseCase
class LikeCommentParams {
  /// ID of the comment to like
  final String commentId;
  
  /// ID of the user liking the comment
  final String userId;

  /// Create a new LikeCommentParams
  const LikeCommentParams({
    required this.commentId,
    required this.userId,
  });
}

/// Use case for liking a comment
class LikeCommentUseCase {
  final CommentRepository repository;

  /// Create a new LikeCommentUseCase
  const LikeCommentUseCase(this.repository);

  /// Execute the use case
  Future<Either<Failure, bool>> call(LikeCommentParams params) {
    return repository.likeComment(
      commentId: params.commentId,
      userId: params.userId,
    );
  }
}
