import 'package:get_it/get_it.dart';
import 'package:immigru/core/country/data/repositories/country_repository_impl.dart';
import 'package:immigru/core/country/domain/repositories/country_repository.dart';
import 'package:immigru/core/country/domain/usecases/get_countries_usecase.dart';
import 'package:immigru/core/logging/logger_provider.dart';
import 'package:immigru/core/network/edge_function_client.dart';
import 'package:immigru/core/logging/logger_interface.dart';

/// Country module for dependency injection
/// Registers all country feature dependencies
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
    
    // Register repository
    if (!sl.isRegistered<CountryFeatureRepository>()) {
      sl.registerLazySingleton<CountryFeatureRepository>(
        () => CountryRepositoryImpl(
          sl<EdgeFunctionClient>(),
          sl<LoggerInterface>(instanceName: 'country_logger'),
        ),
      );
    }
    
    // Register use cases
    if (!sl.isRegistered<GetCountriesUseCase>()) {
      sl.registerLazySingleton<GetCountriesUseCase>(
        () => GetCountriesUseCase(
          sl<CountryFeatureRepository>(),
        ),
      );
    }
  }
}
