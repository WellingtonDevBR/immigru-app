import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:immigru/new_core/network/interceptors/network_interceptor.dart';

/// Interceptor that logs network requests and responses
class LoggingInterceptor implements NetworkInterceptor {
  /// Creates a new logging interceptor
  LoggingInterceptor();
  
  @override
  Future<http.Request?> onRequest(http.Request request) async {
    final method = request.method;
    final url = request.url.toString();
    final headers = request.headers;
    
    if (kDebugMode) {



    }
    
    return null; // Return null to use the original request
  }
  
  @override
  Future<http.Response?> onResponse(http.Response response) async {
    final statusCode = response.statusCode;
    final url = response.request?.url.toString() ?? 'unknown';
    final headers = response.headers;
    
    if (kDebugMode) {
      if (statusCode >= 400) {

      } else {

      }


    }
    
    return null; // Return null to use the original response
  }
  
  @override
  Future<void> onError(Object error, StackTrace stackTrace) async {
    if (kDebugMode) {


    }
  }
  
  /// Sanitize headers to remove sensitive information
  Map<String, String> _sanitizeHeaders(Map<String, String> headers) {
    final sanitized = Map<String, String>.from(headers);
    
    // Remove sensitive headers
    final sensitiveHeaders = [
      'authorization',
      'cookie',
      'set-cookie',
      'apikey',
      'api-key',
      'x-api-key',
    ];
    
    for (final header in sensitiveHeaders) {
      if (sanitized.containsKey(header)) {
        sanitized[header] = '***REDACTED***';
      }
    }
    
    return sanitized;
  }
  
  /// Truncate body to a reasonable length
  String _truncateBody(String body) {
    if (body.isEmpty) {
      return '';
    }
    
    if (body.length > 1000) {
      return '${body.substring(0, 1000)}... [truncated]';
    }
    
    return body;
  }
}
