import 'package:dartz/dartz.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/home/domain/entities/post.dart';

/// Repository interface for home screen data
/// 
/// This interface has been refactored to move functionality to more specific repositories:
/// - PostRepository: For post-related operations
/// - CommentRepository: For comment-related operations
/// - EventRepository: For event-related operations
/// - ImmiGroveRepository: For ImmiGrove-related operations
/// 
/// This interface is kept for backward compatibility but will be deprecated in future versions.
/// @deprecated Use specific repositories instead
abstract class HomeRepository {
  /// Get posts for the home feed
  /// 
  /// @deprecated Use PostRepository.getPosts instead
  Future<Either<Failure, List<Post>>> getPosts({
    String filter = 'all',
    String? category,
    String? userId,
    String? immigroveId,
    bool excludeCurrentUser = false,
    String? currentUserId,
    int limit = 20,
    int offset = 0,
  });
  
  /// Get personalized posts for the user
  /// 
  /// @deprecated Use PostRepository.getPersonalizedPosts instead
  Future<Either<Failure, List<Post>>> getPersonalizedPosts({
    required String userId,
    int limit = 20,
    int offset = 0,
  });
  
  /// Edit an existing post
  /// 
  /// @deprecated Use PostRepository.editPost instead
  Future<Either<Failure, Post>> editPost({
    required String postId,
    required String userId,
    required String content,
    required String category,
  });
  
  /// Delete a post
  /// 
  /// @deprecated Use PostRepository.deletePost instead
  Future<Either<Failure, bool>> deletePost({
    required String postId,
    required String userId,
  });
}