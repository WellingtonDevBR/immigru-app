import 'package:get_it/get_it.dart';
import 'package:immigru/core/cache/cache_service.dart';
import 'package:immigru/core/cache/image_cache_service.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/core/network/network_optimizer.dart';
import 'package:immigru/core/network/api_client.dart';
import 'package:immigru/features/home/domain/datasources/post_data_source.dart';
import 'package:immigru/features/home/data/datasources/post_data_source_impl.dart';
import 'package:immigru/features/home/data/repositories/post_repository_enhanced.dart';
import 'package:immigru/features/home/domain/repositories/post_repository.dart';
import 'package:immigru/features/home/domain/usecases/create_post_usecase.dart';
import 'package:immigru/features/home/presentation/bloc/post_creation/post_creation_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Module for post-related dependencies
/// 
/// Following clean architecture principles:
/// - Repository interfaces are defined in the domain layer
/// - Repository implementations are in the data layer
/// - We're using the enhanced repository implementation for better performance
class PostModule {
  /// Register all post-related dependencies
  static void register(GetIt locator) {
    // Data sources
    locator.registerLazySingleton<PostDataSource>(
      () => PostDataSourceImpl(
        supabase: Supabase.instance.client,
        apiClient: locator<ApiClient>(),
      ),
    );

    // Repositories
    locator.registerLazySingleton<PostRepository>(
      () => PostRepositoryEnhanced(
        postDataSource: locator<PostDataSource>(),
        logger: locator<UnifiedLogger>(),
        cacheService: locator<CacheService>(),
        imageCacheService: locator<ImageCacheService>(),
        networkOptimizer: locator<NetworkOptimizer>(),
      ),
    );

    // Use cases
    locator.registerLazySingleton<CreatePostUseCase>(
      () => CreatePostUseCase(locator<PostRepository>()),
    );

    // BLoCs
    locator.registerFactory<PostCreationBloc>(
      () => PostCreationBloc(
        createPostUseCase: locator<CreatePostUseCase>(),
      ),
    );
  }
}
