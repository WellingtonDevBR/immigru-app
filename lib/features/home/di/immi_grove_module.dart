import 'package:get_it/get_it.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/features/home/data/datasources/immi_grove_data_source_impl.dart';
import 'package:immigru/features/home/data/repositories/immi_grove_repository_impl.dart';
import 'package:immigru/features/home/domain/repositories/immi_grove_repository.dart';
import 'package:immigru/features/home/domain/usecases/get_immi_groves_usecase.dart';
import 'package:immigru/features/home/domain/usecases/get_recommended_immi_groves_usecase.dart';
import 'package:immigru/features/home/domain/usecases/join_immi_grove_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Module for ImmiGrove-related dependencies
class ImmiGroveModule {
  /// Register all ImmiGrove-related dependencies
  static void register(GetIt locator) {
    // Data sources
    locator.registerLazySingleton<ImmiGroveDataSource>(
      () => ImmiGroveDataSourceImpl(
        supabase: Supabase.instance.client,
      ),
    );

    // Repositories
    locator.registerLazySingleton<ImmiGroveRepository>(
      () => ImmiGroveRepositoryImpl(
        immiGroveDataSource: locator<ImmiGroveDataSource>(),
        logger: locator<UnifiedLogger>(),
      ),
    );

    // Use cases
    locator.registerLazySingleton<GetImmiGrovesUseCase>(
      () => GetImmiGrovesUseCase(locator<ImmiGroveRepository>()),
    );

    locator.registerLazySingleton<GetRecommendedImmiGrovesUseCase>(
      () => GetRecommendedImmiGrovesUseCase(locator<ImmiGroveRepository>()),
    );

    locator.registerLazySingleton<JoinImmiGroveUseCase>(
      () => JoinImmiGroveUseCase(locator<ImmiGroveRepository>()),
    );
  }
}
