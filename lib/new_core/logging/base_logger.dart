import 'package:flutter/foundation.dart';
import 'package:immigru/shared/interfaces/logger_interface.dart';

/// Base logger implementation that provides common functionality for all loggers
class BaseLogger implements LoggerInterface {
  /// Current minimum log level to display
  LogLevel _minLogLevel = kDebugMode ? LogLevel.verbose : LogLevel.info;
  
  /// Enable or disable logging completely
  bool _loggingEnabled = true;
  
  /// Set the minimum log level
  @override
  void setMinLogLevel(LogLevel level) {
    _minLogLevel = level;
  }
  
  /// Enable or disable logging
  @override
  void setLoggingEnabled(bool enabled) {
    _loggingEnabled = enabled;
  }
  
  /// Check if logging is enabled
  bool isLoggingEnabled() {
    return _loggingEnabled;
  }
  
  /// Check if the given log level is enabled
  bool isLevelEnabled(LogLevel level) {
    return level.index >= _minLogLevel.index;
  }
  
  /// Log a message with the specified level and category
  void log(
    String message, {
    LogLevel level = LogLevel.info,
    LogCategory category = LogCategory.general,
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_loggingEnabled || level.index < _minLogLevel.index) {
      return;
    }
    
    final emoji = _getLevelEmoji(level);
    final categoryStr = '[${category.toString().split('.').last}]';
    final tagStr = tag != null ? '[$tag]' : '';
    final timestamp = DateTime.now().toIso8601String();
    
    final logMessage = '$emoji $timestamp $categoryStr $tagStr $message';
    
    // Use print for debug builds, but this could be replaced with a more sophisticated
    // logging mechanism in production builds
    debugPrint(logMessage);
    
    if (error != null) {
      debugPrint('Error: $error');
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }
  
  /// Log a verbose message
  @override
  void v(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    log(
      message,
      level: LogLevel.verbose,
      category: LogCategory.general,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// Log a debug message
  @override
  void d(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    log(
      message,
      level: LogLevel.debug,
      category: LogCategory.general,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// Log an info message
  @override
  void i(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    log(
      message,
      level: LogLevel.info,
      category: LogCategory.general,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// Log a warning message
  @override
  void w(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    log(
      message,
      level: LogLevel.warning,
      category: LogCategory.general,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// Log an error message
  @override
  void e(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    log(
      message,
      level: LogLevel.error,
      category: LogCategory.general,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// Log a "what a terrible failure" message
  @override
  void wtf(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    log(
      message,
      level: LogLevel.wtf,
      category: LogCategory.general,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
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
