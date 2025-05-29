import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
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
    
    // Clean URL by removing any query parameters
    String cleanUrl = url.split('?').first;
    
    // Process the URL to ensure it has a proper host
    String processedUrl = cleanUrl;
    
    // Ensure URL has proper http/https prefix for Supabase storage
    if (processedUrl.contains('supabase.co/storage/v1/object') && !processedUrl.startsWith('http')) {
      processedUrl = 'https://$processedUrl';
      _logger.d('Added https prefix to Supabase URL: $processedUrl', tag: 'ImageCacheService');
    }
    
    // Handle potential JSON strings that might be accidentally passed as URLs
    if (url.startsWith('[{') && url.endsWith('}]')) {
      try {
        // Parse the JSON string to extract the media path
        final List<dynamic> mediaList = json.decode(url) as List<dynamic>;
        if (mediaList.isNotEmpty && mediaList[0] is Map<String, dynamic>) {
          final Map<String, dynamic> mediaItem = mediaList[0] as Map<String, dynamic>;
          if (mediaItem.containsKey('path')) {
            cleanUrl = mediaItem['path'] as String;
            _logger.d('Extracted path from JSON: $cleanUrl', tag: 'ImageCacheService');
          } else {
            _logger.e('No path field found in JSON media item', tag: 'ImageCacheService');
            return; // Skip prefetching if we can't extract a valid URL
          }
        } else {
          _logger.e('Invalid media JSON structure', tag: 'ImageCacheService');
          return; // Skip prefetching if the JSON structure is invalid
        }
      } catch (jsonError) {
        _logger.e('Error parsing JSON in URL: $jsonError', tag: 'ImageCacheService');
        return; // Skip prefetching if there's an error
      }
    }
    
    // Skip URLs without a host
    if (!processedUrl.startsWith('http')) {
      _logger.e('Cannot prefetch URL without host: $processedUrl', tag: 'ImageCacheService');
      return;
    }
    
    try {
      _logger.d('Prefetching image: $processedUrl', tag: 'ImageCacheService');
      
      // Use HttpClient directly to add headers for Supabase storage
      if (processedUrl.contains('supabase.co/storage/v1/object')) {
        final httpClient = HttpClient();
        final request = await httpClient.getUrl(Uri.parse(processedUrl));
        
        // Add headers to handle content type issues
        request.headers.add('Accept', 'image/jpeg, image/png, image/webp, image/*');
        request.headers.add('Cache-Control', 'max-age=3600');
        
        final response = await request.close();
        if (response.statusCode == 200) {
          // Save the file to cache
          final bytes = await response.fold<List<int>>(
            <int>[],
            (previous, element) => previous..addAll(element),
          );
          
          // Convert to Uint8List for cache manager
          final uint8Bytes = Uint8List.fromList(bytes);
          
          _logger.d('Successfully downloaded image: $processedUrl', tag: 'ImageCacheService');
          
          await _cacheManager.putFile(
            processedUrl,
            uint8Bytes,
            fileExtension: _getFileExtension(processedUrl),
          );
          
          _logger.d('Successfully prefetched image: $processedUrl', tag: 'ImageCacheService');
          _logger.d('Successfully prefetched image: $cleanUrl', tag: 'ImageCacheService');
        } else {
          throw HttpException('Invalid statusCode: ${response.statusCode}, uri = $cleanUrl');
        }
        
        httpClient.close();
      } else {
        // Use the cache manager for non-Supabase URLs
        await _cacheManager.downloadFile(cleanUrl);
        _logger.d('Successfully prefetched image: $cleanUrl', tag: 'ImageCacheService');
      }
    } catch (e) {
      _logger.e('Error prefetching image: $cleanUrl - $e', tag: 'ImageCacheService');
    }
  }
  
  /// Get file extension from URL
  String _getFileExtension(String url) {
    final uri = Uri.parse(url);
    final path = uri.path;
    final lastDot = path.lastIndexOf('.');
    if (lastDot != -1) {
      return path.substring(lastDot + 1);
    }
    return 'jpg'; // Default extension
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
