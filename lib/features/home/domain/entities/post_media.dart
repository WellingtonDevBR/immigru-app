/// Entity representing media (image or video) attached to a post
class PostMedia {
  /// Unique identifier for the media
  final String id;
  
  /// File path to the media
  final String path;
  
  /// Display name of the media
  final String name;
  
  /// Type of media (image or video)
  final MediaType type;
  
  /// Creation timestamp
  final DateTime createdAt;

  /// Constructor
  const PostMedia({
    required this.id,
    required this.path,
    required this.name,
    required this.type,
    required this.createdAt,
  });
}

/// Enum representing the type of media
enum MediaType {
  image,
  video,
}
