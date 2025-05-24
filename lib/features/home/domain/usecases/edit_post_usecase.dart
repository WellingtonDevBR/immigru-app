import 'package:dartz/dartz.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/home/domain/entities/post.dart';
import 'package:immigru/features/home/domain/repositories/post_repository.dart';

/// Use case for editing a post
class EditPostUseCase {
  final PostRepository repository;

  EditPostUseCase({required this.repository});

  /// Edit a post
  ///
  /// [postId] - ID of the post to edit
  /// [userId] - ID of the user editing the post (must be the author)
  /// [content] - New post content
  /// [category] - Post category (can be the same as before)
  Future<Either<Failure, Post>> call({
    required String postId,
    required String userId,
    required String content,
    required String category,
  }) async {
    return await repository.editPost(
      postId: postId,
      userId: userId,
      content: content,
      category: category,
    );
  }
}
