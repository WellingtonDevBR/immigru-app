import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  late Dio _dio;

  // Singleton pattern
  factory NetworkService() {
    return _instance;
  }

  NetworkService._internal() {
    _dio = Dio();
    
    // Add logging interceptor for debugging
    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
      maxWidth: 90,
    ));
    
    // Add error handling interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException error, ErrorInterceptorHandler handler) {
        print('❌ DIO ERROR: ${error.message}');
        print('❌ ERROR TYPE: ${error.type}');
        print('❌ ERROR RESPONSE: ${error.response}');
        return handler.next(error);
      },
    ));
  }

  // Get the Dio instance
  Dio get dio => _dio;

  // Helper methods for common HTTP operations
  Future<Response> get(String url, {Map<String, dynamic>? queryParameters, Options? options}) {
    return _dio.get(url, queryParameters: queryParameters, options: options);
  }

  Future<Response> post(String url, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return _dio.post(url, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> put(String url, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return _dio.put(url, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> delete(String url, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return _dio.delete(url, data: data, queryParameters: queryParameters, options: options);
  }
}
