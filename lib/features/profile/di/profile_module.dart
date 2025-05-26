import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:immigru/core/error/error_handler.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/core/storage/secure_storage.dart';
import 'package:immigru/features/home/domain/repositories/post_repository.dart';
import 'package:immigru/features/home/domain/usecases/get_posts_usecase.dart';
import 'package:immigru/features/home/domain/usecases/like_post_usecase.dart';
import 'package:immigru/features/home/domain/usecases/delete_post_usecase.dart';
import 'package:immigru/features/home/domain/usecases/edit_post_usecase.dart';
import 'package:immigru/features/profile/data/datasources/user_profile_local_data_source.dart';
import 'package:immigru/features/profile/data/datasources/user_profile_remote_data_source.dart';
import 'package:immigru/features/profile/data/repositories/user_profile_repository_impl.dart';
import 'package:immigru/features/profile/domain/repositories/user_profile_repository.dart';
import 'package:immigru/features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:immigru/features/profile/domain/usecases/get_user_stats_usecase.dart';
import 'package:immigru/features/profile/domain/usecases/remove_cover_image_usecase.dart';
import 'package:immigru/features/profile/domain/usecases/update_user_profile_usecase.dart';
import 'package:immigru/features/profile/domain/usecases/upload_avatar_usecase.dart';
import 'package:immigru/features/profile/domain/usecases/upload_cover_image_usecase.dart';
import 'package:immigru/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Register all dependencies for the profile feature
void registerProfileDependencies(GetIt sl) {
  // Register home dependencies if they're not already registered
  _registerHomeUseCasesIfNeeded(sl);
  
  // BLoC
  sl.registerFactory(
    () => ProfileBloc(
      getUserProfileUseCase: sl<GetUserProfileUseCase>(),
      updateUserProfileUseCase: sl<UpdateUserProfileUseCase>(),
      uploadAvatarUseCase: sl<UploadAvatarUseCase>(),
      uploadCoverImageUseCase: sl<UploadCoverImageUseCase>(),
      removeCoverImageUseCase: sl<RemoveCoverImageUseCase>(),
      getUserStatsUseCase: sl<GetUserStatsUseCase>(),
      getPostsUseCase: sl<GetPostsUseCase>(),
      likePostUseCase: sl<LikePostUseCase>(),
      deletePostUseCase: sl<DeletePostUseCase>(),
      editPostUseCase: sl<EditPostUseCase>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => UploadAvatarUseCase(sl()));
  sl.registerLazySingleton(() => UploadCoverImageUseCase(sl()));
  sl.registerLazySingleton(() => RemoveCoverImageUseCase(sl()));
  sl.registerLazySingleton(() => GetUserStatsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<UserProfileRepository>(
    () => UserProfileRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      connectivity: sl<Connectivity>(),
      errorHandler: ErrorHandler.instance,
    ),
  );

  // Data sources
  sl.registerLazySingleton<UserProfileRemoteDataSource>(
    () => UserProfileRemoteDataSourceImpl(sl<SupabaseClient>()),
  );
  
  sl.registerLazySingleton<UserProfileLocalDataSource>(
    () => UserProfileLocalDataSourceImpl(sl<SecureStorage>()),
  );
}

/// Register home use cases if they're not already registered
/// This ensures that the ProfileBloc has all the dependencies it needs
void _registerHomeUseCasesIfNeeded(GetIt sl) {
  final logger = GetIt.instance<UnifiedLogger>();
  
  try {
    // Check if the use cases are already registered
    sl<LikePostUseCase>();
    sl<DeletePostUseCase>();
    sl<EditPostUseCase>();
    logger.d('Home use cases already registered, skipping registration', tag: 'ProfileModule');
  } catch (e) {
    logger.d('Registering home use cases for ProfileBloc', tag: 'ProfileModule');
    
    // Register the repository if not already registered
    if (!sl.isRegistered<PostRepository>()) {
      // This is a simplified implementation - in a real app, you would register the actual repository
      // For now, we'll just throw an error if it's not registered
      throw Exception('PostRepository must be registered before using ProfileBloc');
    }
    
    // Register the use cases
    if (!sl.isRegistered<LikePostUseCase>()) {
      sl.registerLazySingleton(() => LikePostUseCase(sl<PostRepository>()));
    }
    
    if (!sl.isRegistered<DeletePostUseCase>()) {
      sl.registerLazySingleton(() => DeletePostUseCase(repository: sl<PostRepository>()));
    }
    
    if (!sl.isRegistered<EditPostUseCase>()) {
      sl.registerLazySingleton(() => EditPostUseCase(repository: sl<PostRepository>()));
    }
  }
}
