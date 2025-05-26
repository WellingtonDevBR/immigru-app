import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:path_provider/path_provider.dart';

/// A service for optimized image caching and loading
///
/// This service provides advanced image caching capabilities:
/// 1. Prefetching of images for better user experience
/// 2. Disk caching with size and time limits
/// 3. Background downloading of images
/// 4. Optimized image loading with proper error handling
class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  
  /// Singleton instance
  factory ImageCacheService() => _instance;
  
  ImageCacheService._internal();
  
  final UnifiedLogger _logger = UnifiedLogger();
  late final BaseCacheManager _cacheManager;
  
  /// Initialize the image cache service
  Future<void> init() async {
    final cacheDir = await getTemporaryDirectory();
    final imageCacheDir = Directory('${cacheDir.path}/image_cache');
    
    if (!await imageCacheDir.exists()) {
      await imageCacheDir.create(recursive: true);
    }
    
    _cacheManager = CacheManager(
      Config(
        'imageCache',
        stalePeriod: const Duration(days: 7),
        maxNrOfCacheObjects: 500,
        repo: JsonCacheInfoRepository(databaseName: 'imageCache'),
        fileService: HttpFileService(),
      ),
    );
    
    _logger.d('Image cache service initialized', tag: 'ImageCacheService');
  }
  
  /// Prefetch an image and store it in the cache
  ///
  /// This method downloads the image in the background and stores it in the cache
  /// for faster loading when needed later.
  Future<void> prefetchImage(String url) async {
    if (url.isEmpty) return;
    
    try {
      _logger.d('Prefetching image: $url', tag: 'ImageCacheService');
      await _cacheManager.downloadFile(url);
      _logger.d('Successfully prefetched image: $url', tag: 'ImageCacheService');
    } catch (e) {
      _logger.e('Error prefetching image: $url - $e', tag: 'ImageCacheService');
    }
  }
  
  /// Prefetch multiple images in parallel
  ///
  /// This method downloads multiple images in parallel and stores them in the cache.
  Future<void> prefetchImages(List<String> urls) async {
    if (urls.isEmpty) return;
    
    _logger.d('Prefetching ${urls.length} images', tag: 'ImageCacheService');
    
    // Use a maximum of 5 parallel downloads to avoid overloading the network
    final chunks = <List<String>>[];
    for (var i = 0; i < urls.length; i += 5) {
      chunks.add(
        urls.sublist(i, i + 5 > urls.length ? urls.length : i + 5),
      );
    }
    
    for (final chunk in chunks) {
      await Future.wait(
        chunk.map((url) => prefetchImage(url)),
      );
    }
    
    _logger.d('Completed prefetching ${urls.length} images', tag: 'ImageCacheService');
  }
  
  /// Get an image file from the cache or download it if not available
  ///
  /// This method returns a [File] object that can be used to display the image.
  Future<File?> getImageFile(String url) async {
    if (url.isEmpty) return null;
    
    try {
      _logger.d('Getting image file: $url', tag: 'ImageCacheService');
      final fileInfo = await _cacheManager.getFileFromCache(url);
      
      if (fileInfo != null) {
        _logger.d('Image file found in cache: $url', tag: 'ImageCacheService');
        return fileInfo.file;
      }
      
      _logger.d('Image file not in cache, downloading: $url', tag: 'ImageCacheService');
      final downloadedFile = await _cacheManager.getSingleFile(url);
      _logger.d('Image file downloaded: $url', tag: 'ImageCacheService');
      return downloadedFile;
    } catch (e) {
      _logger.e('Error getting image file: $url - $e', tag: 'ImageCacheService');
      return null;
    }
  }
  
  /// Clear all cached images
  Future<void> clearCache() async {
    try {
      _logger.d('Clearing image cache', tag: 'ImageCacheService');
      await _cacheManager.emptyCache();
      _logger.d('Image cache cleared', tag: 'ImageCacheService');
    } catch (e) {
      _logger.e('Error clearing image cache: $e', tag: 'ImageCacheService');
    }
  }
  
  /// Remove a specific image from the cache
  Future<void> removeFromCache(String url) async {
    if (url.isEmpty) return;
    
    try {
      _logger.d('Removing image from cache: $url', tag: 'ImageCacheService');
      await _cacheManager.removeFile(url);
      _logger.d('Image removed from cache: $url', tag: 'ImageCacheService');
    } catch (e) {
      _logger.e('Error removing image from cache: $url - $e', tag: 'ImageCacheService');
    }
  }
}
