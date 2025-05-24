import 'package:dartz/dartz.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/home/domain/entities/post.dart';
import 'package:immigru/features/home/domain/repositories/post_repository.dart';

/// Use case for getting personalized posts for the user
class GetPersonalizedPostsUseCase {
  final PostRepository repository;

  GetPersonalizedPostsUseCase(this.repository);

  /// Execute the use case
  /// 
  /// [userId] - ID of the current user
  /// [limit] - Maximum number of posts to return
  /// [offset] - Pagination offset
  Future<Either<Failure, List<Post>>> call({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) {
    return repository.getPersonalizedPosts(
      userId: userId,
      limit: limit,
      offset: offset,
    );
  }
}
