import 'package:http/http.dart' as http;

/// Interface for network interceptors
/// Interceptors can modify requests, responses, and handle errors
abstract class NetworkInterceptor {
  /// Called before a request is sent
  /// Return a modified request or null to use the original request
  Future<http.Request?> onRequest(http.Request request) async {
    return null;
  }
  
  /// Called after a response is received
  /// Return a modified response or null to use the original response
  Future<http.Response?> onResponse(http.Response response) async {
    return null;
  }
  
  /// Called when an error occurs
  Future<void> onError(Object error, StackTrace stackTrace) async {}
}
