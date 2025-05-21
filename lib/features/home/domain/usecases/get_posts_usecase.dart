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
  /// [category] - Optional category filter
  /// [limit] - Maximum number of posts to return
  /// [offset] - Pagination offset
  Future<Either<Failure, List<Post>>> call({
    String? category,
    int limit = 20,
    int offset = 0,
  }) {
    return repository.getPosts(
      category: category,
      limit: limit,
      offset: offset,
    );
  }
}
