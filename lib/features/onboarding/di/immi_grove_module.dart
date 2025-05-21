import 'package:get_it/get_it.dart';
import 'package:immigru/core/logging/logger_interface.dart';
import 'package:immigru/core/network/edge_function_client.dart';

import '../data/datasources/immi_grove_data_source.dart';
import '../data/repositories/immi_grove_repository_impl.dart';
import '../domain/repositories/immi_grove_repository.dart';
import '../domain/usecases/get_joined_immi_groves_usecase.dart';
import '../domain/usecases/get_recommended_immi_groves_usecase.dart';
import '../domain/usecases/join_immi_grove_usecase.dart';
import '../domain/usecases/leave_immi_grove_usecase.dart';
import '../domain/usecases/save_selected_immi_groves_usecase.dart';
import '../presentation/bloc/immi_grove/immi_grove_bloc.dart';

/// Module for ImmiGrove dependencies
class ImmiGroveModule {
  /// Register ImmiGrove dependencies
  static void register(GetIt sl) {
    // Data sources
    sl.registerLazySingleton<ImmiGroveDataSource>(
      () => ImmiGroveSupabaseDataSource(
        client: sl<EdgeFunctionClient>(),
        logger: sl<LoggerInterface>(instanceName: 'onboarding_logger'),
      ),
    );

    // Repositories
    sl.registerLazySingleton<ImmiGroveRepository>(
      () => ImmiGroveRepositoryImpl(
        dataSource: sl<ImmiGroveDataSource>(),
        logger: sl<LoggerInterface>(instanceName: 'onboarding_logger'),
      ),
    );

    // Use cases
    sl.registerLazySingleton(
      () => GetRecommendedImmiGrovesUseCase(sl<ImmiGroveRepository>()),
    );

    sl.registerLazySingleton(
      () => JoinImmiGroveUseCase(sl<ImmiGroveRepository>()),
    );

    sl.registerLazySingleton(
      () => LeaveImmiGroveUseCase(sl<ImmiGroveRepository>()),
    );

    sl.registerLazySingleton(
      () => GetJoinedImmiGrovesUseCase(sl<ImmiGroveRepository>()),
    );

    sl.registerLazySingleton(
      () => SaveSelectedImmiGrovesUseCase(sl<ImmiGroveRepository>()),
    );

    // BLoCs
    sl.registerFactory(
      () => ImmiGroveBloc(
        getRecommendedImmiGrovesUseCase: sl<GetRecommendedImmiGrovesUseCase>(),
        joinImmiGroveUseCase: sl<JoinImmiGroveUseCase>(),
        leaveImmiGroveUseCase: sl<LeaveImmiGroveUseCase>(),
        getJoinedImmiGrovesUseCase: sl<GetJoinedImmiGrovesUseCase>(),
        saveSelectedImmiGrovesUseCase: sl<SaveSelectedImmiGrovesUseCase>(),
      ),
    );
  }
}
