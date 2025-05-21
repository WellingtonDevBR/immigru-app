import 'package:dartz/dartz.dart';
import 'package:immigru/features/home/domain/entities/post.dart';
import 'package:immigru/features/home/domain/repositories/home_repository.dart';
import 'package:immigru/core/network/models/failure.dart';

/// Use case for creating a new post
class CreatePostUseCase {
  final HomeRepository repository;

  CreatePostUseCase(this.repository);

  /// Execute the use case
  /// 
  /// [content] - Post content
  /// [userId] - ID of the user creating the post
  /// [category] - Post category
  /// [imageUrl] - Optional image URL
  Future<Either<Failure, Post>> call({
    required String content,
    required String userId,
    required String category,
    String? imageUrl,
  }) {
    return repository.createPost(
      content: content,
      userId: userId,
      category: category,
      imageUrl: imageUrl,
    );
  }
}
