import 'package:get_it/get_it.dart';
import 'package:immigru/core/logging/logger_interface.dart';

/// Utility class for easy access to logging functionality throughout the application
/// This provides a centralized way to log messages without having to inject the logger
class LogUtil {
  /// Get the logger instance from the service locator
  static LoggerInterface get logger => GetIt.instance<LoggerInterface>();

  /// Log a verbose message
  static void v(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    logger.v(message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Log a debug message
  static void d(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    logger.d(message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Log an info message
  static void i(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    logger.i(message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Log a warning message
  static void w(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    logger.w(message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Log an error message
  static void e(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    logger.e(message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Log a "what a terrible failure" message
  static void wtf(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    logger.wtf(message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Log a network-related message
  static void network(String message,
      {LogLevel level = LogLevel.info,
      String? tag,
      Object? error,
      StackTrace? stackTrace}) {
    logger.network(message,
        level: level, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Log a structured event with parameters
  static void logEvent(String eventName,
      {Map<String, dynamic>? parameters, LogLevel level = LogLevel.info}) {
    logger.logEvent(eventName, parameters: parameters, level: level);
  }
}
