import 'package:immigru/features/media/domain/entities/photo_album.dart';

/// Data model for photo albums
class PhotoAlbumModel extends PhotoAlbum {
  /// Constructor
  const PhotoAlbumModel({
    required super.id,
    required super.userId,
    required super.name,
    super.description,
    super.coverPhotoId,
    super.coverPhotoUrl,
    super.coverPhotoTitle,
    super.coverPhotoDescription,
    super.photoCount = 0,
    super.visibility = AlbumVisibility.private,
    required super.updatedAt,
    required super.createdAt,
  });

  /// Create a model from JSON data
  factory PhotoAlbumModel.fromJson(Map<String, dynamic> json) {
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

    return PhotoAlbumModel(
      id: json['Id'],
      userId: json['UserId'],
      name: json['Name'],
      description: json['Description'],
      coverPhotoId: json['CoverPhotoId'],
      coverPhotoUrl: json['CoverPhotoUrl'],
      coverPhotoTitle: json['CoverPhotoTitle'],
      coverPhotoDescription: json['CoverPhotoDescription'],
      photoCount: json['PhotoCount'] ?? 0,
      visibility: visibility,
      updatedAt: DateTime.parse(json['UpdatedAt']),
      createdAt: DateTime.parse(json['CreatedAt']),
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
      default:
        visibilityString = 'private';
        break;
    }

    return {
      'Id': id,
      'UserId': userId,
      'Name': name,
      'Description': description,
      'CoverPhotoId': coverPhotoId,
      'PhotoCount': photoCount,
      'Visibility': visibilityString,
      'UpdatedAt': updatedAt.toIso8601String(),
      'CreatedAt': createdAt.toIso8601String(),
    };
  }

  /// Create a model from the domain entity
  factory PhotoAlbumModel.fromEntity(PhotoAlbum entity) {
    return PhotoAlbumModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      description: entity.description,
      coverPhotoId: entity.coverPhotoId,
      coverPhotoUrl: entity.coverPhotoUrl,
      coverPhotoTitle: entity.coverPhotoTitle,
      coverPhotoDescription: entity.coverPhotoDescription,
      photoCount: entity.photoCount,
      visibility: entity.visibility,
      updatedAt: entity.updatedAt,
      createdAt: entity.createdAt,
    );
  }
}
