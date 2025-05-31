import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:immigru/core/config/environment_config.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:retry/retry.dart';
import 'package:path/path.dart' as path;

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
    String bucketName,
    String folderPath, {
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
        chunk.map((file) {
          final fileName = path.basename(file.path);
          final filePath = '$folderPath/$fileName';
          return uploadSingleFileToSupabase(file, bucketName, filePath, onProgress: onProgress);
        }),
      );
      
      uploadedUrls.addAll(results);
    }
    
    _logger.d('Successfully uploaded ${uploadedUrls.length} files', tag: 'NetworkOptimizer');
    return uploadedUrls;
  }
  
  /// Validates and ensures a media file has the correct content type
  /// 
  /// Returns a tuple with (isValid, mimeType, errorMessage)
  Future<(bool, String, String?)> validateMediaFile(File file) async {
    final fileExtension = path.extension(file.path).replaceAll('.', '').toLowerCase();
    
    // Map common image extensions to MIME types
    final validImageExtensions = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'webp': 'image/webp',
      'heic': 'image/heic',
    };
    
    final validVideoExtensions = {
      'mp4': 'video/mp4',
      'mov': 'video/quicktime',
      'avi': 'video/x-msvideo',
    };
    
    // Check if it's a valid image or video
    if (validImageExtensions.containsKey(fileExtension)) {
      return (true, validImageExtensions[fileExtension]!, null);
    } else if (validVideoExtensions.containsKey(fileExtension)) {
      return (true, validVideoExtensions[fileExtension]!, null);
    }
    
    // If not a valid type, return error
    return (false, 'application/octet-stream', 'Invalid file type: .$fileExtension. Please use a supported image or video format.');
  }
  
  /// Upload a single file to Supabase storage
  ///
  /// This method uploads a file to Supabase storage using the correct API endpoint format
  /// and returns the URL of the uploaded file
  Future<String> uploadSingleFileToSupabase(
    File file,
    String bucketName,
    String filePath, {
    void Function(int, int)? onProgress,
  }) async {
    if (!_isConnected) {
      throw Exception('No network connection available');
    }
    
    _logger.d('Uploading file to Supabase storage: $filePath', tag: 'NetworkOptimizer');
    
    try {
      // Validate the file type
      final (isValid, mimeType, errorMessage) = await validateMediaFile(file);
      
      if (!isValid) {
        _logger.e('Invalid file type: $errorMessage', tag: 'NetworkOptimizer');
        throw Exception(errorMessage ?? 'Invalid file type');
      }
      
      final fileName = path.basename(filePath);
      _logger.d('Validated file with MIME type: $mimeType for file: $fileName', tag: 'NetworkOptimizer');
      
      // Read file as bytes
      final bytes = await file.readAsBytes();
      
      // Construct the proper Supabase storage API endpoint
      final uploadUrl = '${EnvironmentConfig.supabaseUrl}/storage/v1/object/$bucketName/$filePath';
      
      _logger.d('Using Supabase upload URL: $uploadUrl', tag: 'NetworkOptimizer');
      
      // Create headers with proper content type information
      final headers = {
        'Authorization': 'Bearer ${EnvironmentConfig.supabaseAnonKey}',
        'apikey': EnvironmentConfig.supabaseAnonKey,
        'x-upsert': 'true',  // Allow overwriting existing files
        'Content-Type': mimeType, // Set the actual MIME type directly
      };
      
      // Log request details for debugging
      _logger.d('*** Supabase Upload Request ***', tag: 'NetworkOptimizer');
      _logger.d('uri: $uploadUrl', tag: 'NetworkOptimizer');
      _logger.d('method: POST', tag: 'NetworkOptimizer');
      _logger.d('headers: $headers', tag: 'NetworkOptimizer');
      
      // Execute the upload request with raw bytes and proper content type
      final response = await executeWithRetry(
        () => _dio.post(
          uploadUrl,
          data: bytes,
          options: Options(headers: headers),
          onSendProgress: onProgress,
        ),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Construct the public URL for the uploaded file
        final publicUrl = '${EnvironmentConfig.supabaseUrl}/storage/v1/object/public/$bucketName/$filePath';
        _logger.d('File uploaded successfully: $publicUrl', tag: 'NetworkOptimizer');
        return publicUrl;
      } else {
        throw Exception('Upload failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error uploading file to Supabase: $e', tag: 'NetworkOptimizer');
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
    
    _logger.d('Executing batch of ${requests.length} requests', tag: 'NetworkOptimizer');
    
    final results = <Response>[];
    
    for (final request in requests) {
      try {
        final response = await executeWithRetry(() => request());
        results.add(response);
      } catch (e) {
        _logger.e('Error in batch operation: $e', tag: 'NetworkOptimizer');
        if (stopOnError) {
          rethrow;
        }
      }
    }
    
    _logger.d('Batch execution completed with ${results.length} successful responses', tag: 'NetworkOptimizer');
    return results;
  }
  
  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _logger.d('Network optimizer disposed', tag: 'NetworkOptimizer');
  }
}
