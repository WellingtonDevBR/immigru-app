/// Logger interface that defines the contract for all logger implementations
/// following the clean architecture principles.
abstract class LoggerInterface {
  /// Log a verbose message
  void v(String message, {String? tag, Object? error, StackTrace? stackTrace});
  
  /// Log a debug message
  void d(String message, {String? tag, Object? error, StackTrace? stackTrace});
  
  /// Log an info message
  void i(String message, {String? tag, Object? error, StackTrace? stackTrace});
  
  /// Log a warning message
  void w(String message, {String? tag, Object? error, StackTrace? stackTrace});
  
  /// Log an error message
  void e(String message, {String? tag, Object? error, StackTrace? stackTrace});
  
  /// Log a "what a terrible failure" message
  void wtf(String message, {String? tag, Object? error, StackTrace? stackTrace});
  
  /// Log a network-related message
  void network(String message, {LogLevel level = LogLevel.info, String? tag, Object? error, StackTrace? stackTrace});
  
  /// Log a structured event with parameters
  void logEvent(String eventName, {Map<String, dynamic>? parameters, LogLevel level = LogLevel.info});
  
  /// Set the minimum log level
  void setMinLogLevel(LogLevel level);
  
  /// Enable or disable logging
  void setLoggingEnabled(bool enabled);
  
  /// Configure remote logging capabilities
  void configureRemoteLogging({required bool enabled, String? endpoint});
  
  /// Set user context for logs
  void setUserId(String? userId);
  
  /// Add a global property that will be included in all logs
  void addGlobalProperty(String key, dynamic value);
}

/// Log level enum to categorize the severity of logs
enum LogLevel {
  verbose,
  debug,
  info,
  warning,
  error,
  wtf, // What a Terrible Failure
}
