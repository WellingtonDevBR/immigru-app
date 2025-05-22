import 'package:get_it/get_it.dart';
import 'package:immigru/features/home/data/datasources/home_data_source.dart';
import 'package:immigru/features/home/data/repositories/home_repository_impl.dart';
import 'package:immigru/features/home/domain/repositories/home_repository.dart';
import 'package:immigru/features/home/domain/usecases/create_comment_usecase.dart';
import 'package:immigru/features/home/domain/usecases/create_post_usecase.dart';
import 'package:immigru/features/home/domain/usecases/get_comments_usecase.dart';
import 'package:immigru/features/home/domain/usecases/get_events_usecase.dart';
import 'package:immigru/features/home/domain/usecases/get_personalized_posts_usecase.dart';
import 'package:immigru/features/home/domain/usecases/get_posts_usecase.dart';
import 'package:immigru/features/home/presentation/bloc/comments/comments_bloc.dart';
import 'package:immigru/features/home/presentation/bloc/home_bloc.dart';
import 'package:immigru/core/logging/logger_interface.dart';
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

      // Repositories
      if (!sl.isRegistered<HomeRepository>()) {
        sl.registerLazySingleton<HomeRepository>(
          () => HomeRepositoryImpl(
            dataSource: sl<HomeDataSource>(),
            logger: sl<LoggerInterface>(),
          ),
        );
      }

      // Use cases
      if (!sl.isRegistered<GetPostsUseCase>()) {
        sl.registerLazySingleton(
          () => GetPostsUseCase(sl<HomeRepository>()),
        );
      }

      if (!sl.isRegistered<GetPersonalizedPostsUseCase>()) {
        sl.registerLazySingleton(
          () => GetPersonalizedPostsUseCase(sl<HomeRepository>()),
        );
      }

      if (!sl.isRegistered<GetEventsUseCase>()) {
        sl.registerLazySingleton(
          () => GetEventsUseCase(sl<HomeRepository>()),
        );
      }

      // Skip CreatePostUseCase registration - it's now handled in PostModule
      // This prevents duplicate registration errors
      
      // Comment-related use cases
      if (!sl.isRegistered<GetCommentsUseCase>()) {
        sl.registerLazySingleton(
          () => GetCommentsUseCase(sl<HomeRepository>()),
        );
      }
      
      if (!sl.isRegistered<CreateCommentUseCase>()) {
        sl.registerLazySingleton(
          () => CreateCommentUseCase(repository: sl<HomeRepository>()),
        );
      }

      // BLoCs - Using singleton for HomeBloc to prevent multiple instances
      if (!sl.isRegistered<HomeBloc>()) {
        sl.registerFactory(
          () => HomeBloc(
            getPostsUseCase: sl<GetPostsUseCase>(),
            getPersonalizedPostsUseCase: sl<GetPersonalizedPostsUseCase>(),
            getEventsUseCase: sl<GetEventsUseCase>(),
            createPostUseCase: sl<CreatePostUseCase>(),
            logger: sl<LoggerInterface>(),
          ),
        );
      }
      
      // Comments BLoC
      if (!sl.isRegistered<CommentsBloc>()) {
        sl.registerFactory(
          () => CommentsBloc(
            getCommentsUseCase: sl<GetCommentsUseCase>(),
            createCommentUseCase: sl<CreateCommentUseCase>(),
          ),
        );
      }
    } catch (e) {}
  }
}
