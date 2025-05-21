import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/core/logging/logger_interface.dart';

/// Logging module for dependency injection
/// Registers all logging-related dependencies
class LoggingModule {
  /// Register all logging dependencies
  static Future<void> register(GetIt sl) async {
    // Register the unified logger as a singleton
    sl.registerLazySingleton<UnifiedLogger>(() => UnifiedLogger());

    // Register the logger interface using the unified logger
    sl.registerLazySingleton<LoggerInterface>(() => sl<UnifiedLogger>());

    // Register feature-specific loggers as needed
    // Example: sl.registerFactory<LoggerInterface>(() => UnifiedLogger(), instanceName: 'feature_logger');

    // Initialize the unified logger
    final logger = sl<UnifiedLogger>();
    logger.setMinLogLevel(kDebugMode ? LogLevel.verbose : LogLevel.info);
  }
}
