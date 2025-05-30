/// Interface for Supabase storage operations
abstract class ISupabaseStorage {
  /// Validates if a URL is a valid image URL
  bool isValidImageUrl(String? url);

  /// Gets a public URL for a file in a bucket
  String getPublicUrl(String bucket, String path);

  /// Gets a public URL for a profile image
  String getProfileImageUrl(String fileName);

  /// Gets a public URL for a post media image
  String getPostMediaUrl(String fileName);

  /// Gets a public URL for a profile cover image
  String getProfileCoverUrl(String fileName);

  /// Gets a public URL for an avatar image
  String getAvatarUrl(String fileName);

  /// Gets a public URL for a cover image
  String getCoverUrl(String fileName);

  /// Gets a properly formatted image URL, ensuring it uses the correct format
  /// If the URL is invalid, it will generate a UI Avatar using the displayName
  String getImageUrl(String url, {String? displayName});

  /// Uploads a file to a bucket and returns the public URL
  Future<String> uploadFile(String bucket, String path, List<int> fileBytes, {String? contentType});

  /// Fixes a potentially malformed URL by ensuring it uses the proper storage URL format
  /// If the URL is invalid, it will generate a UI Avatar using the displayName
  String fixImageUrl(String? url, {String? displayName});
  
  /// Removes a file from storage
  Future<void> removeFile(String bucket, String path);
}
