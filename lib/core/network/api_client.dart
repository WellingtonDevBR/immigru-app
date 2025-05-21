import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:immigru/core/network/interceptors/network_interceptor.dart';
import 'package:immigru/core/network/models/api_response.dart';
import 'package:immigru/core/network/models/request_options.dart';

/// API client for making HTTP requests
/// This class provides a clean interface for making HTTP requests
/// and handles common functionality like interceptors, error handling, etc.
class ApiClient {
  final http.Client _client;
  final List<NetworkInterceptor> _interceptors;

  /// Creates a new API client with the given interceptors
  ApiClient({
    http.Client? client,
    List<NetworkInterceptor>? interceptors,
  })  : _client = client ?? http.Client(),
        _interceptors = interceptors ?? [];

  /// Add an interceptor to the client
  void addInterceptor(NetworkInterceptor interceptor) {
    _interceptors.add(interceptor);
  }

  /// Make a GET request to the given URL
  Future<ApiResponse<T>> get<T>(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    RequestOptions? options,
  }) async {
    var request = http.Request('GET', Uri.parse(url));

    if (headers != null) {
      request.headers.addAll(headers);
    }

    if (queryParameters != null) {
      final uri = Uri.parse(url).replace(queryParameters: queryParameters);
      // Create a new request with the updated URI
      final newRequest = http.Request(request.method, uri);
      newRequest.headers.addAll(request.headers);
      newRequest.body = request.body;
      request = newRequest;
    }

    return _executeRequest<T>(request, options);
  }

  /// Make a POST request to the given URL
  Future<ApiResponse<T>> post<T>(
    String url, {
    Map<String, String>? headers,
    dynamic body,
    RequestOptions? options,
  }) async {
    final request = http.Request('POST', Uri.parse(url));

    if (headers != null) {
      request.headers.addAll(headers);
    }

    if (body != null) {
      if (body is String) {
        request.body = body;
      } else {
        request.body = jsonEncode(body);
        request.headers['Content-Type'] = 'application/json';
      }
    }

    return _executeRequest<T>(request, options);
  }

  /// Make a PUT request to the given URL
  Future<ApiResponse<T>> put<T>(
    String url, {
    Map<String, String>? headers,
    dynamic body,
    RequestOptions? options,
  }) async {
    final request = http.Request('PUT', Uri.parse(url));

    if (headers != null) {
      request.headers.addAll(headers);
    }

    if (body != null) {
      if (body is String) {
        request.body = body;
      } else {
        request.body = jsonEncode(body);
        request.headers['Content-Type'] = 'application/json';
      }
    }

    return _executeRequest<T>(request, options);
  }

  /// Make a DELETE request to the given URL
  Future<ApiResponse<T>> delete<T>(
    String url, {
    Map<String, String>? headers,
    dynamic body,
    RequestOptions? options,
  }) async {
    final request = http.Request('DELETE', Uri.parse(url));

    if (headers != null) {
      request.headers.addAll(headers);
    }

    if (body != null) {
      if (body is String) {
        request.body = body;
      } else {
        request.body = jsonEncode(body);
        request.headers['Content-Type'] = 'application/json';
      }
    }

    return _executeRequest<T>(request, options);
  }

  /// Execute the given request with interceptors
  Future<ApiResponse<T>> _executeRequest<T>(
    http.Request request,
    RequestOptions? options,
  ) async {
    try {
      // Apply request interceptors
      for (final interceptor in _interceptors) {
        final interceptedRequest = await interceptor.onRequest(request);
        if (interceptedRequest != null) {
          request = interceptedRequest;
        }
      }

      // Execute the request
      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      // Apply response interceptors
      http.Response interceptedResponse = response;
      for (final interceptor in _interceptors) {
        final intercepted = await interceptor.onResponse(interceptedResponse);
        if (intercepted != null) {
          interceptedResponse = intercepted;
        }
      }

      // Parse the response
      final statusCode = interceptedResponse.statusCode;
      final responseBody = interceptedResponse.body;

      if (statusCode >= 200 && statusCode < 300) {
        // Success response
        return ApiResponse<T>.success(
          statusCode: statusCode,
          data: _parseResponseData<T>(responseBody),
          headers: interceptedResponse.headers,
        );
      } else {
        // Error response
        return ApiResponse<T>.error(
          statusCode: statusCode,
          message: 'Request failed with status: $statusCode',
          data: _parseResponseData<T>(responseBody),
          headers: interceptedResponse.headers,
        );
      }
    } catch (error, stackTrace) {
      // Apply error interceptors
      for (final interceptor in _interceptors) {
        await interceptor.onError(error, stackTrace);
      }

      // Return error response
      return ApiResponse<T>.error(
        statusCode: 0,
        message: error.toString(),
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Parse the response data based on the expected type
  T? _parseResponseData<T>(String responseBody) {
    if (responseBody.isEmpty) {
      return null;
    }

    try {
      final dynamic jsonData = jsonDecode(responseBody);

      if (T == String) {
        return responseBody as T;
      } else if (T == Map<String, dynamic>) {
        return jsonData as T;
      } else if (T == List<dynamic>) {
        return jsonData as T;
      } else if (T == bool) {
        return (jsonData as bool) as T;
      } else if (T == int) {
        return (jsonData as int) as T;
      } else if (T == double) {
        return (jsonData as double) as T;
      } else {
        return jsonData as T;
      }
    } catch (e) {
      return null;
    }
  }

  /// Close the client and release resources
  void close() {
    _client.close();
  }
}
