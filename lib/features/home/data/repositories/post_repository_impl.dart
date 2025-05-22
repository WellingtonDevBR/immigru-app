import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/home/data/datasources/post_datasource.dart';
import 'package:immigru/features/home/domain/entities/post.dart';
import 'package:immigru/features/home/domain/entities/post_media.dart';
import 'package:immigru/features/home/domain/repositories/post_repository.dart';

/// Implementation of the post repository
class PostRepositoryImpl implements PostRepository {
  final PostDataSource _postDataSource;
  final UnifiedLogger _logger;

  /// Constructor
  PostRepositoryImpl({
    required PostDataSource postDataSource,
    required UnifiedLogger logger,
  })  : _postDataSource = postDataSource,
        _logger = logger;

  @override
  Future<Either<Failure, Post>> createPost({
    required String userId,
    required String content,
    required String category,
    List<PostMedia>? media,
  }) async {
    try {
      _logger.d('Creating post with content: $content', tag: 'PostRepositoryImpl');
      
      // Upload media files if they exist and are local files
      final List<PostMedia> processedMedia = [];
      
      if (media != null && media.isNotEmpty) {
        for (final mediaItem in media) {
          // Check if the media is a local file that needs to be uploaded
          if (!mediaItem.path.startsWith('http') && File(mediaItem.path).existsSync()) {
            try {
              final uploadedUrl = await _postDataSource.uploadPostMedia(
                mediaItem.path,
                mediaItem.name,
              );
              
              // Create a new PostMedia with the uploaded URL
              final uploadedMedia = PostMedia(
                id: mediaItem.id,
                path: uploadedUrl,
                name: mediaItem.name,
                type: mediaItem.type,
                createdAt: mediaItem.createdAt,
              );
              
              processedMedia.add(uploadedMedia);
              _logger.d('Media uploaded: ${uploadedUrl}', tag: 'PostRepositoryImpl');
            } catch (e) {
              _logger.e('Failed to upload media: $e', tag: 'PostRepositoryImpl');
              // Continue with other media items even if one fails
            }
          } else {
            // Media is already a URL or doesn't exist, use as is
            processedMedia.add(mediaItem);
          }
        }
      }
      
      // Call the edge function to create the post
      final response = await _postDataSource.createPost(
        userId: userId,
        content: content,
        type: category, // Use category as the post type
        media: processedMedia,
      );
      
      if (response['success'] == true && response['data'] != null) {
        final postData = response['data'];
        
        // Create a Post entity from the response
        final post = Post(
          id: postData['Id'],
          content: postData['Content'],
          userId: postData['UserId'],
          createdAt: DateTime.parse(postData['CreatedAt']),
          category: postData['Type'], // Use Type field as category
          imageUrl: postData['MediaUrl'], // Use MediaUrl as imageUrl
          // Other fields would be populated here if available
        );
        
        _logger.d('Post created successfully with ID: ${post.id}', tag: 'PostRepositoryImpl');
        return Right(post);
      } else {
        final errorMessage = response['error'] ?? 'Unknown error creating post';
        _logger.e('Error creating post: $errorMessage', tag: 'PostRepositoryImpl');
        return Left(Failure(message: errorMessage));
      }
    } catch (e) {
      _logger.e('Exception creating post: $e', tag: 'PostRepositoryImpl');
      return Left(Failure(message: 'Failed to create post: $e'));
    }
  }
}
