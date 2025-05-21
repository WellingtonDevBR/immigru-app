import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/core/logging/logger_interface.dart';

/// Simple provider for logger instances
class LoggerProvider {
  /// Singleton instance
  static final LoggerProvider _instance = LoggerProvider._internal();

  /// Factory constructor to return the singleton instance
  factory LoggerProvider() => _instance;

  /// Internal constructor
  LoggerProvider._internal();

  /// The unified logger instance
  final UnifiedLogger _logger = UnifiedLogger();

  /// Get the default logger
  LoggerInterface getLogger() => _logger;

  /// Create a logger with a specific tag for a feature
  LoggerInterface createFeatureLogger(String featureName) {
    return _TaggedLogger(_logger, featureName);
  }
}

/// A logger that adds a tag to all log messages
class _TaggedLogger implements LoggerInterface {
  final LoggerInterface _logger;
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
  void wtf(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    _logger.wtf(message,
        tag: tag ?? _tag, error: error, stackTrace: stackTrace);
  }

  @override
  void network(String message,
      {LogLevel level = LogLevel.info,
      String? tag,
      Object? error,
      StackTrace? stackTrace}) {
    _logger.network(message,
        level: level, tag: tag ?? _tag, error: error, stackTrace: stackTrace);
  }

  @override
  void logEvent(String eventName,
      {Map<String, dynamic>? parameters, LogLevel level = LogLevel.info}) {
    _logger.logEvent(eventName, parameters: parameters, level: level);
  }

  @override
  void setMinLogLevel(LogLevel level) {
    _logger.setMinLogLevel(level);
  }

  @override
  void setLoggingEnabled(bool enabled) {
    _logger.setLoggingEnabled(enabled);
  }

  @override
  void configureRemoteLogging({required bool enabled, String? endpoint}) {
    _logger.configureRemoteLogging(enabled: enabled, endpoint: endpoint);
  }

  @override
  void setUserId(String? userId) {
    _logger.setUserId(userId);
  }

  @override
  void addGlobalProperty(String key, dynamic value) {
    _logger.addGlobalProperty(key, value);
  }
}
