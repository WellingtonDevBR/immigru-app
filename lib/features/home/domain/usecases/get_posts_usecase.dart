import 'package:dartz/dartz.dart';
import 'package:immigru/features/home/domain/entities/post.dart';
import 'package:immigru/features/home/domain/repositories/home_repository.dart';
import 'package:immigru/core/network/models/failure.dart';

/// Use case for getting posts for the home feed
class GetPostsUseCase {
  final HomeRepository repository;

  GetPostsUseCase(this.repository);

  /// Execute the use case
  ///
  /// [filter] - Filter type: 'all', 'user', 'following', 'my-immigroves'
  /// [category] - Optional category filter
  /// [userId] - Optional user ID to filter posts by
  /// [immigroveId] - Optional ImmiGrove ID to filter posts by
  /// [excludeCurrentUser] - Whether to exclude the current user's posts
  /// [currentUserId] - ID of the current user (needed for some filters)
  /// [limit] - Maximum number of posts to return
  /// [offset] - Pagination offset
  Future<Either<Failure, List<Post>>> call({
    String filter = 'all',
    String? category,
    String? userId,
    String? immigroveId,
    bool excludeCurrentUser = false,
    String? currentUserId,
    int limit = 20,
    int offset = 0,
  }) {
    return repository.getPosts(
      filter: filter,
      category: category,
      userId: userId,
      immigroveId: immigroveId,
      excludeCurrentUser: excludeCurrentUser,
      currentUserId: currentUserId,
      limit: limit,
      offset: offset,
    );
  }
}
