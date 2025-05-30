import 'package:immigru/features/media/domain/entities/photo.dart';
import 'package:immigru/features/media/domain/entities/photo_album.dart';
import 'package:immigru/features/media/domain/entities/photo_comment.dart';
import 'package:immigru/features/media/domain/entities/photo_like.dart';

/// Data model for photos
class PhotoModel extends Photo {
  /// Constructor
  const PhotoModel({
    required super.id,
    required super.albumId,
    required super.userId,
    required super.storagePath,
    required super.url,
    super.thumbnailUrl,
    super.title,
    super.description,
    super.width,
    super.height,
    super.size,
    super.format,
    super.visibility = AlbumVisibility.private,
    required super.updatedAt,
    required super.createdAt,
    super.comments,
    super.likes,
    super.likeCount = 0,
    super.commentCount = 0,
  });

  /// Create a model from JSON data
  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    // Convert string visibility to enum
    AlbumVisibility visibility = AlbumVisibility.private;
    if (json['Visibility'] != null) {
      switch (json['Visibility'].toString().toLowerCase()) {
        case 'public':
          visibility = AlbumVisibility.public;
          break;
        case 'friends':
          visibility = AlbumVisibility.friends;
          break;
        case 'private':
        default:
          visibility = AlbumVisibility.private;
          break;
      }
    }
    
    // Process comments if present
    List<PhotoComment>? comments;
    if (json['PhotoComment'] != null) {
      final commentsList = json['PhotoComment'] as List<dynamic>;
      comments = commentsList.map((commentJson) {
        // Get user information from the UserProfile join if available
        String userName = 'User';
        String? userAvatar;
        
        if (commentJson['UserProfile'] != null) {
          userName = commentJson['UserProfile']['DisplayName'] ?? 'User';
          userAvatar = commentJson['UserProfile']['AvatarUrl'];
        }
        
        return PhotoComment(
          id: commentJson['Id'],
          photoId: commentJson['PhotoId'],
          userId: commentJson['UserId'],
          text: commentJson['Content'],
          userName: userName,
          userAvatar: userAvatar,
          createdAt: DateTime.parse(commentJson['CreatedAt']),
          updatedAt: DateTime.parse(commentJson['UpdatedAt'] ?? commentJson['CreatedAt']),
        );
      }).toList();
    }
    
    // Process likes if present
    List<PhotoLike>? likes;
    if (json['PhotoLike'] != null) {
      final likesList = json['PhotoLike'] as List<dynamic>;
      likes = likesList.map((likeJson) {
        // Get user information from the UserProfile join if available
        String userName = 'User';
        String? userAvatar;
        
        if (likeJson['UserProfile'] != null) {
          userName = likeJson['UserProfile']['DisplayName'] ?? 'User';
          userAvatar = likeJson['UserProfile']['AvatarUrl'];
        }
        
        return PhotoLike(
          id: likeJson['Id'],
          photoId: likeJson['PhotoId'],
          userId: likeJson['UserId'],
          userName: userName,
          userAvatar: userAvatar,
          createdAt: DateTime.parse(likeJson['CreatedAt']),
        );
      }).toList();
    }

    return PhotoModel(
      id: json['Id'],
      albumId: json['AlbumId'],
      userId: json['UserId'],
      storagePath: json['StoragePath'],
      url: json['Url'],
      thumbnailUrl: json['ThumbnailUrl'],
      title: json['Title'],
      description: json['Description'],
      width: json['Width'],
      height: json['Height'],
      size: json['Size'],
      format: json['Format'],
      visibility: visibility,
      updatedAt: DateTime.parse(json['UpdatedAt']),
      createdAt: DateTime.parse(json['CreatedAt']),
      comments: comments,
      likes: likes,
      commentCount: comments?.length ?? 0,
      likeCount: likes?.length ?? 0,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    String visibilityString;
    switch (visibility) {
      case AlbumVisibility.public:
        visibilityString = 'public';
        break;
      case AlbumVisibility.friends:
        visibilityString = 'friends';
        break;
      case AlbumVisibility.private:
        visibilityString = 'private';
        break;
    }

    return {
      'Id': id,
      'AlbumId': albumId,
      'UserId': userId,
      'StoragePath': storagePath,
      'Url': url,
      'ThumbnailUrl': thumbnailUrl,
      'Title': title,
      'Description': description,
      'Width': width,
      'Height': height,
      'Size': size,
      'Format': format,
      'Visibility': visibilityString,
      'UpdatedAt': updatedAt.toIso8601String(),
      'CreatedAt': createdAt.toIso8601String(),
    };
  }

  /// Create a model from the domain entity
  factory PhotoModel.fromEntity(Photo entity) {
    return PhotoModel(
      id: entity.id,
      albumId: entity.albumId,
      userId: entity.userId,
      storagePath: entity.storagePath,
      url: entity.url,
      thumbnailUrl: entity.thumbnailUrl,
      title: entity.title,
      description: entity.description,
      width: entity.width,
      height: entity.height,
      size: entity.size,
      format: entity.format,
      visibility: entity.visibility,
      updatedAt: entity.updatedAt,
      createdAt: entity.createdAt,
    );
  }
}
