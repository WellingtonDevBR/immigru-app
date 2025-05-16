import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Client for interacting with Supabase Edge Functions
class EdgeFunctionClient {
  late final SupabaseClient _client;
  
  /// Creates a new edge function client
  EdgeFunctionClient() {
    _client = Supabase.instance.client;
  }
  
  /// Invoke an edge function with the given name and body
  Future<EdgeFunctionResponse<T>> invoke<T>(
    String functionName, {
    required Map<String, dynamic> body,
    Map<String, dynamic>? params,
    HttpMethod method = HttpMethod.post,
  }) async {
    try {
      // Log the request in debug mode
      if (kDebugMode) {
        print('🔄 Edge Function Request: $functionName');
        print('Body: $body');
        if (params != null) {
          print('Query Params: $params');
        }
        print('User ID: ${_client.auth.currentUser?.id}');
      }
      
      // Build the URL with query parameters if provided
      String url = functionName;
      if (params != null && params.isNotEmpty) {
        final queryString = params.entries
            .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
            .join('&');
        url = '$functionName?$queryString';
      }
      
      // Invoke the edge function
      final response = await _client.functions.invoke(
        url,
        body: body,
        method: method,
      );
      
      // Parse the response data
      final responseData = response.data;
      
      // Log the response in debug mode
      if (kDebugMode) {
        print('✅ Edge Function Response: $functionName');
        print('Data: $responseData');
      }
      
      // Check if the response contains an error
      if (responseData is Map<String, dynamic> && 
          responseData.containsKey('error') && 
          responseData['error'] != null) {
        return EdgeFunctionResponse<T>.error(
          message: responseData['error'].toString(),
          data: _convertToType<T>(responseData),
        );
      }
      
      // Return success response with proper type handling
      return EdgeFunctionResponse<T>.success(
        data: _convertToType<T>(responseData),
      );
    } catch (error, stackTrace) {
      // Log the error in debug mode
      if (kDebugMode) {
        print('❌ Edge Function Error: $functionName');
        print('Error: $error');
        print('Stack trace: $stackTrace');
      }
      
      // Return error response
      return EdgeFunctionResponse<T>.error(
        message: error.toString(),
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// Safely converts a dynamic value to the specified type T
  T? _convertToType<T>(dynamic value) {
    if (value == null) {
      return null;
    }
    
    // If the value is already of type T, return it
    if (value is T) {
      return value;
    }
    
    // Handle common type conversions
    if (identical(T, String)) {
      return value.toString() as T?;
    } else if (identical(T, Map) || T.toString() == 'Map<String, dynamic>') {
      if (value is Map) {
        return Map<String, dynamic>.from(value) as T?;
      }
    } else if (identical(T, List) || T.toString() == 'List<dynamic>') {
      if (value is List) {
        return value as T?;
      }
    } else if (identical(T, int)) {
      if (value is String) {
        return int.tryParse(value) as T?;
      } else if (value is num) {
        return value.toInt() as T?;
      }
    } else if (identical(T, double)) {
      if (value is String) {
        return double.tryParse(value) as T?;
      } else if (value is num) {
        return value.toDouble() as T?;
      }
    } else if (identical(T, bool)) {
      if (value is String) {
        return (value.toLowerCase() == 'true') as T?;
      } else if (value is num) {
        return (value != 0) as T?;
      }
    }
    
    // For complex types, try to use the value as is
    // This might fail at runtime if the types are incompatible
    try {
      return value as T?;
    } catch (e) {
      if (kDebugMode) {
        print('Type conversion error: Could not convert ${value.runtimeType} to $T');
      }
      return null;
    }
  }
}

/// Response from an edge function
class EdgeFunctionResponse<T> {
  /// Data returned by the edge function
  final T? data;
  
  /// Error message if the request failed
  final String? message;
  
  /// Error object if the request failed
  final Object? error;
  
  /// Stack trace if the request failed
  final StackTrace? stackTrace;
  
  /// Whether the request was successful
  final bool isSuccess;

  /// Creates a success response
  EdgeFunctionResponse.success({
    this.data,
  })  : message = null,
        error = null,
        stackTrace = null,
        isSuccess = true;

  /// Creates an error response
  EdgeFunctionResponse.error({
    required this.message,
    this.data,
    this.error,
    this.stackTrace,
  }) : isSuccess = false;
}
