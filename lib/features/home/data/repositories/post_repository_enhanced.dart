import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:immigru/core/cache/cache_service.dart';
import 'package:immigru/core/cache/image_cache_service.dart';
import 'package:immigru/core/error/error_handler.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/core/network/network_optimizer.dart';
import 'package:immigru/core/network/network_optimizer_extension.dart';
import 'package:immigru/features/home/data/datasources/post_datasource.dart';
import 'package:immigru/features/home/domain/entities/author.dart';
import 'package:immigru/features/home/domain/entities/post.dart';
import 'package:immigru/features/home/domain/entities/post_media.dart';
import 'package:immigru/features/home/domain/repositories/post_repository.dart';
import 'package:path/path.dart' as path;

/// Enhanced implementation of the post repository with performance optimizations
class PostRepositoryEnhanced implements PostRepository {
  final PostDataSource _postDataSource;
  final UnifiedLogger _logger;
  final CacheService _cacheService;
  final ImageCacheService _imageCacheService;
  final NetworkOptimizer _networkOptimizer;
  
  // Cache keys
  static const String _postsListCacheKey = 'posts_list';
  static const String _personalizedPostsCacheKey = 'personalized_posts';
  static const String _postDetailsCacheKey = 'post_details';
  
  // Cache durations
  static const Duration _postsListCacheDuration = Duration(minutes: 5);
  static const Duration _postDetailsCacheDuration = Duration(hours: 1);
  
  /// Constructor
  PostRepositoryEnhanced({
    required PostDataSource postDataSource,
    required UnifiedLogger logger,
    required CacheService cacheService,
    required ImageCacheService imageCacheService,
    required NetworkOptimizer networkOptimizer,
  })  : _postDataSource = postDataSource,
        _logger = logger,
        _cacheService = cacheService,
        _imageCacheService = imageCacheService,
        _networkOptimizer = networkOptimizer;

