import 'package:dartz/dartz.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/home/domain/repositories/comment_repository.dart';

/// Parameters for the UnlikeCommentUseCase
class UnlikeCommentParams {
  /// ID of the comment to unlike
  final String commentId;
  
  /// ID of the user unliking the comment
  final String userId;

  /// Create a new UnlikeCommentParams
  const UnlikeCommentParams({
    required this.commentId,
    required this.userId,
  });
}

/// Use case for unliking a comment
class UnlikeCommentUseCase {
  final CommentRepository repository;

  /// Create a new UnlikeCommentUseCase
  const UnlikeCommentUseCase(this.repository);

  /// Execute the use case
  Future<Either<Failure, bool>> call(UnlikeCommentParams params) {
    return repository.unlikeComment(
      commentId: params.commentId,
      userId: params.userId,
    );
  }
}
