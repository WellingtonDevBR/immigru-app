/// Configuration for storage paths and buckets
class StorageConfig {
  /// Private constructor to prevent instantiation
  StorageConfig._();

  /// Storage buckets
  static const buckets = _Buckets();

  /// User-related paths
  static const userPaths = _UserPaths();

  /// Generate a unique file ID based on timestamp and random suffix
  static String generateFileId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = timestamp % 10000; // Use last 4 digits for uniqueness
    return '$timestamp-$randomSuffix';
  }

  /// Get the full storage path for an avatar image
  static String getAvatarStoragePath(String userId, String fileExtension) {
    final fileId = generateFileId();
    return '${userPaths.avatarPath(userId)}/avatars-$fileId.$fileExtension';
  }

  /// Get the full storage path for a cover image
  static String getCoverStoragePath(String userId, String fileExtension) {
    final fileId = generateFileId();
    return '${userPaths.coverPath(userId)}/covers-$fileId.$fileExtension';
  }

  /// Get the full storage path for an album image
  static String getAlbumStoragePath(String userId, String fileExtension) {
    final fileId = generateFileId();
    return '${userPaths.albumPath(userId)}/albums-$fileId.$fileExtension';
  }
}

/// Storage bucket names
class _Buckets {
  const _Buckets();

  /// Base storage bucket for user-related files
  final String users = 'users';

  /// Storage bucket for post media
  final String postMedia = 'post-media';
}

/// User-related storage paths
class _UserPaths {
  const _UserPaths();

  /// Get the path for user avatar images
  String avatarPath(String userId) => '$userId/avatars';

  /// Get the path for user cover images
  String coverPath(String userId) => '$userId/covers';

  /// Get the path for user album images
  String albumPath(String userId) => '$userId/albums';
}
