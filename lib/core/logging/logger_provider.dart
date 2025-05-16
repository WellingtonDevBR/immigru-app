import 'package:flutter/foundation.dart';
import 'package:immigru/core/logging/app_logger.dart';
import 'package:immigru/core/logging/edge_function_logger.dart';
import 'package:immigru/domain/interfaces/logger_interface.dart';

/// Provider class for creating and configuring different types of loggers
/// This follows the factory pattern to create appropriate logger instances
class LoggerProvider {
  /// The singleton instance
  static final LoggerProvider _instance = LoggerProvider._internal();
  
  /// Factory constructor to return the singleton instance
  factory LoggerProvider() => _instance;
  
  /// Internal constructor
  LoggerProvider._internal();
  
  /// The main application logger instance
  final AppLogger _appLogger = AppLogger();
  
  /// Initialize the logger with appropriate configuration
  void initialize({
    bool useStructuredLogging = false,
    bool useRemoteLogging = false,
    String? remoteLoggingEndpoint,
    LogLevel minLogLevel = LogLevel.info,
  }) {
    // Configure the app logger
    _appLogger.setMinLogLevel(kDebugMode ? LogLevel.verbose : minLogLevel);
    _appLogger.enableStructuredLogging(useStructuredLogging);
    _appLogger.configureRemoteLogging(
      enabled: useRemoteLogging,
      endpoint: remoteLoggingEndpoint,
    );
  }
  
  /// Get the main application logger
  AppLogger getAppLogger() => _appLogger;
  
  /// Create a new edge function logger
  EdgeFunctionLogger createEdgeFunctionLogger() {
    return EdgeFunctionLogger(_appLogger);
  }
  
  /// Create a category-specific logger that logs with a specific tag
  LoggerInterface createTaggedLogger(String tag) {
    return _TaggedLogger(_appLogger, tag);
  }
  
  /// Create a logger for a specific feature
  LoggerInterface createFeatureLogger(String featureName) {
    return _TaggedLogger(_appLogger, 'Feature:$featureName');
  }
  
  /// Create a logger for a specific class
  LoggerInterface createClassLogger(Type classType) {
    return _TaggedLogger(_appLogger, classType.toString());
  }
}

/// A logger that adds a specific tag to all log messages
class _TaggedLogger implements LoggerInterface {
  final AppLogger _logger;
  final String _tag;
  
  _TaggedLogger(this._logger, this._tag);
  
  @override
  void v(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _logger.v(message, tag: tag ?? _tag, error: error, stackTrace: stackTrace);
  }
  
  @override
  void d(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _logger.d(message, tag: tag ?? _tag, error: error, stackTrace: stackTrace);
  }
  
  @override
  void i(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _logger.i(message, tag: tag ?? _tag, error: error, stackTrace: stackTrace);
  }
  
  @override
  void w(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _logger.w(message, tag: tag ?? _tag, error: error, stackTrace: stackTrace);
  }
  
  @override
  void e(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _logger.e(message, tag: tag ?? _tag, error: error, stackTrace: stackTrace);
  }
  
  @override
  void wtf(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _logger.wtf(message, tag: tag ?? _tag, error: error, stackTrace: stackTrace);
  }
  
  @override
  void setMinLogLevel(LogLevel level) {
    _logger.setMinLogLevel(level);
  }
  
  @override
  void setLoggingEnabled(bool enabled) {
    _logger.setLoggingEnabled(enabled);
  }
}
