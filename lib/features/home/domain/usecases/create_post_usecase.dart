import 'package:dartz/dartz.dart';
import 'package:immigru/features/home/domain/entities/post.dart';
import 'package:immigru/features/home/domain/entities/post_media.dart';
import 'package:immigru/features/home/domain/repositories/post_repository.dart';
import 'package:immigru/core/network/models/failure.dart';

/// Use case for creating a new post
class CreatePostUseCase {
  final PostRepository repository;

  CreatePostUseCase(this.repository);

  /// Execute the use case
  /// 
  /// [content] - Post content
  /// [userId] - ID of the user creating the post
  /// [category] - Post category
  /// [media] - Optional list of media items (images or videos)
  Future<Either<Failure, Post>> call({
    required String content,
    required String userId,
    required String category,
    List<PostMedia>? media,
  }) {
    return repository.createPost(
      content: content,
      userId: userId,
      category: category,
      media: media,
    );
  }
}
