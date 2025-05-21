import 'package:dartz/dartz.dart';
import 'package:immigru/features/home/domain/entities/event.dart';
import 'package:immigru/features/home/domain/entities/immi_grove.dart';
import 'package:immigru/features/home/domain/entities/post.dart';
import 'package:immigru/core/network/models/failure.dart';

/// Repository interface for home screen data
abstract class HomeRepository {
  /// Get posts for the home feed
  ///
  /// [category] - Optional category filter
  /// [limit] - Maximum number of posts to return
  /// [offset] - Pagination offset
  Future<Either<Failure, List<Post>>> getPosts({
    String? category,
    int limit = 20,
    int offset = 0,
  });

  /// Get personalized posts for the user
  ///
  /// [userId] - ID of the current user
  /// [limit] - Maximum number of posts to return
  /// [offset] - Pagination offset
  Future<Either<Failure, List<Post>>> getPersonalizedPosts({
    required String userId,
    int limit = 20,
    int offset = 0,
  });

  /// Get upcoming events
  ///
  /// [upcoming] - Whether to only include upcoming events
  /// [limit] - Maximum number of events to return
  /// [offset] - Pagination offset
  Future<Either<Failure, List<Event>>> getEvents({
    bool upcoming = true,
    int limit = 10,
    int offset = 0,
  });

  /// Get ImmiGroves (communities)
  ///
  /// [query] - Optional search query
  /// [limit] - Maximum number of ImmiGroves to return
  /// [offset] - Pagination offset
  Future<Either<Failure, List<ImmiGrove>>> getImmiGroves({
    String? query,
    int limit = 10,
    int offset = 0,
  });

  /// Get recommended ImmiGroves for the user
  ///
  /// [limit] - Maximum number of ImmiGroves to return
  Future<Either<Failure, List<ImmiGrove>>> getRecommendedImmiGroves({
    int limit = 5,
  });

  /// Join or leave an ImmiGrove
  ///
  /// [immiGroveId] - ID of the ImmiGrove to join/leave
  /// [userId] - ID of the user performing the action
  /// [join] - Whether to join (true) or leave (false)
  Future<Either<Failure, bool>> joinImmiGrove({
    required String immiGroveId,
    required String userId,
    required bool join,
  });

  /// Create a new post
  ///
  /// [content] - Post content
  /// [userId] - ID of the user creating the post
  /// [category] - Post category
  /// [imageUrl] - Optional image URL
  Future<Either<Failure, Post>> createPost({
    required String content,
    required String userId,
    required String category,
    String? imageUrl,
  });

  /// Like or unlike a post
  ///
  /// [postId] - ID of the post to like/unlike
  /// [userId] - ID of the user performing the action
  /// [like] - Whether to like (true) or unlike (false)
  Future<Either<Failure, bool>> likePost({
    required String postId,
    required String userId,
    required bool like,
  });

  /// Register for an event
  ///
  /// [eventId] - ID of the event to register for
  /// [userId] - ID of the user registering
  Future<Either<Failure, bool>> registerForEvent({
    required String eventId,
    required String userId,
  });
}
