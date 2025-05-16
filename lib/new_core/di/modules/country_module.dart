import 'package:get_it/get_it.dart';
import 'package:immigru/core/services/logger_service.dart';
import 'package:immigru/data/datasources/supabase_data_source.dart';
import 'package:immigru/data/repositories/country_repository_impl.dart';
import 'package:immigru/domain/repositories/country_repository.dart';
import 'package:immigru/domain/usecases/country_usecases.dart';
import 'package:immigru/new_core/country/data/repositories/country_repository_impl.dart' as new_arch;
import 'package:immigru/new_core/country/domain/repositories/country_repository.dart';
import 'package:immigru/new_core/country/domain/usecases/get_countries_usecase.dart' as new_arch;
import 'package:immigru/new_core/logging/logger_provider.dart';
import 'package:immigru/new_core/network/edge_function_client.dart';
import 'package:immigru/shared/interfaces/logger_interface.dart';

/// Country module for dependency injection
/// Registers all country-related dependencies
class CountryModule {
  /// Register all country dependencies
  static Future<void> register(GetIt sl) async {
    // Register feature-specific logger
    if (!sl.isRegistered<LoggerInterface>(instanceName: 'country_logger')) {
      sl.registerFactory<LoggerInterface>(
        () => sl<LoggerProvider>().createFeatureLogger('Country'),
        instanceName: 'country_logger',
      );
    }
    
    // Register new architecture repository
    if (!sl.isRegistered<CountryFeatureRepository>()) {
      sl.registerLazySingleton<CountryFeatureRepository>(
        () => new_arch.CountryRepositoryImpl(
          sl<EdgeFunctionClient>(),
          sl<LoggerInterface>(instanceName: 'country_logger'),
        ),
      );
    }
    
    // Register new architecture use cases
    if (!sl.isRegistered<new_arch.GetCountriesUseCase>()) {
      sl.registerLazySingleton<new_arch.GetCountriesUseCase>(
        () => new_arch.GetCountriesUseCase(
          sl<CountryFeatureRepository>(),
        ),
      );
    }
    
    // For backward compatibility, register old architecture components
    // Register country repository if not already registered
    if (!sl.isRegistered<CountryRepository>()) {
      sl.registerLazySingleton<CountryRepository>(
        () => CountryRepositoryImpl(
          dataSource: sl<SupabaseDataSource>(),
          logger: sl<LoggerService>(),
        ),
      );
    }

    // Register country use cases for backward compatibility
    if (!sl.isRegistered<GetCountriesUseCase>()) {
      sl.registerLazySingleton<GetCountriesUseCase>(
        () => GetCountriesUseCase(sl<CountryRepository>()),
      );
    }
  }
}
