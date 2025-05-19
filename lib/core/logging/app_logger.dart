import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:immigru/core/logging/base_logger.dart';
import 'package:immigru/domain/interfaces/logger_interface.dart';

/// Application logger that extends the base logger with additional functionality
/// such as structured logging and remote logging capabilities
class AppLogger extends BaseLogger {
  /// Singleton instance
  static final AppLogger _instance = AppLogger._internal();
  
  /// Factory constructor to return the singleton instance
  factory AppLogger() => _instance;
  
  /// Internal constructor
  AppLogger._internal();
  
  /// Whether to use structured logging format (JSON)
  bool _useStructuredLogging = false;
  
  /// Whether to send logs to a remote service
  bool _useRemoteLogging = false;
  
  /// Remote logging endpoint URL
  String? _remoteLoggingUrl;

  final bool _loggingEnabled = true;
  
  /// Minimum log level
  final LogLevel _minLogLevel = LogLevel.info;
  
  /// Enable structured logging (JSON format)
  void enableStructuredLogging(bool enabled) {
    _useStructuredLogging = enabled;
  }
  
  /// Configure remote logging
  void configureRemoteLogging({
    required bool enabled,
    String? endpoint,
  }) {
    _useRemoteLogging = enabled;
    _remoteLoggingUrl = endpoint;
  }
  
  @override
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
    
    final timestamp = DateTime.now().toIso8601String();
    
    if (_useStructuredLogging) {
      _logStructured(
        message: message,
        level: level,
        category: category,
        tag: tag,
        error: error,
        stackTrace: stackTrace,
        timestamp: timestamp,
      );
    } else {
      // Use standard logging from base class
      super.log(
        message,
        level: level,
        category: category,
        tag: tag,
        error: error,
        stackTrace: stackTrace,
      );
    }
    
    // Send to remote logging service if enabled
    if (_useRemoteLogging && _remoteLoggingUrl != null) {
      _sendToRemoteLogging(
        message: message,
        level: level,
        category: category,
        tag: tag,
        error: error,
        stackTrace: stackTrace,
        timestamp: timestamp,
      );
    }
  }
  
  /// Log in structured format (JSON)
  void _logStructured({
    required String message,
    required LogLevel level,
    required LogCategory category,
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    required String timestamp,
  }) {
    final Map<String, dynamic> logData = {
      'timestamp': timestamp,
      'level': level.toString().split('.').last,
      'category': category.toString().split('.').last,
      'message': message,
    };
    
    if (tag != null) {
      logData['tag'] = tag;
    }
    
    if (error != null) {
      logData['error'] = error.toString();
      if (stackTrace != null) {
        logData['stackTrace'] = stackTrace.toString();
      }
    }
    
    final jsonLog = jsonEncode(logData);
    debugPrint(jsonLog);
  }
  
  /// Send log to remote logging service
  Future<void> _sendToRemoteLogging({
    required String message,
    required LogLevel level,
    required LogCategory category,
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    required String timestamp,
  }) async {
    // In a real implementation, this would send the log data to a remote service
    // using HTTP or another transport mechanism.
    // For now, we'll just print a message indicating that we would send the log.
    if (kDebugMode) {
      print('Would send log to remote service: $_remoteLoggingUrl');
    }
  }
  
  /// Log with specific category
  void logWithCategory(
    String message,
    LogCategory category, {
    LogLevel level = LogLevel.info,
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(
      message,
      level: level,
      category: category,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// Log network related messages
  void network(String message, {LogLevel level = LogLevel.info, String? tag, Object? error, StackTrace? stackTrace}) {
    logWithCategory(message, LogCategory.network, level: level, tag: tag, error: error, stackTrace: stackTrace);
  }
  
  /// Log authentication related messages
  void auth(String message, {LogLevel level = LogLevel.info, String? tag, Object? error, StackTrace? stackTrace}) {
    logWithCategory(message, LogCategory.auth, level: level, tag: tag, error: error, stackTrace: stackTrace);
  }
  
  /// Log database related messages
  void database(String message, {LogLevel level = LogLevel.info, String? tag, Object? error, StackTrace? stackTrace}) {
    logWithCategory(message, LogCategory.database, level: level, tag: tag, error: error, stackTrace: stackTrace);
  }
  
  /// Log UI related messages
  void ui(String message, {LogLevel level = LogLevel.info, String? tag, Object? error, StackTrace? stackTrace}) {
    logWithCategory(message, LogCategory.ui, level: level, tag: tag, error: error, stackTrace: stackTrace);
  }
  
  /// Log navigation related messages
  void navigation(String message, {LogLevel level = LogLevel.info, String? tag, Object? error, StackTrace? stackTrace}) {
    logWithCategory(message, LogCategory.navigation, level: level, tag: tag, error: error, stackTrace: stackTrace);
  }
  
  /// Log performance related messages
  void performance(String message, {LogLevel level = LogLevel.info, String? tag, Object? error, StackTrace? stackTrace}) {
    logWithCategory(message, LogCategory.performance, level: level, tag: tag, error: error, stackTrace: stackTrace);
  }
}
