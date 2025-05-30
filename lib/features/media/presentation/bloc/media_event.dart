import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:immigru/features/media/domain/entities/photo_album.dart';

/// Base class for all media events
abstract class MediaEvent extends Equatable {
  /// Constructor
  const MediaEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load user albums
class LoadUserAlbums extends MediaEvent {
  /// User ID to load albums for
  final String userId;
  
  /// Whether to bypass cache
  final bool bypassCache;

  /// Constructor
  const LoadUserAlbums({
    required this.userId,
    this.bypassCache = false,
  });

  @override
  List<Object?> get props => [userId, bypassCache];
}

/// Event to load a specific album
class LoadAlbum extends MediaEvent {
  /// Album ID to load
  final String albumId;
  
  /// Whether to bypass cache
  final bool bypassCache;

  /// Constructor
  const LoadAlbum({
    required this.albumId,
    this.bypassCache = false,
  });

  @override
  List<Object?> get props => [albumId, bypassCache];
}

/// Event to create a new album
class CreateAlbum extends MediaEvent {
  /// User ID who owns the album
  final String userId;
  
  /// Name of the album
  final String name;
  
  /// Optional description of the album
  final String? description;
  
  /// Visibility setting for the album
  final AlbumVisibility visibility;

  /// Constructor
  const CreateAlbum({
    required this.userId,
    required this.name,
    this.description,
    this.visibility = AlbumVisibility.private,
  });

  @override
  List<Object?> get props => [userId, name, description, visibility];
}

/// Event to update an existing album
class UpdateAlbum extends MediaEvent {
  /// Album ID to update
  final String albumId;
  
  /// New name for the album
  final String? name;
  
  /// New description for the album
  final String? description;
  
  /// New cover photo ID for the album
  final String? coverPhotoId;
  
  /// New visibility setting for the album
  final AlbumVisibility? visibility;

  /// Constructor
  const UpdateAlbum({
    required this.albumId,
    this.name,
    this.description,
    this.coverPhotoId,
    this.visibility,
  });

  @override
  List<Object?> get props => [albumId, name, description, coverPhotoId, visibility];
}

/// Event to delete an album
class DeleteAlbum extends MediaEvent {
  /// Album ID to delete
  final String albumId;

  /// Constructor
  const DeleteAlbum({
    required this.albumId,
  });

  @override
  List<Object?> get props => [albumId];
}

/// Event to load photos in an album
class LoadAlbumPhotos extends MediaEvent {
  /// Album ID to load photos from
  final String albumId;
  
  /// Maximum number of photos to return
  final int? limit;
  
  /// Number of photos to skip
  final int? offset;
  
  /// Whether to bypass cache
  final bool bypassCache;

  /// Constructor
  const LoadAlbumPhotos({
    required this.albumId,
    this.limit,
    this.offset,
    this.bypassCache = false,
  });

  @override
  List<Object?> get props => [albumId, limit, offset, bypassCache];
}

/// Event to upload a photo to an album
class UploadPhoto extends MediaEvent {
  /// Album ID to upload the photo to (optional, will use default album if not provided)
  final String? albumId;
  
  /// User ID who owns the photo
  final String userId;
  
  /// The image file to upload
  final XFile imageFile;
  
  /// Optional title for the photo
  final String? title;
  
  /// Optional description for the photo
  final String? description;
  
  /// Visibility setting for the photo
  final AlbumVisibility? visibility;

  /// Constructor
  const UploadPhoto({
    this.albumId,
    required this.userId,
    required this.imageFile,
    this.title,
    this.description,
    this.visibility,
  });

  @override
  List<Object?> get props => [albumId, userId, imageFile, title, description, visibility];
}

/// Event to delete a photo
class DeletePhoto extends MediaEvent {
  /// Photo ID to delete
  final String photoId;

  /// Constructor
  const DeletePhoto({
    required this.photoId,
  });

  @override
  List<Object?> get props => [photoId];
}

/// Event to set an album cover photo
class SetAlbumCoverPhoto extends MediaEvent {
  /// Album ID to set cover photo for
  final String albumId;
  
  /// Photo ID to use as cover photo
  final String photoId;

  /// Constructor
  const SetAlbumCoverPhoto({
    required this.albumId,
    required this.photoId,
  });

  @override
  List<Object?> get props => [albumId, photoId];
}

/// Event to get or create a default album for a user
class GetOrCreateDefaultAlbum extends MediaEvent {
  /// User ID to get or create default album for
  final String userId;

  /// Constructor
  const GetOrCreateDefaultAlbum({
    required this.userId,
  });

  @override
  List<Object?> get props => [userId];
}

/// Event to clear any errors
class ClearMediaError extends MediaEvent {
  /// Constructor
  const ClearMediaError();
}

/// Event to clear the selected album
class ClearSelectedAlbum extends MediaEvent {
  /// Constructor
  const ClearSelectedAlbum();
}

/// Event to upload multiple photos to an album
class UploadMultiplePhotos extends MediaEvent {
  /// Album ID to upload the photos to
  final String albumId;
  
  /// User ID who owns the photos
  final String userId;
  
  /// The image files to upload
  final List<XFile> imageFiles;
  
  /// Optional title for the photos (will be applied to all)
  final String? title;
  
  /// Optional description for the photos (will be applied to all)
  final String? description;
  
  /// Visibility setting for the photos
  final AlbumVisibility? visibility;

  /// Constructor
  const UploadMultiplePhotos({
    required this.albumId,
    required this.userId,
    required this.imageFiles,
    this.title,
    this.description,
    this.visibility,
  });

  @override
  List<Object?> get props => [albumId, userId, imageFiles, title, description, visibility];
}

/// Event to add a comment to a photo
class AddPhotoComment extends MediaEvent {
  /// ID of the photo to comment on
  final String photoId;
  
  /// ID of the user making the comment
  final String userId;
  
  /// Display name of the user making the comment
  final String userName;
  
  /// Avatar URL of the user making the comment
  final String? userAvatar;
  
  /// Comment text
  final String text;

  /// Constructor
  const AddPhotoComment({
    required this.photoId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.text,
  });

  @override
  List<Object?> get props => [photoId, userId, userName, userAvatar, text];
}

/// Event to like a photo
class LikePhoto extends MediaEvent {
  /// ID of the photo to like
  final String photoId;
  
  /// ID of the user liking the photo
  final String userId;
  
  /// Display name of the user liking the photo
  final String userName;
  
  /// Avatar URL of the user liking the photo
  final String? userAvatar;

  /// Constructor
  const LikePhoto({
    required this.photoId,
    required this.userId,
    required this.userName,
    this.userAvatar,
  });

  @override
  List<Object?> get props => [photoId, userId, userName, userAvatar];
}

/// Event to unlike a photo
class UnlikePhoto extends MediaEvent {
  /// ID of the photo to unlike
  final String photoId;
  
  /// ID of the user unliking the photo
  final String userId;

  /// Constructor
  const UnlikePhoto({
    required this.photoId,
    required this.userId,
  });

  @override
  List<Object?> get props => [photoId, userId];
}
