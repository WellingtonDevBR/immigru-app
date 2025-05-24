import 'package:dartz/dartz.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/home/domain/repositories/post_repository.dart';

/// Parameters for liking a post
class LikePostParams {
  /// ID of the post to like/unlike
  final String postId;
  
  /// ID of the user liking/unliking the post
  final String userId;
  
  /// Whether to like (true) or unlike (false) the post
  final bool like;

  /// Create a new LikePostParams
  const LikePostParams({
    required this.postId,
    required this.userId,
    required this.like,
  });
}

/// Use case for liking or unliking a post
class LikePostUseCase {
  final PostRepository repository;

  /// Create a new LikePostUseCase
  const LikePostUseCase(this.repository);

  /// Execute the use case
  Future<Either<Failure, bool>> call(LikePostParams params) {
    return repository.likePost(
      postId: params.postId,
      userId: params.userId,
      like: params.like,
    );
  }
}
