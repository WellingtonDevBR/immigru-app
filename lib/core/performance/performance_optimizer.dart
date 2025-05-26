import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:immigru/core/cache/cache_service.dart';
import 'package:immigru/core/cache/image_cache_service.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/core/network/network_optimizer.dart';

/// A service that initializes and manages all performance optimizations
/// 
/// This service coordinates the initialization of caching, network optimization,
/// and UI performance enhancements.
class PerformanceOptimizer {
  static final PerformanceOptimizer _instance = PerformanceOptimizer._internal();
  
  /// Singleton instance
  factory PerformanceOptimizer() => _instance;
  
  PerformanceOptimizer._internal();
  
  final UnifiedLogger _logger = UnifiedLogger();
  final CacheService _cacheService = CacheService();
  final ImageCacheService _imageCacheService = ImageCacheService();
  final NetworkOptimizer _networkOptimizer = NetworkOptimizer();
  
  bool _isInitialized = false;
  
  /// Initialize all performance optimization services
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _logger.d('Initializing performance optimizations', tag: 'PerformanceOptimizer');
    
    try {
      // Initialize services in parallel for faster startup
      await Future.wait([
        _cacheService.init(),
        _imageCacheService.init(),
        _networkOptimizer.init(),
      ]);
      
      // Set optimal frame timing
      _optimizeFrameTiming();
      
      _isInitialized = true;
      _logger.d('Performance optimizations initialized successfully', tag: 'PerformanceOptimizer');
    } catch (e) {
      _logger.e('Error initializing performance optimizations: $e', tag: 'PerformanceOptimizer');
      // Continue even if initialization fails, as these are optimizations
      // and not critical for app functionality
      _isInitialized = true;
    }
  }
  
  /// Get the cache service instance
  CacheService get cacheService => _cacheService;
  
  /// Get the image cache service instance
  ImageCacheService get imageCacheService => _imageCacheService;
  
  /// Get the network optimizer instance
  NetworkOptimizer get networkOptimizer => _networkOptimizer;
  
  /// Optimize frame timing for smoother animations
  void _optimizeFrameTiming() {
    // Enable frame rate throttling when the app is in the background
    // to save battery and resources
    WidgetsBinding.instance.addObserver(_AppLifecycleObserver());
    
    // Schedule a frame to ensure smooth animations
    SchedulerBinding.instance.scheduleFrame();
  }
  
  /// Start tracking performance for a specific operation
  /// 
  /// Returns a stopwatch that can be used to measure the operation's duration
  Stopwatch startPerformanceTracking(String operationName) {
    final stopwatch = Stopwatch()..start();
    _logger.d('Starting performance tracking for: $operationName', tag: 'PerformanceOptimizer');
    return stopwatch;
  }
  
  /// End tracking performance for a specific operation
  /// 
  /// This method logs the duration of the operation and can be used to identify
  /// performance bottlenecks
  void endPerformanceTracking(String operationName, Stopwatch stopwatch) {
    stopwatch.stop();
    final duration = stopwatch.elapsedMilliseconds;
    _logger.d('Performance tracking for $operationName: $duration ms', tag: 'PerformanceOptimizer');
    
    // Log slow operations as warnings
    if (duration > 500) {
      _logger.w('Slow operation detected: $operationName took $duration ms', tag: 'PerformanceOptimizer');
    }
    
    // Track performance metrics for later analysis
    _trackPerformanceMetric(operationName, duration);
  }
  
  /// Track a performance metric for later analysis
  void _trackPerformanceMetric(String metricName, int valueMs) {
    // In a real app, this would send the metric to an analytics service
    // For now, we just log it
    developer.log('PERFORMANCE_METRIC: $metricName = $valueMs ms', name: 'PerformanceOptimizer');
  }
  
  /// Prefetch data for a specific screen
  /// 
  /// This method can be called when a user is likely to navigate to a specific screen
  /// to preload data and improve perceived performance.
  Future<void> prefetchDataForScreen(String screenName, Map<String, dynamic> params) async {
    if (!_isInitialized) await initialize();
    
    _logger.d('Prefetching data for screen: $screenName', tag: 'PerformanceOptimizer');
    
    try {
      switch (screenName) {
        case 'home':
          // Prefetch data for home screen
          // This could include recent posts, user data, etc.
          break;
        case 'profile':
          // Prefetch data for profile screen
          // This could include user profile, posts, etc.
          final userId = params['userId'] as String?;
          if (userId != null) {
            // Prefetch user profile data
          }
          break;
        case 'post_details':
          // Prefetch data for post details screen
          final postId = params['postId'] as String?;
          if (postId != null) {
            // Prefetch post details and comments
          }
          break;
        default:
          _logger.d('No prefetch strategy for screen: $screenName', tag: 'PerformanceOptimizer');
      }
    } catch (e) {
      _logger.e('Error prefetching data for screen $screenName: $e', tag: 'PerformanceOptimizer');
    }
  }
  
  /// Clear all caches
  Future<void> clearAllCaches() async {
    if (!_isInitialized) await initialize();
    
    _logger.d('Clearing all caches', tag: 'PerformanceOptimizer');
    
    try {
      await Future.wait([
        _cacheService.clear(),
        _imageCacheService.clearCache(),
      ]);
      
      _logger.d('All caches cleared successfully', tag: 'PerformanceOptimizer');
    } catch (e) {
      _logger.e('Error clearing caches: $e', tag: 'PerformanceOptimizer');
    }
  }
}

/// Observer for app lifecycle events to optimize performance
class _AppLifecycleObserver extends WidgetsBindingObserver {
  final UnifiedLogger _logger = UnifiedLogger();
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // App is in the foreground
        _logger.d('App resumed - optimizing for foreground use', tag: 'PerformanceOptimizer');
        // Ensure smooth animations when app is in foreground
        SchedulerBinding.instance.scheduleFrame();
        // Optimize for foreground by enabling all frames
        _enableFullFrameRate();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        // App is in the background
        _logger.d('App paused - optimizing for background use', tag: 'PerformanceOptimizer');
        // Reduce frame rate when in background
        _reduceFrameRate();
        break;
      case AppLifecycleState.detached:
        // App is detached
        _logger.d('App detached', tag: 'PerformanceOptimizer');
        break;
      default:
        break;
    }
  }
  
  // Enable full frame rate for foreground operation
  void _enableFullFrameRate() {
    // Schedule a frame to ensure smooth animations
    SchedulerBinding.instance.scheduleFrame();
  }
  
  // Reduce frame rate for background operation to save battery
  void _reduceFrameRate() {
    // When in background, we don't need to schedule frames as frequently
    // The system will handle this automatically
  }
}
