import 'package:dartz/dartz.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/home/domain/entities/post_comment.dart';
import 'package:immigru/features/home/domain/repositories/home_repository.dart';

/// Use case for creating a comment on a post
class CreateCommentUseCase {
  final HomeRepository repository;

  /// Create a new CreateCommentUseCase
  CreateCommentUseCase({required this.repository});

  /// Execute the use case to create a comment
  /// 
  /// [postId] - ID of the post to comment on
  /// [userId] - ID of the user creating the comment
  /// [content] - Content of the comment
  /// [parentCommentId] - Optional ID of the parent comment (for replies)
  Future<Either<Failure, PostComment>> execute({
    required String postId,
    required String userId,
    required String content,
    String? parentCommentId,
  }) async {
    return repository.createComment(
      postId: postId,
      userId: userId,
      content: content,
      parentCommentId: parentCommentId,
    );
  }
}
