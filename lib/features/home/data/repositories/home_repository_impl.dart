import 'package:dartz/dartz.dart';
import 'package:immigru/features/home/data/datasources/home_data_source.dart';
import 'package:immigru/features/home/domain/entities/event.dart';
import 'package:immigru/features/home/domain/entities/immi_grove.dart';
import 'package:immigru/features/home/domain/entities/post.dart';
import 'package:immigru/features/home/domain/entities/post_comment.dart';
import 'package:immigru/features/home/domain/repositories/home_repository.dart';
import 'package:immigru/core/logging/logger_interface.dart';
import 'package:immigru/core/network/models/failure.dart';

/// Implementation of HomeRepository
class HomeRepositoryImpl implements HomeRepository {
  final HomeDataSource dataSource;
  final LoggerInterface logger;

  HomeRepositoryImpl({
    required this.dataSource,
    required this.logger,
  });

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
  }) async {
    try {
      final posts = await dataSource.getPosts(
        filter: filter,
        category: category,
        userId: userId,
        immigroveId: immigroveId,
        excludeCurrentUser: excludeCurrentUser,
        currentUserId: currentUserId,
        limit: limit,
        offset: offset,
      );
      return Right(posts);
    } catch (e) {
      logger.e('Failed to get posts: $e', tag: 'HomeRepository');
      return Left(Failure(message: 'Failed to get posts'));
    }
  }

  @override
  Future<Either<Failure, List<Post>>> getPersonalizedPosts({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final posts = await dataSource.getPersonalizedPosts(
        userId: userId,
        limit: limit,
        offset: offset,
      );
      return Right(posts);
    } catch (e) {
      logger.e('Failed to get personalized posts: $e', tag: 'HomeRepository');
      return Left(Failure(message: 'Failed to get personalized posts'));
    }
  }

  @override
  Future<Either<Failure, List<Event>>> getEvents({
    bool upcoming = true,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final events = await dataSource.getEvents(
        upcoming: upcoming,
        limit: limit,
        offset: offset,
      );
      return Right(events);
    } catch (e) {
      logger.e('Failed to get events: $e', tag: 'HomeRepository');
      return Left(Failure(message: 'Failed to get events'));
    }
  }

  @override
  Future<Either<Failure, Post>> createPost({
    required String content,
    required String userId,
    required String category,
    String? imageUrl,
  }) async {
    try {
      final post = await dataSource.createPost(
        content: content,
        userId: userId,
        category: category,
        imageUrl: imageUrl,
      );
      return Right(post);
    } catch (e) {
      logger.e('Failed to create post: $e', tag: 'HomeRepository');
      return Left(Failure(message: 'Failed to create post'));
    }
  }

  @override
  Future<Either<Failure, bool>> likePost({
    required String postId,
    required String userId,
    required bool like,
  }) async {
    try {
      final result = await dataSource.likePost(
        postId: postId,
        userId: userId,
        like: like,
      );
      return Right(result);
    } catch (e) {
      logger.e('Failed to like post: $e', tag: 'HomeRepository');
      return Left(Failure(message: 'Failed to like post'));
    }
  }

  @override
  Future<Either<Failure, bool>> registerForEvent({
    required String eventId,
    required String userId,
  }) async {
    try {
      await dataSource.registerForEvent(
        eventId: eventId,
        userId: userId,
      );
      return const Right(true);
    } catch (e) {
      logger.e('Failed to register for event: $e', tag: 'HomeRepository');
      return Left(Failure(message: 'Failed to register for event'));
    }
  }

  @override
  Future<Either<Failure, List<PostComment>>> getComments({
    required String postId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final comments = await dataSource.getComments(
        postId: postId,
        limit: limit,
        offset: offset,
      );
      return Right(comments);
    } catch (e) {
      logger.e('Failed to get comments: $e', tag: 'HomeRepository');
      return Left(Failure(message: 'Failed to get comments'));
    }
  }

  @override
  Future<Either<Failure, PostComment>> createComment({
    required String postId,
    required String userId,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      final comment = await dataSource.createComment(
        postId: postId,
        userId: userId,
        content: content,
        parentCommentId: parentCommentId,
      );
      return Right(comment);
    } catch (e) {
      logger.e('Failed to create comment: $e', tag: 'HomeRepository');
      return Left(Failure(message: 'Failed to create comment'));
    }
  }

  @override
  Future<Either<Failure, List<ImmiGrove>>> getImmiGroves({
    String? query,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final immiGroves = await dataSource.getImmiGroves(
        query: query,
        limit: limit,
        offset: offset,
      );
      return Right(immiGroves);
    } catch (e) {
      logger.e('Failed to get ImmiGroves: $e', tag: 'HomeRepository');
      return Left(Failure(message: 'Failed to get ImmiGroves'));
    }
  }

  @override
  Future<Either<Failure, List<ImmiGrove>>> getRecommendedImmiGroves({
    int limit = 5,
  }) async {
    try {
      final immiGroves = await dataSource.getRecommendedImmiGroves(
        limit: limit,
      );
      return Right(immiGroves);
    } catch (e) {
      logger.e('Failed to get recommended ImmiGroves: $e',
          tag: 'HomeRepository');
      return Left(Failure(message: 'Failed to get recommended ImmiGroves'));
    }
  }

  @override
  Future<Either<Failure, bool>> joinImmiGrove({
    required String immiGroveId,
    required String userId,
    required bool join,
  }) async {
    try {
      final result = await dataSource.joinImmiGrove(
        immiGroveId: immiGroveId,
        userId: userId,
        join: join,
      );
      return Right(result);
    } catch (e) {
      final action = join ? 'join' : 'leave';
      logger.e('Failed to $action ImmiGrove: $e', tag: 'HomeRepository');
      return Left(Failure(message: 'Failed to $action ImmiGrove'));
    }
  }
}
