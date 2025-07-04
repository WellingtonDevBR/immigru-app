import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:immigru/core/config/url_builder.dart';
import 'package:immigru/core/storage/i_supabase_storage.dart';
import 'package:immigru/shared/theme/app_colors.dart';

/// Implementation of Supabase storage operations
class SupabaseStorageUtils implements ISupabaseStorage {
  /// Singleton instance
  static final SupabaseStorageUtils instance = SupabaseStorageUtils._internal();

  /// The Supabase client
  final SupabaseClient _supabaseClient;

  /// Private constructor for singleton pattern
  SupabaseStorageUtils._internal() : _supabaseClient = Supabase.instance.client;

  /// Constructor with dependency injection for testing
  SupabaseStorageUtils.withClient(this._supabaseClient);

  /// The base Supabase storage URL
  static const String _baseStorageUrl = 'https://kkdhnvapcbwwqapsnnfg.supabase.co/storage/v1/object/public';

  /// Storage bucket names - using the new configuration
  static const String usersBucket = 'users';

  // No longer needed as we inject the client in the constructor

  @override
  bool isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    if (url == 'custom') return false;
    
    // If it's a file path, return false
    if (url.contains('file:///')) return false;
    
    // Check if it's a valid HTTP/HTTPS URL
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return true;
    }
    
    // Check if it matches our avatar/cover image filename pattern
    // Format: {type}-{timestamp}-{random}.{extension}
    final filenamePattern = RegExp(r'^(avatars|covers)-\d+-\d+\.[a-zA-Z0-9]+$');
    return filenamePattern.hasMatch(url);
  }

  @override
  String getPublicUrl(String bucket, String path) {
    final url = '$_baseStorageUrl/$bucket/$path';
    print('DEBUG: getPublicUrl - bucket: $bucket, path: $path');
    print('DEBUG: getPublicUrl - final URL: $url');
    return url;
  }

  @override
  String getProfileImageUrl(String fileName) {
    // Get current user ID
    final currentUser = _supabaseClient.auth.currentUser;
    if (currentUser == null) return '';
    
    // Build the path using the new structure
    final path = '${currentUser.id}/avatars/$fileName';
    return getPublicUrl(usersBucket, path);
  }

  @override
  String getPostMediaUrl(String fileName) {
    return getPublicUrl('post-media', fileName);
  }

  @override
  String getProfileCoverUrl(String fileName) {
    // Get current user ID
    final currentUser = _supabaseClient.auth.currentUser;
    if (currentUser == null) return '';
    
    // Build the path using the new structure
    final path = '${currentUser.id}/covers/$fileName';
    return getPublicUrl(usersBucket, path);
  }

  @override
  String getAvatarUrl(String fileName) {
    print('DEBUG: getAvatarUrl called with fileName: $fileName');
    
    // Get current user ID
    final currentUser = _supabaseClient.auth.currentUser;
    if (currentUser == null) {
      print('DEBUG: getAvatarUrl - No current user, returning empty string');
      return '';
    }
    
    // Build the path using the new structure
    final path = '${currentUser.id}/avatars/$fileName';
    print('DEBUG: getAvatarUrl - Built path: $path');
    
    final url = getPublicUrl(usersBucket, path);
    print('DEBUG: getAvatarUrl - Final URL: $url');
    
    return url;
  }

  @override
  String getCoverUrl(String fileName) {
    // Get current user ID
    final currentUser = _supabaseClient.auth.currentUser;
    if (currentUser == null) return '';
    
    // Build the path using the new structure
    final path = '${currentUser.id}/covers/$fileName';
    return getPublicUrl(usersBucket, path);
  }

  @override
  String getImageUrl(String url, {String? displayName}) {
    print('DEBUG: SupabaseStorageUtils.getImageUrl input: $url');
    
    // Handle special cases first
    if (url.isEmpty || url == 'custom' || url.startsWith('file:///')) {
      final defaultUrl = UrlBuilder.buildDefaultAvatarUrl(displayName ?? 'User');
      print('DEBUG: Using default avatar: $defaultUrl');
      return defaultUrl;
    }
    
    // If it's already a complete URL (Supabase or external), return it as is
    if (url.startsWith('http://') || url.startsWith('https://')) {
      print('DEBUG: Already a complete URL: $url');
      return url;
    }
    
    // Special case for full Supabase storage URLs that might be stored without the http prefix
    if (url.contains('supabase.co/storage/v1/object/public')) {
      print('DEBUG: Found Supabase storage URL without http prefix: $url');
      return 'https://$url';
    }
    
    // For avatar filenames that match our pattern but might not exist in storage
    if (url.startsWith('avatars-')) {
      // First try to get the actual avatar
      try {
        final currentUser = _supabaseClient.auth.currentUser;
        if (currentUser == null) {
          print('DEBUG: No current user, using default avatar');
          return UrlBuilder.buildDefaultAvatarUrl(displayName ?? 'User');
        }
        
        // Try to use the UrlBuilder first if available
        return UrlBuilder.buildAvatarUrl(url);
      } catch (e) {
        print('DEBUG: Error getting avatar URL: $e');
        return UrlBuilder.buildDefaultAvatarUrl(displayName ?? 'User');
      }
    }
    
    // Handle post media paths that include the user ID and timestamp
    // Format: userId/post_timestamp_index.jpg
    if (url.contains('/post_')) {
      print('DEBUG: Found post media path: $url');
      return getPublicUrl('post-media', url);
    }
    
    // Get current user ID for building paths
    final currentUser = _supabaseClient.auth.currentUser;
    if (currentUser == null) {
      print('DEBUG: No current user, using default avatar');
      return UrlBuilder.buildDefaultAvatarUrl(displayName ?? 'User');
    }
    
    print('DEBUG: Current user ID: ${currentUser.id}');
    String result;
    
    // Handle different types of relative paths
    if (url.contains('/')) {
      // It's already a path, just use it with the appropriate bucket
      if (url.contains('post-media/')) {
        result = getPublicUrl('post-media', url.replaceFirst('post-media/', ''));
      } else {
        result = getPublicUrl(usersBucket, url);
      }
      print('DEBUG: Using full path: $result');
    } else {
      // It's just a filename, determine the type based on prefix
      if (url.startsWith('covers-')) {
        // Try to use the UrlBuilder first
        result = UrlBuilder.buildCoverImageUrl(url);
      } else if (url.contains('post_')) {
        // For post media, we need to use the post-media bucket
        result = getPostMediaUrl(url);
      } else {
        // For other media that might be from other users, try to extract user ID if present
        // This is a fallback for media that doesn't follow our naming conventions
        final userId = currentUser.id;
        result = getPublicUrl(usersBucket, '$userId/media/$url');
      }
      print('DEBUG: Using determined URL: $result');
    }
    
    return result;
  }

  @override
  Future<String> uploadFile(String bucket, String path, List<int> fileBytes, {String? contentType}) async {
    try {
      final fileOptions = FileOptions(
        contentType: contentType,
        upsert: true,
      );
      
      await _supabaseClient.storage.from(bucket).uploadBinary(
        path,
        Uint8List.fromList(fileBytes),
        fileOptions: fileOptions,
      );
      
      return getPublicUrl(bucket, path);
    } catch (e) {
      // Return a valid asset path if upload fails
      return 'assets/images/default_profile.png';
    }
  }

  @override
  String fixImageUrl(String? url, {String? displayName}) {
    if (!isValidImageUrl(url)) {
      // Use UI Avatars for generating a default profile image
      final name = displayName ?? 'User';
      // Convert primary color to hex without the # and without the alpha channel
      final backgroundColor = AppColors.primaryColor.value.toRadixString(16).substring(2);
      final textColor = 'FFFFFF'; // White text for contrast
      return 'https://ui-avatars.com/api/?background=$backgroundColor&color=$textColor&name=${Uri.encodeComponent(name)}';
    }
    
    // If it's already a valid Supabase URL, return it as is
    if (url!.contains(_baseStorageUrl)) return url;
    
    // If it's a custom URL that doesn't match our format, return it as is (if valid)
    if (!url.contains('custom') && isValidImageUrl(url)) return url;
    
    // Try to fix the URL by getting the image URL
    return getImageUrl(url, displayName: displayName);
  }
  
  @override
  Future<void> removeFile(String bucket, String path) async {
    try {
      await _supabaseClient.storage.from(bucket).remove([path]);
    } catch (e) {
      print('Error removing file from storage: $e');
      // Rethrow to allow proper error handling upstream
      rethrow;
    }
  }
}
