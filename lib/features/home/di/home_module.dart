import 'package:get_it/get_it.dart';
import 'package:immigru/features/home/data/datasources/home_data_source.dart';
import 'package:immigru/features/home/data/repositories/home_repository_impl.dart';
import 'package:immigru/features/home/domain/repositories/home_repository.dart';
import 'package:immigru/features/home/domain/usecases/create_post_usecase.dart';
import 'package:immigru/features/home/domain/usecases/get_events_usecase.dart';
import 'package:immigru/features/home/domain/usecases/get_personalized_posts_usecase.dart';
import 'package:immigru/features/home/domain/usecases/get_posts_usecase.dart';
import 'package:immigru/features/home/presentation/bloc/home_bloc.dart';
import 'package:immigru/new_core/logging/logger_interface.dart';
import 'package:immigru/new_core/network/api_client.dart';
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
      
      if (!sl.isRegistered<CreatePostUseCase>()) {
        sl.registerLazySingleton(
          () => CreatePostUseCase(sl<HomeRepository>()),
        );
      }

      // BLoCs
      sl.registerFactory(
        () => HomeBloc(
          getPostsUseCase: sl<GetPostsUseCase>(),
          getPersonalizedPostsUseCase: sl<GetPersonalizedPostsUseCase>(),
          getEventsUseCase: sl<GetEventsUseCase>(),
          createPostUseCase: sl<CreatePostUseCase>(),
          logger: sl<LoggerInterface>(),
        ),
      );
    } catch (e, stackTrace) {
      print('Error while registering home dependencies: $e');
      print('Stack trace: $stackTrace');
    }
  }
}
