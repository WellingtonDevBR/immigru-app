import 'package:dartz/dartz.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/home/domain/entities/post_comment.dart';
import 'package:immigru/features/home/domain/repositories/comment_repository.dart';

/// Use case for editing an existing comment
class EditCommentUseCase {
  final CommentRepository repository;

  /// Create a new EditCommentUseCase
  EditCommentUseCase({required this.repository});

  /// Execute the use case to edit a comment
  /// 
  /// [commentId] - ID of the comment to edit
  /// [postId] - ID of the post the comment belongs to
  /// [userId] - ID of the user editing the comment (must be the author)
  /// [content] - New content for the comment
  Future<Either<Failure, PostComment>> execute({
    required String commentId,
    required String postId,
    required String userId,
    required String content,
  }) async {
    return repository.editComment(
      commentId: commentId,
      postId: postId,
      userId: userId,
      content: content,
    );
  }
}
