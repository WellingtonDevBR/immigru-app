import 'package:flutter/foundation.dart';
import 'package:immigru/core/logging/logger_interface.dart';

/// A unified logger implementation for the Immigru app
/// This is the single logging solution for the entire application
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
    _log(LogLevel.verbose, message,
        tag: tag, error: error, stackTrace: stackTrace);
  }

  @override
  void d(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message,
        tag: tag, error: error, stackTrace: stackTrace);
  }

  @override
  void i(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  @override
  void w(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message,
        tag: tag, error: error, stackTrace: stackTrace);
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
  void network(String message,
      {LogLevel level = LogLevel.info,
      String? tag,
      Object? error,
      StackTrace? stackTrace}) {
    _log(level, message, tag: tag ?? 'NETWORK', error: error, stackTrace: stackTrace);
  }

  @override
  void logEvent(String eventName,
      {Map<String, dynamic>? parameters, LogLevel level = LogLevel.info}) {
    final message =
        'EVENT: $eventName ${parameters != null ? parameters.toString() : ''}';
    _log(level, message, tag: 'EVENT');
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
    // This method is a placeholder for future remote logging configuration
    // When you're ready to implement remote logging, you can add the implementation here
    if (kDebugMode) {
      print('Remote logging configuration: enabled=$enabled, endpoint=$endpoint');
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
  void _log(LogLevel level, String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    if (!_loggingEnabled || level.index < _minLogLevel.index) {
      return;
    }

    final timestamp = DateTime.now().toIso8601String();
    final logTag = tag != null ? '[$tag]' : '';
    final userId = _userId != null ? '[User:$_userId]' : '';

    // Format the log message
    final formattedMessage =
        '$timestamp[${level.toString().split('.').last.toUpperCase()}]$userId$logTag $message';

    // Print to console
    if (error != null) {
      debugPrint('$formattedMessage\nERROR: $error');
    } else {
      debugPrint(formattedMessage);
    }

    if (stackTrace != null) {
      debugPrint('STACK TRACE:\n$stackTrace');
    }

    // In the future, this is where you would send logs to a remote service
    // Example:
    // _sendToRemoteService(level, message, tag, error, stackTrace);
  }
}
