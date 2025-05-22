import 'package:dartz/dartz.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/home/domain/entities/post.dart';
import 'package:immigru/features/home/domain/entities/post_media.dart';

/// Repository interface for post-related operations
abstract class PostRepository {
  /// Create a new post
  /// 
  /// Returns a [Post] entity on success or a [Failure] on error
  Future<Either<Failure, Post>> createPost({
    required String userId,
    required String content,
    required String category,
    List<PostMedia>? media,
  });
}
