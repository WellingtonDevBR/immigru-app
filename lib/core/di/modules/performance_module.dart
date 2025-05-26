import 'package:get_it/get_it.dart';
import 'package:immigru/core/cache/cache_service.dart';
import 'package:immigru/core/cache/image_cache_service.dart';
import 'package:immigru/core/network/network_optimizer.dart';
import 'package:immigru/core/performance/performance_optimizer.dart';

/// Performance module for dependency injection
/// Registers all performance optimization services
class PerformanceModule {
  /// Register all performance optimization dependencies
  static Future<void> register(GetIt sl) async {
    // Register cache service as a singleton
    sl.registerLazySingleton<CacheService>(() => CacheService());
    
    // Register image cache service as a singleton
    sl.registerLazySingleton<ImageCacheService>(() => ImageCacheService());
    
    // Register network optimizer as a singleton
    sl.registerLazySingleton<NetworkOptimizer>(() => NetworkOptimizer());
    
    // Register performance optimizer as a singleton
    sl.registerLazySingleton<PerformanceOptimizer>(() => PerformanceOptimizer());
    
    // Initialize the performance optimizer
    final performanceOptimizer = sl<PerformanceOptimizer>();
    await performanceOptimizer.initialize();
  }
}
