import 'dart:convert';
import 'package:immigru/new_core/logging/app_logger.dart';
import 'package:immigru/shared/interfaces/logger_interface.dart';

/// Specialized logger for edge function calls
/// This logger provides specialized logging for Supabase Edge Function calls
class EdgeFunctionLogger {
  final AppLogger _logger;
  
  /// Constructor that takes a logger instance
  EdgeFunctionLogger(this._logger);
  
  /// Log an edge function request
  void logRequest({
    required String functionName,
    required Map<String, dynamic> requestBody,
    String? userId,
  }) {
    final sanitizedBody = _sanitizeRequestBody(requestBody);
    final logMessage = 'Edge Function Request: $functionName';
    
    _logger.network(
      logMessage,
      level: LogLevel.info,
      tag: 'EdgeFunction',
      error: {
        'functionName': functionName,
        'requestBody': sanitizedBody,
        'userId': userId,
      },
    );
  }
  
  /// Log an edge function response
  void logResponse({
    required String functionName,
    required dynamic responseData,
    Object? error,
  }) {
    if (error != null) {
      _logger.network(
        'Edge Function Error: $functionName',
        level: LogLevel.error,
        tag: 'EdgeFunction',
        error: error,
      );
      return;
    }
    
    final sanitizedResponse = _sanitizeResponseData(responseData);
    final logMessage = 'Edge Function Response: $functionName';
    
    _logger.network(
      logMessage,
      level: LogLevel.info,
      tag: 'EdgeFunction',
      error: {
        'functionName': functionName,
        'responseData': sanitizedResponse,
      },
    );
  }
  
  /// Sanitize request body to remove sensitive information
  Map<String, dynamic> _sanitizeRequestBody(Map<String, dynamic> body) {
    final sanitized = Map<String, dynamic>.from(body);
    
    // Remove sensitive fields
    final sensitiveFields = ['password', 'token', 'secret', 'apiKey', 'api_key'];
    for (final field in sensitiveFields) {
      if (sanitized.containsKey(field)) {
        sanitized[field] = '***REDACTED***';
      }
    }
    
    return sanitized;
  }
  
  /// Sanitize response data to make it more readable and remove sensitive information
  dynamic _sanitizeResponseData(dynamic responseData) {
    if (responseData == null) {
      return null;
    }
    
    if (responseData is Map) {
      final sanitized = Map<String, dynamic>.from(responseData as Map<String, dynamic>);
      
      // Remove sensitive fields
      final sensitiveFields = ['password', 'token', 'secret', 'apiKey', 'api_key'];
      for (final field in sensitiveFields) {
        if (sanitized.containsKey(field)) {
          sanitized[field] = '***REDACTED***';
        }
      }
      
      // Truncate large data fields
      sanitized.forEach((key, value) {
        if (value is String && value.length > 500) {
          sanitized[key] = '${value.substring(0, 500)}... [truncated]';
        } else if (value is List && value.length > 20) {
          sanitized[key] = '[${value.length} items]';
        }
      });
      
      return sanitized;
    }
    
    if (responseData is String && responseData.length > 1000) {
      return '${responseData.substring(0, 1000)}... [truncated]';
    }
    
    return responseData;
  }
  
  /// Log an edge function error with detailed information
  void logError({
    required String functionName,
    required Object error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    final contextStr = context != null ? jsonEncode(context) : '';
    final logMessage = 'Edge Function Error: $functionName - $error $contextStr';
    
    _logger.network(
      logMessage,
      level: LogLevel.error,
      tag: 'EdgeFunction',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