  @override
  Future<Either<Failure, Post>> createPost({
    required String userId,
    required String content,
    required String category,
    List<PostMedia>? media,
  }) async {
    try {
      _logger.d('Creating post with content: $content',
          tag: 'PostRepositoryEnhanced');

      // Upload media files if they exist and are local files
      final List<PostMedia> processedMedia = [];

      if (media != null && media.isNotEmpty) {
        // Convert media to File objects for parallel upload
        final List<File> mediaFiles = [];
        final Map<String, String> mediaNames = {};
        
        for (final mediaItem in media) {
          if (!mediaItem.path.startsWith('http') &&
              File(mediaItem.path).existsSync()) {
            final file = File(mediaItem.path);
            mediaFiles.add(file);
            mediaNames[file.path] = mediaItem.name;
          } else {
            // Media is already a URL or doesn't exist
            processedMedia.add(mediaItem);
          }
        }
        
        // Use parallel upload for better performance
        if (mediaFiles.isNotEmpty) {
          try {
            final uploadedUrls = await _networkOptimizer.uploadMediaInParallel(
              mediaFiles,
              'https://immigrove.supabase.co/storage/v1/object/public/immigrove-media', // Replace with actual endpoint
              {'userId': userId},
              onProgress: (sent, total) {
                final progress = (sent / total * 100).toStringAsFixed(0);
                _logger.d('Upload progress: $progress%', tag: 'PostRepositoryEnhanced');
              },
            );
            
            // Create PostMedia objects from uploaded URLs
            for (int i = 0; i < mediaFiles.length; i++) {
              if (i < uploadedUrls.length) {
                final originalPath = mediaFiles[i].path;
                final name = mediaNames[originalPath] ?? 'media_${i + 1}';
                
                final uploadedMedia = PostMedia(
                  id: '${DateTime.now().millisecondsSinceEpoch}_$i',
                  path: uploadedUrls[i],
                  name: name,
                  type: _getMediaType(originalPath),
                  createdAt: DateTime.now(),
                );
                
                processedMedia.add(uploadedMedia);
                _logger.d('Media uploaded successfully: ${uploadedUrls[i]}',
                    tag: 'PostRepositoryEnhanced');
              }
            }
          } catch (e) {
            _logger.e('Error uploading media: $e', tag: 'PostRepositoryEnhanced');
            return Left(ErrorHandler.instance.handleException(
              e,
              tag: 'PostRepositoryEnhanced',
              customMessage: 'Failed to upload media',
            ));
          }
        }
      }

      try {
        // Create the post using the correct interface
        final response = await _postDataSource.createPost(
          userId: userId,
          content: content,
          type: category, // The API expects 'type' instead of 'category'
          media: processedMedia,
        );

        // Convert the response to a Post entity
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
            likeCount: postData['LikeCount'] ?? 0,
            commentCount: postData['CommentCount'] ?? 0,
            isLiked: postData['HasUserLiked'] ?? false,
            hasUserComment: postData['HasUserCommented'] ?? false,
            author: postData['Author'] != null
                ? Author(
                    id: postData['Author']['Id'],
                    displayName: postData['Author']['Name'],
                    avatarUrl: postData['Author']['ProfileImageUrl'],
                  )
                : null,
          );
          
          // Prefetch author avatar for better UX
          if (post.author?.avatarUrl != null && post.author!.avatarUrl!.isNotEmpty) {
            _imageCacheService.prefetchImage(post.author!.avatarUrl!);
          }
          
          // Prefetch post image if available
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty) {
            _imageCacheService.prefetchImage(post.imageUrl!);
          }
          
          // Cache the newly created post
          _cachePost(post);
          
          _logger.d('Post created successfully with ID: ${post.id}',
              tag: 'PostRepositoryEnhanced');
          return Right(post);
        } else {
          final errorMessage = response['error'] ?? 'Unknown error creating post';
          _logger.e('Error creating post: $errorMessage',
              tag: 'PostRepositoryEnhanced');
          return Left(ErrorHandler.instance.handleException(
            Exception(errorMessage),
            tag: 'PostRepositoryEnhanced',
            customMessage: 'Failed to create post',
          ));
        }
      } catch (e) {
        _logger.e('Error creating post: $e', tag: 'PostRepositoryEnhanced');
        // Use the ErrorHandler to standardize error handling
        return Left(ErrorHandler.instance.handleException(
          e,
          tag: 'PostRepositoryEnhanced',
          customMessage: 'Failed to create post',
        ));
      }
    } catch (e) {
      _logger.e('Exception in post creation process: $e', tag: 'PostRepositoryEnhanced');
      // Use the ErrorHandler to standardize error handling
      return Left(ErrorHandler.instance.handleException(
        e,
        tag: 'PostRepositoryEnhanced',
        customMessage: 'Failed to process post creation',
      ));
    }
  }

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
    bool bypassCache = false, // New parameter to force bypass cache
  }) async {
    try {
      // Generate cache key based on parameters
      final cacheKey = _generatePostsListCacheKey(
        filter: filter,
        category: category,
        userId: userId,
        immigroveId: immigroveId,
        excludeCurrentUser: excludeCurrentUser,
        currentUserId: currentUserId,
        limit: limit,
        offset: offset,
      );
      
      // Check cache first (only for first page and if not bypassing cache)
      if (offset == 0 && !bypassCache) {
        final cachedPosts = _cacheService.get<List<Post>>(cacheKey);
        if (cachedPosts != null) {
          _logger.d('Returning cached posts for key: $cacheKey',
              tag: 'PostRepositoryEnhanced');
          
          // Prefetch images for better UX
          _prefetchPostImages(cachedPosts);
          
          return Right(cachedPosts);
        }
      }
      
      _logger.d('Getting posts with filter: $filter',
          tag: 'PostRepositoryEnhanced');

      // Use network optimizer with retry for better reliability
      final posts = await _networkOptimizer.executePostOperation(
        () => _postDataSource.getPosts(
          filter: filter,
          category: category,
          userId: userId,
          immigroveId: immigroveId,
          excludeCurrentUser: excludeCurrentUser,
          currentUserId: currentUserId,
          limit: limit,
          offset: offset,
        ),
      );
      
      // Cache the posts (only for first page)
      if (offset == 0) {
        _cacheService.set<List<Post>>(
          cacheKey,
          posts,
          expiration: _postsListCacheDuration,
          persistToDisk: true,
        );
      }
      
      // Prefetch images for better UX
      _prefetchPostImages(posts);

      return Right(posts);
    } catch (e) {
      _logger.e('Failed to get posts: $e', tag: 'PostRepositoryEnhanced');
      return Left(ErrorHandler.instance.handleException(
        e,
        tag: 'PostRepositoryEnhanced',
        customMessage: 'Failed to get posts',
      ));
    }
  }

  @override
  Future<Either<Failure, List<Post>>> getPersonalizedPosts({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Generate cache key
      final cacheKey = '$_personalizedPostsCacheKey:$userId:$limit:$offset';
      
      // Check cache first (only for first page)
      if (offset == 0) {
        final cachedPosts = _cacheService.get<List<Post>>(cacheKey);
        if (cachedPosts != null) {
          _logger.d('Returning cached personalized posts for user: $userId',
              tag: 'PostRepositoryEnhanced');
          
          // Prefetch images for better UX
          _prefetchPostImages(cachedPosts);
          
          return Right(cachedPosts);
        }
      }
      
      _logger.d('Getting personalized posts for user: $userId',
          tag: 'PostRepositoryEnhanced');

      // Use network optimizer with retry for better reliability
      final posts = await _networkOptimizer.executePostOperation(
        () => _postDataSource.getPersonalizedPosts(
          userId: userId,
          limit: limit,
          offset: offset,
        ),
      );
      
      // Cache the posts (only for first page)
      if (offset == 0) {
        _cacheService.set<List<Post>>(
          cacheKey,
          posts,
          expiration: _postsListCacheDuration,
          persistToDisk: true,
        );
      }
      
      // Prefetch images for better UX
      _prefetchPostImages(posts);

      return Right(posts);
    } catch (e) {
      _logger.e('Failed to get personalized posts: $e',
          tag: 'PostRepositoryEnhanced');
      return Left(ErrorHandler.instance.handleException(
        e,
        tag: 'PostRepositoryEnhanced',
        customMessage: 'Failed to get personalized posts',
      ));
    }
  }

  @override
  Future<Either<Failure, Post>> editPost({
    required String postId,
    required String userId,
    required String content,
    required String category,
  }) async {
    try {
      _logger.d('Editing post: $postId', tag: 'PostRepositoryEnhanced');

      final post = await _postDataSource.editPost(
        postId: postId,
        userId: userId,
        content: content,
        category: category,
      );
      
      // Update cache with edited post
      _cachePost(post);

      return Right(post);
    } catch (e) {
      _logger.e('Failed to edit post: $e', tag: 'PostRepositoryEnhanced');
      return Left(ErrorHandler.instance.handleException(
        e,
        tag: 'PostRepositoryEnhanced',
        customMessage: 'Failed to edit post',
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> deletePost({
    required String postId,
    required String userId,
  }) async {
    try {
      _logger.d('Deleting post: $postId', tag: 'PostRepositoryEnhanced');

      final result = await _postDataSource.deletePost(
        postId: postId,
        userId: userId,
      );
      
      // Remove post from cache if deleted successfully
      if (result) {
        _removePostFromCache(postId);
      }

      return Right(result);
    } catch (e) {
      _logger.e('Failed to delete post: $e', tag: 'PostRepositoryEnhanced');
      return Left(ErrorHandler.instance.handleException(
        e,
        tag: 'PostRepositoryEnhanced',
        customMessage: 'Failed to delete post',
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> likePost({
    required String postId,
    required String userId,
    required bool like,
  }) async {
    try {
      _logger.d('${like ? 'Liking' : 'Unliking'} post: $postId',
          tag: 'PostRepositoryEnhanced');

      final result = await _postDataSource.likePost(
        postId: postId,
        userId: userId,
        like: like,
      );
      
      // Clear all cached posts to ensure fresh data
      _logger.d('Clearing all post caches after like/unlike action',
          tag: 'PostRepositoryEnhanced');
      _cacheService.clearByPrefix(_postsListCacheKey);
      _cacheService.clearByPrefix(_personalizedPostsCacheKey);
      
      // Remove the specific post from cache
      final cacheKey = '$_postDetailsCacheKey:$postId';
      _cacheService.remove(cacheKey);

      return Right(result);
    } catch (e) {
      _logger.e('Failed to ${like ? 'like' : 'unlike'} post: $e',
          tag: 'PostRepositoryEnhanced');
      return Left(ErrorHandler.instance.handleException(
        e,
        tag: 'PostRepositoryEnhanced',
        customMessage: 'Failed to ${like ? 'like' : 'unlike'} post',
      ));
    }
  }
  
  // Helper method to generate cache key for posts list
  String _generatePostsListCacheKey({
    required String filter,
    String? category,
    String? userId,
    String? immigroveId,
    required bool excludeCurrentUser,
    String? currentUserId,
    required int limit,
    required int offset,
  }) {
    return '$_postsListCacheKey:$filter:${category ?? ''}:${userId ?? ''}:${immigroveId ?? ''}:$excludeCurrentUser:${currentUserId ?? ''}:$limit:$offset';
  }
  
  // Helper method to cache a post
  void _cachePost(Post post) {
    final cacheKey = '$_postDetailsCacheKey:${post.id}';
    _cacheService.set<Post>(
      cacheKey,
      post,
      expiration: _postDetailsCacheDuration,
      persistToDisk: true,
    );
  }
  
  // Helper method to remove a post from cache
  void _removePostFromCache(String postId) {
    final cacheKey = '$_postDetailsCacheKey:$postId';
    _cacheService.remove(cacheKey);
    
    // Also clear any list caches that might contain this post
    _cacheService.clearByPrefix(_postsListCacheKey);
    _cacheService.clearByPrefix(_personalizedPostsCacheKey);
  }
  
  // Note: We no longer need to update individual posts in cache
  // Instead, we clear the entire cache to ensure fresh data is fetched
  
  // Helper method to prefetch images for posts
  void _prefetchPostImages(List<Post> posts) {
    final imagesToPrefetch = <String>[];
    
    for (final post in posts) {
      if (post.imageUrl != null && post.imageUrl!.isNotEmpty) {
        imagesToPrefetch.add(post.imageUrl!);
      }
      
      if (post.author?.avatarUrl != null && post.author!.avatarUrl!.isNotEmpty) {
        imagesToPrefetch.add(post.author!.avatarUrl!);
      }
    }
    
    if (imagesToPrefetch.isNotEmpty) {
      _imageCacheService.prefetchImages(imagesToPrefetch);
    }
  }
  
  // Helper method to determine media type from file path
  MediaType _getMediaType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    
    // Check if the file is an image
    if (['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp', '.heic'].contains(extension)) {
      return MediaType.image;
    }
    
    // Check if the file is a video
    if (['.mp4', '.mov', '.avi', '.wmv', '.flv', '.webm', '.mkv', '.3gp'].contains(extension)) {
      return MediaType.video;
    }
    
    // Default to image if unknown
    return MediaType.image;
  }
}
