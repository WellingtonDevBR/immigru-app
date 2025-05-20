import 'package:get_it/get_it.dart';
import 'package:immigru/new_core/logging/logger_interface.dart';
import 'package:immigru/new_core/network/edge_function_client.dart';
import '../data/datasources/interest_data_source.dart';
import '../data/repositories/interest_repository_impl.dart';
import '../domain/repositories/interest_repository.dart';
import '../domain/usecases/get_interests_usecase.dart';
import '../domain/usecases/get_user_interests_usecase.dart';
import '../domain/usecases/save_user_interests_usecase.dart';
import '../presentation/bloc/interest/interest_bloc.dart';

/// Register all dependencies for the Interest feature
void registerInterestDependencies(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<InterestDataSource>(
    () => InterestSupabaseDataSource(
      client: sl<EdgeFunctionClient>(),
      logger: sl<LoggerInterface>(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<InterestRepository>(
    () => InterestRepositoryImpl(
      dataSource: sl<InterestDataSource>(),
      logger: sl<LoggerInterface>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(
    () => GetInterestsUseCase(sl<InterestRepository>()),
  );

  sl.registerLazySingleton(
    () => GetUserInterestsUseCase(sl<InterestRepository>()),
  );

  sl.registerLazySingleton(
    () => SaveUserInterestsUseCase(sl<InterestRepository>()),
  );

  // BLoCs
  sl.registerFactory(
    () => InterestBloc(
      getInterestsUseCase: sl<GetInterestsUseCase>(),
      getUserInterestsUseCase: sl<GetUserInterestsUseCase>(),
      saveUserInterestsUseCase: sl<SaveUserInterestsUseCase>(),
      logger: sl<LoggerInterface>(),
    ),
  );
}
