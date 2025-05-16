import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:immigru/core/services/logger_service.dart' as old_logger;
import 'package:immigru/new_core/logging/app_logger.dart';
import 'package:immigru/new_core/logging/edge_function_logger.dart';
import 'package:immigru/new_core/logging/logger_provider.dart';
import 'package:immigru/shared/interfaces/logger_interface.dart';

/// Logging module for dependency injection
/// Registers all logging-related dependencies
class LoggingModule {
  /// Register all logging dependencies
  static Future<void> register(GetIt sl) async {
    // Register the logger provider as a singleton
    sl.registerLazySingleton<LoggerProvider>(() => LoggerProvider());
    
    // Initialize the logger provider
    final loggerProvider = sl<LoggerProvider>();
    loggerProvider.initialize(
      useStructuredLogging: kDebugMode ? false : true,
      useRemoteLogging: kDebugMode ? false : true,
      minLogLevel: kDebugMode ? LogLevel.verbose : LogLevel.info,
    );
    
    // Register the main app logger
    sl.registerLazySingleton<AppLogger>(() => loggerProvider.getAppLogger());
    
    // Register the logger interface (for general use)
    sl.registerLazySingleton<LoggerInterface>(() => loggerProvider.getAppLogger());
    
    // Register the edge function logger
    sl.registerLazySingleton<EdgeFunctionLogger>(
      () => loggerProvider.createEdgeFunctionLogger(),
    );
    
    // Register LoggerService for backward compatibility with old architecture
    sl.registerLazySingleton<old_logger.LoggerService>(() => old_logger.LoggerService());
    
    // Register feature-specific loggers as factories
    _registerFeatureLoggers(sl, loggerProvider);
  }
  
  /// Register feature-specific loggers
  static void _registerFeatureLoggers(GetIt sl, LoggerProvider provider) {
    // Auth feature logger
    sl.registerFactory<LoggerInterface>(
      () => provider.createFeatureLogger('Auth'),
      instanceName: 'auth_logger',
    );
    
    // Onboarding feature logger
    sl.registerFactory<LoggerInterface>(
      () => provider.createFeatureLogger('Onboarding'),
      instanceName: 'onboarding_logger',
    );
    
    // Profile feature logger
    sl.registerFactory<LoggerInterface>(
      () => provider.createFeatureLogger('Profile'),
      instanceName: 'profile_logger',
    );
  }
}
