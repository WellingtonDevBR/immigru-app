import 'package:get_it/get_it.dart';
import 'package:immigru/new_core/network/api_client.dart';
import 'package:immigru/new_core/network/edge_function_client.dart';
import 'package:immigru/new_core/network/interceptors/auth_interceptor.dart';
import 'package:immigru/new_core/network/interceptors/logging_interceptor.dart';

/// Network module for dependency injection
/// Registers all network-related dependencies
class NetworkModule {
  /// Register all network dependencies
  static Future<void> register(GetIt sl) async {
    // Register interceptors
    sl.registerFactory<LoggingInterceptor>(
      () => LoggingInterceptor(),
    );
    
    sl.registerFactory<AuthInterceptor>(
      () => AuthInterceptor(),
    );
    
    // Register API client
    sl.registerLazySingleton<ApiClient>(() => ApiClient(
      interceptors: [
        sl<LoggingInterceptor>(),
        sl<AuthInterceptor>(),
      ],
    ));
    
    // Register Edge Function client
    sl.registerLazySingleton<EdgeFunctionClient>(() => EdgeFunctionClient());
  }
}
