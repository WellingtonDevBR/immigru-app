import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:immigru/core/network/api_client.dart';
import 'package:immigru/core/network/interceptors/auth_interceptor.dart';
import 'package:immigru/core/network/interceptors/logging_interceptor.dart';

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
        
    // Register Connectivity service
    sl.registerLazySingleton<Connectivity>(() => Connectivity());

    // Note: EdgeFunctionClient is registered in SupabaseModule
    // We don't register it here to avoid conflicts
  }
}
