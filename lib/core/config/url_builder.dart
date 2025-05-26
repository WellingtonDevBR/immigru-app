import 'package:immigru/core/config/environment_config.dart';
import 'package:immigru/core/config/storage_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Utility class for building URLs for various resources
class UrlBuilder {
  /// Private constructor to prevent instantiation
  UrlBuilder._();
  
  /// Build a public URL for a storage file
  /// 
  /// [bucket] - The storage bucket name
  /// [path] - The file path within the bucket
  static String buildStorageUrl(String bucket, String path) {
    // If the path is already a full URL, return it as is
    if (path.startsWith('http')) {
      return path;
    }
    
    return '${EnvironmentConfig.storageBaseUrl}/object/public/$bucket/$path';
  }
  
  /// Build a public URL for a user avatar
  /// 
  /// [fileName] - Just the avatar file name (e.g., 'avatars-12345.jpg')
  static String buildAvatarUrl(String fileName) {
    // If the fileName is null or empty, return empty string
    if (fileName.isEmpty) {
      return '';
    }
    
    // If it's already a full URL, return it as is
    if (fileName.startsWith('http')) {
      return fileName;
    }
    
    // If it's already a full path with userId, use it directly
    if (fileName.contains('/')) {
      return buildStorageUrl(StorageConfig.buckets.users, fileName);
    }
    
    // Otherwise, we need to build the path using the current user ID
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      // Fallback for when user is not authenticated
      return '';
    }
    
    // Build the full path: userId/avatars/fileName
    final fullPath = '${currentUser.id}/avatars/$fileName';
    return buildStorageUrl(StorageConfig.buckets.users, fullPath);
  }
  
  /// Build a public URL for a user cover image
  /// 
  /// [fileName] - Just the cover image file name (e.g., 'covers-12345.jpg')
  static String buildCoverImageUrl(String fileName) {
    // If the fileName is null or empty, return empty string
    if (fileName.isEmpty) {
      return '';
    }
    
    // If it's already a full URL, return it as is
    if (fileName.startsWith('http')) {
      return fileName;
    }
    
    // If it's already a full path with userId, use it directly
    if (fileName.contains('/')) {
      return buildStorageUrl(StorageConfig.buckets.users, fileName);
    }
    
    // Otherwise, we need to build the path using the current user ID
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      // Fallback for when user is not authenticated
      return '';
    }
    
    // Build the full path: userId/covers/fileName
    final fullPath = '${currentUser.id}/covers/$fileName';
    return buildStorageUrl(StorageConfig.buckets.users, fullPath);
  }
  
  /// Build a public URL for a user album image
  /// 
  /// [fileName] - Just the album image file name (e.g., 'albums-12345.jpg')
  static String buildAlbumImageUrl(String fileName) {
    // If the fileName is null or empty, return empty string
    if (fileName.isEmpty) {
      return '';
    }
    
    // If it's already a full URL, return it as is
    if (fileName.startsWith('http')) {
      return fileName;
    }
    
    // If it's already a full path with userId, use it directly
    if (fileName.contains('/')) {
      return buildStorageUrl(StorageConfig.buckets.users, fileName);
    }
    
    // Otherwise, we need to build the path using the current user ID
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      // Fallback for when user is not authenticated
      return '';
    }
    
    // Build the full path: userId/albums/fileName
    final fullPath = '${currentUser.id}/albums/$fileName';
    return buildStorageUrl(StorageConfig.buckets.users, fullPath);
  }
}
