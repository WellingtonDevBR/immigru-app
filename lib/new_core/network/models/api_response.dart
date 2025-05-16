/// API response model that encapsulates the response from an API call
/// This class provides a clean way to handle both success and error responses
class ApiResponse<T> {
  /// Status code of the response
  final int statusCode;
  
  /// Data returned by the API
  final T? data;
  
  /// Error message if the request failed
  final String? message;
  
  /// Error object if the request failed
  final Object? error;
  
  /// Stack trace if the request failed
  final StackTrace? stackTrace;
  
  /// Headers returned by the API
  final Map<String, String>? headers;
  
  /// Whether the request was successful
  final bool isSuccess;

  /// Creates a success response
  ApiResponse.success({
    required this.statusCode,
    this.data,
    this.headers,
  })  : message = null,
        error = null,
        stackTrace = null,
        isSuccess = true;

  /// Creates an error response
  ApiResponse.error({
    required this.statusCode,
    required this.message,
    this.data,
    this.error,
    this.stackTrace,
    this.headers,
  }) : isSuccess = false;
  
  /// Creates a copy of this response with the given fields replaced
  ApiResponse<T> copyWith({
    int? statusCode,
    T? data,
    String? message,
    Object? error,
    StackTrace? stackTrace,
    Map<String, String>? headers,
    bool? isSuccess,
  }) {
    return isSuccess ?? this.isSuccess
        ? ApiResponse<T>.success(
            statusCode: statusCode ?? this.statusCode,
            data: data ?? this.data,
            headers: headers ?? this.headers,
          )
        : ApiResponse<T>.error(
            statusCode: statusCode ?? this.statusCode,
            message: message ?? this.message ?? '',
            data: data ?? this.data,
            error: error ?? this.error,
            stackTrace: stackTrace ?? this.stackTrace,
            headers: headers ?? this.headers,
          );
  }
}
