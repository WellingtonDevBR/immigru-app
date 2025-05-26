import 'package:get_it/get_it.dart';
import 'package:immigru/core/cache/cache_service.dart';
import 'package:immigru/core/cache/image_cache_service.dart';
import 'package:immigru/core/logging/logger_interface.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/core/network/network_optimizer.dart';
import 'package:immigru/features/home/data/datasources/home_data_source.dart';
import 'package:immigru/features/home/data/datasources/post_datasource.dart';
import 'package:immigru/features/home/data/repositories/home_repository_impl.dart';
// Using the enhanced repository implementation for better performance
import 'package:immigru/features/home/data/repositories/post_repository_enhanced.dart';
import 'package:immigru/features/home/domain/repositories/home_repository.dart';
import 'package:immigru/features/home/domain/repositories/post_repository.dart';
import 'package:immigru/features/home/domain/usecases/create_comment_usecase.dart';
import 'package:immigru/features/home/domain/usecases/create_post_usecase.dart';
import 'package:immigru/features/home/domain/usecases/delete_comment_usecase.dart';
import 'package:immigru/features/home/domain/usecases/delete_post_usecase.dart';
import 'package:immigru/features/home/domain/usecases/edit_comment_usecase.dart';
import 'package:immigru/features/home/domain/usecases/edit_post_usecase.dart';
import 'package:immigru/features/home/domain/usecases/get_comments_usecase.dart';
import 'package:immigru/features/home/domain/usecases/get_personalized_posts_usecase.dart';
import 'package:immigru/features/home/domain/usecases/get_posts_usecase.dart';
import 'package:immigru/features/home/domain/usecases/like_comment_usecase.dart';
import 'package:immigru/features/home/domain/usecases/like_post_usecase.dart';
import 'package:immigru/features/home/domain/usecases/unlike_comment_usecase.dart';
import 'package:immigru/features/home/presentation/bloc/comments/comments_bloc.dart';
import 'package:immigru/features/home/presentation/bloc/home_bloc.dart';
import 'package:immigru/features/home/presentation/bloc/post_creation/post_creation_bloc.dart';
import 'package:immigru/core/network/api_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Module for home feature dependency injection
class HomeModule {
  /// Register all dependencies for the home feature
  static void init(GetIt sl) {
    try {
      // Data sources
      if (!sl.isRegistered<HomeDataSource>()) {
        sl.registerLazySingleton<HomeDataSource>(
          () => HomeDataSourceImpl(
            apiClient: sl<ApiClient>(),
            supabase: sl<SupabaseClient>(),
          ),
        );
      }

      // Register PostDataSource
      if (!sl.isRegistered<PostDataSource>()) {
        sl.registerLazySingleton<PostDataSource>(
          () => PostDataSource(),
        );
      }

      // Repositories
      // Register PostRepository first since HomeRepository depends on it
      if (!sl.isRegistered<PostRepository>()) {
        sl.registerLazySingleton<PostRepository>(
          () => PostRepositoryEnhanced(
            postDataSource: sl<PostDataSource>(),
            logger: sl<UnifiedLogger>(),
            cacheService: sl<CacheService>(),
            imageCacheService: sl<ImageCacheService>(),
            networkOptimizer: sl<NetworkOptimizer>(),
          ),
        );
      }

      // Now register HomeRepository with PostRepository dependency
      if (!sl.isRegistered<HomeRepository>()) {
        sl.registerLazySingleton<HomeRepository>(
          () => HomeRepositoryImpl(
            dataSource: sl<HomeDataSource>(),
            logger: sl<LoggerInterface>(),
            postRepository: sl<PostRepository>(),
          ),
        );
      }

      // Use cases
      if (!sl.isRegistered<GetPostsUseCase>()) {
        sl.registerLazySingleton(
          () => GetPostsUseCase(sl<PostRepository>()),
        );
      }

      if (!sl.isRegistered<GetPersonalizedPostsUseCase>()) {
        sl.registerLazySingleton(
          () => GetPersonalizedPostsUseCase(sl<PostRepository>()),
        );
      }

      // Event-related use cases are now handled in EventModule

      // Skip CreatePostUseCase registration - it's now handled in PostModule
      // This prevents duplicate registration errors

      // Comment-related use cases are now handled in CommentModule

      // Register edit post use case
      if (!sl.isRegistered<EditPostUseCase>()) {
        sl.registerLazySingleton(
          () => EditPostUseCase(repository: sl<PostRepository>()),
        );
      }

      // Register delete post use case
      if (!sl.isRegistered<DeletePostUseCase>()) {
        sl.registerLazySingleton(
          () => DeletePostUseCase(repository: sl<PostRepository>()),
        );
      }
      
      // Register like post use case
      if (!sl.isRegistered<LikePostUseCase>()) {
        sl.registerLazySingleton(
          () => LikePostUseCase(sl<PostRepository>()),
        );
      }

      // BLoCs - Using singleton for HomeBloc to prevent multiple instances
      if (!sl.isRegistered<HomeBloc>()) {
        sl.registerLazySingleton(
          () => HomeBloc(
            getPostsUseCase: sl<GetPostsUseCase>(),
            createPostUseCase: sl<CreatePostUseCase>(),
            editPostUseCase: sl<EditPostUseCase>(),
            deletePostUseCase: sl<DeletePostUseCase>(),
            logger: sl<UnifiedLogger>(),
            likePostUseCase: sl<LikePostUseCase>(),
          ),
        );
      }

      // Comments BLoC
      if (!sl.isRegistered<CommentsBloc>()) {
        sl.registerFactory(
          () => CommentsBloc(
            getCommentsUseCase: sl<GetCommentsUseCase>(),
            createCommentUseCase: sl<CreateCommentUseCase>(),
            editCommentUseCase: sl<EditCommentUseCase>(),
            deleteCommentUseCase: sl<DeleteCommentUseCase>(),
            likeCommentUseCase: sl<LikeCommentUseCase>(),
            unlikeCommentUseCase: sl<UnlikeCommentUseCase>(),
          ),
        );
      }

      // Post Creation BLoC
      if (!sl.isRegistered<PostCreationBloc>()) {
        sl.registerFactory(
          () => PostCreationBloc(
            createPostUseCase: sl<CreatePostUseCase>(),
          ),
        );
      }
    } catch (e) {
      // Log the error but don't rethrow to prevent app crashes during initialization
      final logger = UnifiedLogger();
      logger.e('Error initializing HomeModule: $e', tag: 'HomeModule');
    }
  }
}
