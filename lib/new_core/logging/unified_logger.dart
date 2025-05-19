import 'package:flutter/foundation.dart';
import 'package:immigru/new_core/logging/logger_interface.dart';

/// A minimal unified logger implementation for the Immigru app
class UnifiedLogger implements LoggerInterface {
  /// Singleton instance
  static final UnifiedLogger _instance = UnifiedLogger._internal();
  
  /// Factory constructor to return the singleton instance
  factory UnifiedLogger() => _instance;
  
  /// Internal constructor
  UnifiedLogger._internal();
  
  /// Current minimum log level to display
  LogLevel _minLogLevel = kDebugMode ? LogLevel.verbose : LogLevel.info;
  
  /// Enable or disable logging completely
  bool _loggingEnabled = true;
  
  /// User ID for tracking logs
  String? _userId;
  
  /// Global properties for all logs
  final Map<String, dynamic> _globalProperties = {};

  @override
  void v(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.verbose, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  @override
  void d(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  @override
  void i(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  @override
  void w(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  @override
  void e(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  @override
  void wtf(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.wtf, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  @override
  void network(String message, {LogLevel level = LogLevel.info, String? tag, Object? error, StackTrace? stackTrace}) {
    _log(level, message, tag: tag ?? 'Network', error: error, stackTrace: stackTrace);
  }

  @override
  void logEvent(String eventName, {Map<String, dynamic>? parameters, LogLevel level = LogLevel.info}) {
    final message = 'Event: $eventName${parameters != null ? ' - Parameters: $parameters' : ''}';
    _log(level, message, tag: 'Analytics');
  }

  @override
  void setMinLogLevel(LogLevel level) {
    _minLogLevel = level;
  }

  @override
  void setLoggingEnabled(bool enabled) {
    _loggingEnabled = enabled;
  }

  @override
  void configureRemoteLogging({required bool enabled, String? endpoint}) {
    // Simple implementation - just print configuration
    if (kDebugMode) {
      print('Remote logging configured: enabled=$enabled, endpoint=$endpoint');
    }
  }

  @override
  void setUserId(String? userId) {
    _userId = userId;
  }

  @override
  void addGlobalProperty(String key, dynamic value) {
    _globalProperties[key] = value;
  }

  /// Internal logging method
  void _log(LogLevel level, String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (!_loggingEnabled || level.index < _minLogLevel.index) {
      return;
    }

    final logTag = tag != null ? '[$tag]' : '';
    final userContext = _userId != null ? '[User:$_userId]' : '';
    final timestamp = DateTime.now().toString();
    final levelStr = _getLevelString(level);
    
    final logMessage = '[$timestamp]$levelStr$logTag$userContext $message';
    
    if (error != null) {
      if (kDebugMode) {
        print('$logMessage\nError: $error${stackTrace != null ? '\n$stackTrace' : ''}');
      }
    } else {
      if (kDebugMode) {
        print(logMessage);
      }
    }
  }

  /// Get string representation of log level
  String _getLevelString(LogLevel level) {
    switch (level) {
      case LogLevel.verbose:
        return '[V]';
      case LogLevel.debug:
        return '[D]';
      case LogLevel.info:
        return '[I]';
      case LogLevel.warning:
        return '[W]';
      case LogLevel.error:
        return '[E]';
      case LogLevel.wtf:
        return '[WTF]';
    }
  }
}
