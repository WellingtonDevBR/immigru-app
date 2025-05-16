import 'package:get_it/get_it.dart';
import 'package:immigru/core/logging/app_logger.dart';
import 'package:immigru/core/logging/edge_function_logger.dart';
import 'package:immigru/core/logging/logger_provider.dart';
import 'package:immigru/domain/interfaces/logger_interface.dart';

/// Dependency injection module for logging components
/// This module registers all logging-related dependencies
class LoggingModule {
  /// Register all logging dependencies
  static void register(GetIt sl) {
    // Register the logger provider as a singleton
    sl.registerLazySingleton<LoggerProvider>(() => LoggerProvider());
    
    // Initialize the logger provider
    final loggerProvider = sl<LoggerProvider>();
    loggerProvider.initialize(
      useStructuredLogging: false, // Set to true in production
      useRemoteLogging: false, // Set to true in production
    );
    
    // Register the main app logger
    sl.registerLazySingleton<AppLogger>(() => loggerProvider.getAppLogger());
    
    // Register the logger interface (for general use)
    sl.registerLazySingleton<LoggerInterface>(() => loggerProvider.getAppLogger());
    
    // Register the edge function logger
    sl.registerLazySingleton<EdgeFunctionLogger>(
      () => loggerProvider.createEdgeFunctionLogger(),
    );
    
    // Register feature-specific loggers as factories
    sl.registerFactory<LoggerInterface>(
      () => loggerProvider.createFeatureLogger('Auth'),
      instanceName: 'auth_logger',
    );
    
    sl.registerFactory<LoggerInterface>(
      () => loggerProvider.createFeatureLogger('Profile'),
      instanceName: 'profile_logger',
    );
    
    sl.registerFactory<LoggerInterface>(
      () => loggerProvider.createFeatureLogger('Onboarding'),
      instanceName: 'onboarding_logger',
    );
  }
}
