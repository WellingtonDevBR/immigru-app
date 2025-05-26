import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:retry/retry.dart';

/// A service for optimizing network operations
///
/// This service provides:
/// 1. Batch operations for related data
/// 2. Retry mechanisms for network operations
/// 3. Parallel upload capabilities for media files
/// 4. Network connectivity monitoring
class NetworkOptimizer {
  static final NetworkOptimizer _instance = NetworkOptimizer._internal();
  
  /// Singleton instance
  factory NetworkOptimizer() => _instance;
  
  NetworkOptimizer._internal();
  
  final UnifiedLogger _logger = UnifiedLogger();
  final Dio _dio = Dio();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _connectivitySubscription;
  bool _isConnected = true;
  
  /// Initialize the network optimizer
  Future<void> init() async {
    // Setup connectivity monitoring
    final connectivityResult = await _connectivity.checkConnectivity();
    _isConnected = connectivityResult != ConnectivityResult.none;
    
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
      final wasConnected = _isConnected;
      _isConnected = result != ConnectivityResult.none;
      
      if (!wasConnected && _isConnected) {
        _logger.i('Network connection restored', tag: 'NetworkOptimizer');
        // Process any pending operations when connection is restored
        _processPendingOperations();
      } else if (wasConnected && !_isConnected) {
        _logger.w('Network connection lost', tag: 'NetworkOptimizer');
      }
    });
    
    // Configure Dio
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.options.sendTimeout = const Duration(seconds: 15);
    
    // Add interceptors for logging and retrying
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (log) => _logger.d(log.toString(), tag: 'NetworkOptimizer'),
    ));
    
    _logger.d('Network optimizer initialized', tag: 'NetworkOptimizer');
  }
  
  /// Check if the device is connected to the network
  bool get isConnected => _isConnected;
  
  /// Process any pending operations when connection is restored
  void _processPendingOperations() {
    // This would be implemented to retry failed operations
    // For now, just log that we're ready to process pending operations
    _logger.d('Ready to process pending operations', tag: 'NetworkOptimizer');
  }
  
  /// Execute a network request with retry capability for Dio Response objects
  ///
  /// This method will retry the request if it fails due to network issues
  Future<Response<T>> executeWithRetryDio<T>(
    Future<Response<T>> Function() request, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    if (!_isConnected) {
      throw Exception('No network connection available');
    }
    
    try {
      return await retry(
        () => request(),
        retryIf: (e) => _shouldRetry(e),
        maxAttempts: maxRetries,
        delayFactor: retryDelay,
      );
    } catch (e) {
      _logger.e('Request failed after $maxRetries retries: $e', tag: 'NetworkOptimizer');
      rethrow;
    }
  }
  
  /// Execute any operation with retry capability
  ///
  /// This method will retry the operation if it fails due to network issues
  /// It works with any Future type, not just Dio Response objects
  Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    if (!_isConnected) {
      throw Exception('No network connection available');
    }
    
    try {
      return await retry(
        () => operation(),
        retryIf: (e) => _shouldRetry(e),
        maxAttempts: maxRetries,
        delayFactor: retryDelay,
      );
    } catch (e) {
      _logger.e('Operation failed after $maxRetries retries: $e', tag: 'NetworkOptimizer');
      rethrow;
    }
  }
  
  /// Determine if a request should be retried based on the error
  bool _shouldRetry(Exception e) {
    if (e is DioException) {
      // Retry on timeout, network errors, or server errors (5xx)
      return e.type == DioExceptionType.connectionTimeout ||
             e.type == DioExceptionType.receiveTimeout ||
             e.type == DioExceptionType.sendTimeout ||
             e.type == DioExceptionType.connectionError ||
             (e.response != null && e.response!.statusCode != null && e.response!.statusCode! >= 500);
    }
    
    if (e is SocketException || e is TimeoutException) {
      return true;
    }
    
    return false;
  }
  
  /// Upload multiple media files in parallel
  ///
  /// This method uploads multiple files in parallel and returns the URLs of the uploaded files
  Future<List<String>> uploadMediaInParallel(
    List<File> files,
    String uploadUrl,
    Map<String, dynamic> metadata, {
    int maxConcurrent = 3,
    void Function(int, int)? onProgress,
  }) async {
    if (!_isConnected) {
      throw Exception('No network connection available');
    }
    
    if (files.isEmpty) {
      return [];
    }
    
    _logger.d('Uploading ${files.length} files in parallel', tag: 'NetworkOptimizer');
    
    // Split files into chunks to limit concurrent uploads
    final chunks = <List<File>>[];
    for (var i = 0; i < files.length; i += maxConcurrent) {
      chunks.add(
        files.sublist(i, i + maxConcurrent > files.length ? files.length : i + maxConcurrent),
      );
    }
    
    final uploadedUrls = <String>[];
    
    for (final chunk in chunks) {
      final results = await Future.wait(
        chunk.map((file) => _uploadSingleFile(file, uploadUrl, metadata, onProgress)),
      );
      
      uploadedUrls.addAll(results);
    }
    
    _logger.d('Successfully uploaded ${uploadedUrls.length} files', tag: 'NetworkOptimizer');
    return uploadedUrls;
  }
  
  /// Upload a single file with retry capability
  Future<String> _uploadSingleFile(
    File file,
    String uploadUrl,
    Map<String, dynamic> metadata,
    void Function(int, int)? onProgress,
  ) async {
    final fileName = file.path.split('/').last;
    
    try {
      final formData = FormData.fromMap({
        ...metadata,
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });
      
      final response = await executeWithRetry(
        () => _dio.post(
          uploadUrl,
          data: formData,
          onSendProgress: onProgress,
        ),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        if (responseData != null && responseData['url'] != null) {
          return responseData['url'];
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Upload failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error uploading file $fileName: $e', tag: 'NetworkOptimizer');
      rethrow;
    }
  }
  
  /// Execute batch operations for related data
  ///
  /// This method executes multiple related requests as a batch to reduce network overhead
  Future<List<Response>> executeBatch(
    List<Future<Response> Function()> requests, {
    bool stopOnError = false,
  }) async {
    if (!_isConnected) {
      throw Exception('No network connection available');
    }
    
    if (requests.isEmpty) {
      return [];
    }
    
    _logger.d('Executing batch of ${requests.length} requests', tag: 'NetworkOptimizer');
    
    final responses = <Response>[];
    
    for (final request in requests) {
      try {
        final response = await executeWithRetry(request);
        responses.add(response);
      } catch (e) {
        _logger.e('Error in batch request: $e', tag: 'NetworkOptimizer');
        if (stopOnError) {
          throw e;
        }
      }
    }
    
    _logger.d('Completed batch of ${requests.length} requests', tag: 'NetworkOptimizer');
    return responses;
  }
  
  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _logger.d('Network optimizer disposed', tag: 'NetworkOptimizer');
  }
}
