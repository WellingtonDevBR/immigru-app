import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:immigru/core/logging/unified_logger.dart';

/// A service that provides caching functionality for the application.
/// 
/// This service implements a two-level caching strategy:
/// 1. In-memory cache for fast access during app session
/// 2. Persistent cache using SharedPreferences for data that should survive app restarts
class CacheService {
  static final CacheService _instance = CacheService._internal();
  
  /// Singleton instance
  factory CacheService() => _instance;
  
  CacheService._internal();
  
  final UnifiedLogger _logger = UnifiedLogger();
  final Map<String, dynamic> _memoryCache = {};
  late SharedPreferences _prefs;
  
  /// Cache expiration times
  static const Duration shortTerm = Duration(minutes: 5);
  static const Duration mediumTerm = Duration(hours: 1);
  static const Duration longTerm = Duration(days: 1);
  
  /// Initialize the cache service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _logger.d('Cache service initialized', tag: 'CacheService');
  }
  
  /// Save data to cache with expiration
  Future<bool> set<T>(
    String key, 
    T data, {
    Duration expiration = mediumTerm,
    bool persistToDisk = false,
  }) async {
    try {
      // Create cache entry with expiration time
      final expiryTime = DateTime.now().add(expiration);
      final cacheEntry = {
        'data': data,
        'expiry': expiryTime.millisecondsSinceEpoch,
      };
      
      // Save to memory cache
      _memoryCache[key] = cacheEntry;
      
      // Save to persistent storage if requested
      if (persistToDisk) {
        String serializedData;
        if (T == List || T == Map) {
          serializedData = jsonEncode(cacheEntry);
        } else {
          serializedData = jsonEncode(cacheEntry);
        }
        await _prefs.setString(key, serializedData);
      }
      
      _logger.d('Cached data for key: $key (expires: ${expiryTime.toIso8601String()})', 
          tag: 'CacheService');
      return true;
    } catch (e) {
      _logger.e('Error caching data for key: $key - $e', tag: 'CacheService');
      return false;
    }
  }
  
  /// Get data from cache
  T? get<T>(String key, {bool checkDiskCache = true}) {
    try {
      // Check memory cache first
      if (_memoryCache.containsKey(key)) {
        final cacheEntry = _memoryCache[key];
        final expiryTime = DateTime.fromMillisecondsSinceEpoch(cacheEntry['expiry']);
        
        // Check if cache entry is still valid
        if (DateTime.now().isBefore(expiryTime)) {
          _logger.d('Cache hit for key: $key (memory)', tag: 'CacheService');
          return cacheEntry['data'] as T;
        } else {
          // Remove expired cache entry
          _memoryCache.remove(key);
          _logger.d('Removed expired cache entry for key: $key', tag: 'CacheService');
        }
      }
      
      // If not in memory cache or expired, check disk cache if requested
      if (checkDiskCache) {
        final serializedData = _prefs.getString(key);
        if (serializedData != null) {
          final cacheEntry = jsonDecode(serializedData);
          final expiryTime = DateTime.fromMillisecondsSinceEpoch(cacheEntry['expiry']);
          
          // Check if disk cache entry is still valid
          if (DateTime.now().isBefore(expiryTime)) {
            // Restore to memory cache
            _memoryCache[key] = cacheEntry;
            _logger.d('Cache hit for key: $key (disk)', tag: 'CacheService');
            return cacheEntry['data'] as T;
          } else {
            // Remove expired disk cache entry
            _prefs.remove(key);
            _logger.d('Removed expired disk cache entry for key: $key', tag: 'CacheService');
          }
        }
      }
      
      // Cache miss
      _logger.d('Cache miss for key: $key', tag: 'CacheService');
      return null;
    } catch (e) {
      _logger.e('Error retrieving cached data for key: $key - $e', tag: 'CacheService');
      return null;
    }
  }
  
  /// Remove data from cache
  Future<bool> remove(String key) async {
    try {
      _memoryCache.remove(key);
      await _prefs.remove(key);
      _logger.d('Removed cache entry for key: $key', tag: 'CacheService');
      return true;
    } catch (e) {
      _logger.e('Error removing cache entry for key: $key - $e', tag: 'CacheService');
      return false;
    }
  }
  
  /// Clear all cache data
  Future<bool> clear() async {
    try {
      _memoryCache.clear();
      await _prefs.clear();
      _logger.d('Cleared all cache data', tag: 'CacheService');
      return true;
    } catch (e) {
      _logger.e('Error clearing cache data - $e', tag: 'CacheService');
      return false;
    }
  }
  
  /// Clear cache data by prefix
  Future<bool> clearByPrefix(String prefix) async {
    try {
      // Clear memory cache entries with matching prefix
      _memoryCache.removeWhere((key, _) => key.startsWith(prefix));
      
      // Clear disk cache entries with matching prefix
      final keys = _prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(prefix)) {
          await _prefs.remove(key);
        }
      }
      
      _logger.d('Cleared cache data with prefix: $prefix', tag: 'CacheService');
      return true;
    } catch (e) {
      _logger.e('Error clearing cache data with prefix: $prefix - $e', tag: 'CacheService');
      return false;
    }
  }
  
  /// Check if cache contains a key
  bool containsKey(String key) {
    return _memoryCache.containsKey(key) || _prefs.containsKey(key);
  }
}
