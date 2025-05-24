import 'package:dartz/dartz.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/home/domain/repositories/comment_repository.dart';

/// Use case for deleting a comment
class DeleteCommentUseCase {
  final CommentRepository repository;

  /// Create a new DeleteCommentUseCase
  DeleteCommentUseCase({required this.repository});

  /// Execute the use case to delete a comment
  /// 
  /// [commentId] - ID of the comment to delete
  /// [postId] - ID of the post the comment belongs to
  /// [userId] - ID of the user deleting the comment (must be the author)
  Future<Either<Failure, bool>> execute({
    required String commentId,
    required String postId,
    required String userId,
  }) async {
    return repository.deleteComment(
      commentId: commentId,
      postId: postId,
      userId: userId,
    );
  }
}
