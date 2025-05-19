import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:immigru/new_core/network/interceptors/network_interceptor.dart';

/// Interceptor that logs network requests and responses
class LoggingInterceptor implements NetworkInterceptor {
  /// Creates a new logging interceptor
  LoggingInterceptor();

  @override
  Future<http.Request?> onRequest(http.Request request) async {
    return null; // Return null to use the original request
  }

  @override
  Future<http.Response?> onResponse(http.Response response) async {
    final statusCode = response.statusCode;

    if (kDebugMode) {
      if (statusCode >= 400) {
      } else {}
    }

    return null; // Return null to use the original response
  }

  @override
  Future<void> onError(Object error, StackTrace stackTrace) async {
    if (kDebugMode) {}
  }
}
