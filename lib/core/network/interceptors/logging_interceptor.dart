import 'package:http/http.dart' as http;
import 'package:immigru/core/network/interceptors/network_interceptor.dart';
import 'package:immigru/core/logging/unified_logger.dart';

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
    final url = response.request?.url.toString() ?? 'unknown';

    if (statusCode >= 400) {
      final logger = UnifiedLogger();
      logger.e(
        'HTTP Response: $statusCode from $url',
        tag: 'Network',
        error: response.body,
      );
    } else {
      final logger = UnifiedLogger();
      logger.d(
        'HTTP Response: $statusCode from $url',
        tag: 'Network',
      );
    }

    return null; // Return null to use the original response
  }

  @override
  Future<void> onError(Object error, StackTrace stackTrace) async {
    final logger = UnifiedLogger();
    logger.e(
      'Network Error',
      tag: 'Network',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
