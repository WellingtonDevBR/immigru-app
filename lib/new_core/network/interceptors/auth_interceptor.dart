import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:immigru/new_core/network/interceptors/network_interceptor.dart';

/// Interceptor that adds authentication headers to requests
class AuthInterceptor implements NetworkInterceptor {
  /// Token provider function that returns the current authentication token
  final Future<String?> Function()? _tokenProvider;
  
  /// Creates a new authentication interceptor with the given token provider
  AuthInterceptor({Future<String?> Function()? tokenProvider}) 
      : _tokenProvider = tokenProvider;
  
  @override
  Future<http.Request?> onRequest(http.Request request) async {
    // Skip authentication for requests that don't need it
    if (_shouldSkipAuth(request)) {
      return null;
    }
    
    // Get the token from the provider
    final token = _tokenProvider != null ? await _tokenProvider!() : null;
    
    // Add the token to the request headers if available
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    
    return request;
  }
  
  @override
  Future<http.Response?> onResponse(http.Response response) async {
    // No modifications needed for responses
    return null;
  }
  
  @override
  Future<void> onError(Object error, StackTrace stackTrace) async {
    // Handle authentication errors if needed
    if (kDebugMode) {
      if (error.toString().contains('401') || 
          error.toString().contains('unauthorized')) {
        print('⚠️ Authentication error: $error');
      }
    }
  }
  
  /// Determine if authentication should be skipped for this request
  bool _shouldSkipAuth(http.Request request) {
    // Skip authentication for public endpoints
    final url = request.url.toString().toLowerCase();
    
    // Add your public endpoints here
    final publicEndpoints = [
      '/auth/login',
      '/auth/register',
      '/auth/forgot-password',
    ];
    
    for (final endpoint in publicEndpoints) {
      if (url.contains(endpoint)) {
        return true;
      }
    }
    
    // Check for custom header that indicates to skip authentication
    return request.headers.containsKey('X-Skip-Auth');
  }
}
