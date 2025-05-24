import 'package:dartz/dartz.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/home/domain/repositories/post_repository.dart';

/// Use case for deleting a post (soft delete by setting DeletedAt)
class DeletePostUseCase {
  final PostRepository repository;

  DeletePostUseCase({required this.repository});

  /// Delete a post
  ///
  /// [postId] - ID of the post to delete
  /// [userId] - ID of the user deleting the post (must be the author)
  Future<Either<Failure, bool>> call({
    required String postId,
    required String userId,
  }) async {
    return await repository.deletePost(
      postId: postId,
      userId: userId,
    );
  }
}
