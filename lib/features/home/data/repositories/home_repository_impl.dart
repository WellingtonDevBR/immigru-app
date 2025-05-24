import 'package:dartz/dartz.dart';
import 'package:immigru/core/logging/logger_interface.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/home/data/datasources/home_data_source.dart';
import 'package:immigru/features/home/domain/entities/post.dart';
import 'package:immigru/features/home/domain/repositories/home_repository.dart';
import 'package:immigru/features/home/domain/repositories/post_repository.dart';

/// Implementation of HomeRepository
/// 
/// This implementation is kept for backward compatibility but will be deprecated in future versions.
/// All functionality has been moved to more specific repositories:
/// - PostRepository: For post-related operations
/// - CommentRepository: For comment-related operations
/// - EventRepository: For event-related operations
/// - ImmiGroveRepository: For ImmiGrove-related operations
class HomeRepositoryImpl implements HomeRepository {
  final HomeDataSource dataSource;
  final LoggerInterface logger;
  final PostRepository _postRepository;

  HomeRepositoryImpl({
    required this.dataSource,
    required this.logger,
    required PostRepository postRepository,
  }) : _postRepository = postRepository;
  
  // All methods delegate to more specific repositories
  
  @override
  Future<Either<Failure, List<Post>>> getPosts({
    String filter = 'all',
    String? category,
    String? userId,
    String? immigroveId,
    bool excludeCurrentUser = false,
    String? currentUserId,
    int limit = 20,
    int offset = 0,
  }) {
    logger.d('HomeRepositoryImpl.getPosts: Delegating to PostRepository', tag: 'HomeRepositoryImpl');
    return _postRepository.getPosts(
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
  
  @override
  Future<Either<Failure, List<Post>>> getPersonalizedPosts({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) {
    logger.d('HomeRepositoryImpl.getPersonalizedPosts: Delegating to PostRepository', tag: 'HomeRepositoryImpl');
    return _postRepository.getPersonalizedPosts(
      userId: userId,
      limit: limit,
      offset: offset,
    );
  }
  
  @override
  Future<Either<Failure, Post>> editPost({
    required String postId,
    required String userId,
    required String content,
    required String category,
  }) {
    logger.d('HomeRepositoryImpl.editPost: Delegating to PostRepository', tag: 'HomeRepositoryImpl');
    return _postRepository.editPost(
      postId: postId,
      userId: userId,
      content: content,
      category: category,
    );
  }
  
  @override
  Future<Either<Failure, bool>> deletePost({
    required String postId,
    required String userId,
  }) {
    logger.d('HomeRepositoryImpl.deletePost: Delegating to PostRepository', tag: 'HomeRepositoryImpl');
    return _postRepository.deletePost(
      postId: postId,
      userId: userId,
    );
  }
}
