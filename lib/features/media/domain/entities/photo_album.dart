import 'package:equatable/equatable.dart';

/// Enum representing the visibility options for albums and photos
enum AlbumVisibility {
  /// Visible to everyone
  public,
  
  /// Visible only to the owner
  private,
  
  /// Visible to friends only
  friends,
}

/// Domain entity representing a photo album
class PhotoAlbum extends Equatable {
  /// Unique identifier for the album
  final String id;
  
  /// ID of the user who owns this album
  final String userId;
  
  /// Name of the album
  final String name;
  
  /// Optional description of the album
  final String? description;
  
  /// ID of the cover photo for this album
  final String? coverPhotoId;
  
  /// URL of the cover photo
  final String? coverPhotoUrl;
  
  /// Title of the cover photo
  final String? coverPhotoTitle;
  
  /// Description of the cover photo
  final String? coverPhotoDescription;
  
  /// Number of photos in this album
  final int photoCount;
  
  /// Visibility setting for this album
  final AlbumVisibility visibility;
  
  /// When the album was last updated
  final DateTime updatedAt;
  
  /// When the album was created
  final DateTime createdAt;

  /// Constructor
  const PhotoAlbum({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.coverPhotoId,
    this.coverPhotoUrl,
    this.coverPhotoTitle,
    this.coverPhotoDescription,
    this.photoCount = 0,
    this.visibility = AlbumVisibility.private,
    required this.updatedAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        description,
        coverPhotoId,
        coverPhotoUrl,
        photoCount,
        visibility,
        updatedAt,
        createdAt,
      ];
      
  /// Create a copy of this album with modified properties
  PhotoAlbum copyWith({
    String? id,
    String? userId,
    String? name,
    String? Function()? description,
    String? Function()? coverPhotoId,
    String? Function()? coverPhotoUrl,
    String? Function()? coverPhotoTitle,
    String? Function()? coverPhotoDescription,
    int? photoCount,
    AlbumVisibility? visibility,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) {
    return PhotoAlbum(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description != null ? description() : this.description,
      coverPhotoId: coverPhotoId != null ? coverPhotoId() : this.coverPhotoId,
      coverPhotoUrl: coverPhotoUrl != null ? coverPhotoUrl() : this.coverPhotoUrl,
      coverPhotoTitle: coverPhotoTitle != null ? coverPhotoTitle() : this.coverPhotoTitle,
      coverPhotoDescription: coverPhotoDescription != null ? coverPhotoDescription() : this.coverPhotoDescription,
      photoCount: photoCount ?? this.photoCount,
      visibility: visibility ?? this.visibility,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
