import 'package:flutter/foundation.dart';

/// Log level enum to categorize the severity of logs
enum LogLevel {
  verbose,
  debug,
  info,
  warning,
  error,
  wtf, // What a Terrible Failure
}

/// Log category enum to categorize the type of logs
enum LogCategory {
  auth,
  network,
  database,
  ui,
  navigation,
  performance,
  general,
}

/// A centralized logging service for the application
class LoggerService {
  /// Singleton instance
  static final LoggerService _instance = LoggerService._internal();
  
  /// Factory constructor to return the singleton instance
  factory LoggerService() => _instance;
  
  /// Internal constructor
  LoggerService._internal();
  
  /// Current minimum log level to display
  LogLevel _minLogLevel = kDebugMode ? LogLevel.info : LogLevel.warning;
  
  /// Enable or disable logging completely
  bool _loggingEnabled = true;
  
  /// Set the minimum log level
  void setMinLogLevel(LogLevel level) {
    _minLogLevel = level;
  }
  
  /// Enable or disable logging
  void setLoggingEnabled(bool enabled) {
    _loggingEnabled = enabled;
  }
  
  /// Log a message with the specified level and category
  void log(
    String message, {
    LogLevel level = LogLevel.info,
    LogCategory category = LogCategory.general,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_loggingEnabled || level.index < _minLogLevel.index) {
      return;
    }
  }
  
  /// Log a verbose message
  void v(String message, {LogCategory category = LogCategory.general, Object? error, StackTrace? stackTrace}) {
    log(message, level: LogLevel.verbose, category: category, error: error, stackTrace: stackTrace);
  }
  
  /// Log a debug message
  void d(String message, {LogCategory category = LogCategory.general, Object? error, StackTrace? stackTrace}) {
    log(message, level: LogLevel.debug, category: category, error: error, stackTrace: stackTrace);
  }
  
  /// Log a debug message with tag
  void debug(String tag, String message, {Object? error, StackTrace? stackTrace}) {
    log('[$tag] $message', level: LogLevel.debug, error: error, stackTrace: stackTrace);
  }
  
  /// Log an info message
  void i(String message, {LogCategory category = LogCategory.general, Object? error, StackTrace? stackTrace}) {
    log(message, level: LogLevel.info, category: category, error: error, stackTrace: stackTrace);
  }
  
  /// Log an info message with tag
  void info(String tag, String message, {Object? error, StackTrace? stackTrace}) {
    log('[$tag] $message', level: LogLevel.info, error: error, stackTrace: stackTrace);
  }
  
  /// Log a warning message
  void w(String message, {LogCategory category = LogCategory.general, Object? error, StackTrace? stackTrace}) {
    log(message, level: LogLevel.warning, category: category, error: error, stackTrace: stackTrace);
  }
  
  /// Log an error message
  void e(String message, {LogCategory category = LogCategory.general, Object? error, StackTrace? stackTrace}) {
    log(message, level: LogLevel.error, category: category, error: error, stackTrace: stackTrace);
  }
  
  /// Log an error message with tag
  void error(String tag, String message, {Object? error, StackTrace? stackTrace}) {
    log('[$tag] $message', level: LogLevel.error, error: error, stackTrace: stackTrace);
  }
  
  /// Log a "what a terrible failure" message
  void wtf(String message, {LogCategory category = LogCategory.general, Object? error, StackTrace? stackTrace}) {
    log(message, level: LogLevel.wtf, category: category, error: error, stackTrace: stackTrace);
  }
  
  /// Get emoji for the log level
  String _getLevelEmoji(LogLevel level) {
    switch (level) {
      case LogLevel.verbose:
        return '💬';
      case LogLevel.debug:
        return '🔍';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.wtf:
        return '💥';
    }
  }
}

/// Global logger instance for easy access
final logger = LoggerService();
