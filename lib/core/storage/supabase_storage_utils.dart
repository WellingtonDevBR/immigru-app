import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  /// Storage bucket names
  static const String profileBucket = 'profiles';
  static const String postMediaBucket = 'post-media';
  static const String profileCoversBucket = 'profile-covers';
  static const String profileAlbumsBucket = 'profile-albums';
  static const String avatarsBucket = 'avatars';
  static const String coversBucket = 'covers';

  // No longer needed as we inject the client in the constructor

  @override
  bool isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    if (url == 'custom') return false;
    
    // Check if it's a valid HTTP/HTTPS URL
    return (url.startsWith('http://') || url.startsWith('https://')) &&
           // Make sure it's not a malformed file:/// URL
           !url.contains('file:///');
  }

  @override
  String getPublicUrl(String bucket, String path) {
    return '$_baseStorageUrl/$bucket/$path';
  }

  @override
  String getProfileImageUrl(String fileName) {
    return getPublicUrl(profileBucket, fileName);
  }

  @override
  String getPostMediaUrl(String fileName) {
    return getPublicUrl(postMediaBucket, fileName);
  }

  @override
  String getProfileCoverUrl(String fileName) {
    return getPublicUrl(profileCoversBucket, fileName);
  }

  @override
  String getAvatarUrl(String fileName) {
    return getPublicUrl(avatarsBucket, fileName);
  }

  @override
  String getCoverUrl(String fileName) {
    return getPublicUrl(coversBucket, fileName);
  }

  @override
  String getImageUrl(String url, {String? displayName}) {
    // Handle special cases first
    if (url == 'custom' || url.startsWith('file:///') || !isValidImageUrl(url)) {
      // Use UI Avatars for generating a default profile image with our brand colors
      final name = displayName ?? 'User';
      // Convert primary color to hex without the # and without the alpha channel
      final backgroundColor = AppColors.primaryColor.value.toRadixString(16).substring(2);
      final textColor = 'FFFFFF'; // White text for contrast
      return 'https://ui-avatars.com/api/?background=$backgroundColor&color=$textColor&name=${Uri.encodeComponent(name)}';
    }
    
    // If it's already a Supabase URL, return it as is
    if (url.contains(_baseStorageUrl)) {
      return url;
    }
    
    // If it's a relative path within a bucket, try to determine the bucket
    if (url.startsWith('/')) {
      // Remove leading slash
      url = url.substring(1);
    }
    
    // Try to determine the bucket from the URL pattern
    if (url.startsWith('avatars/')) {
      return getPublicUrl(avatarsBucket, url.substring('avatars/'.length));
    } else if (url.startsWith('covers/')) {
      return getPublicUrl(coversBucket, url.substring('covers/'.length));
    } else if (url.startsWith('profiles/')) {
      return getPublicUrl(profileBucket, url.substring('profiles/'.length));
    } else if (url.startsWith('post-media/')) {
      return getPublicUrl(postMediaBucket, url.substring('post-media/'.length));
    }
    
    // If it's a valid external URL, return it as is
    return url;
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
}
