import 'package:get_it/get_it.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/features/home/data/datasources/post_datasource.dart';
import 'package:immigru/features/home/data/repositories/post_repository_impl.dart';
import 'package:immigru/features/home/domain/repositories/post_repository.dart';
import 'package:immigru/features/home/domain/usecases/create_post_usecase.dart';
import 'package:immigru/features/home/presentation/bloc/post_creation/post_creation_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Module for post-related dependencies
class PostModule {
  /// Register all post-related dependencies
  static void register(GetIt locator) {
    // Data sources
    locator.registerLazySingleton<PostDataSource>(
      () => PostDataSource(
        supabaseClient: Supabase.instance.client,
      ),
    );

    // Repositories
    locator.registerLazySingleton<PostRepository>(
      () => PostRepositoryImpl(
        postDataSource: locator<PostDataSource>(),
        logger: locator<UnifiedLogger>(),
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
