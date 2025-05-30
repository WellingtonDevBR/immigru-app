import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/media/domain/entities/photo.dart';
import 'package:immigru/features/media/domain/entities/photo_album.dart';

/// Repository interface for media operations
abstract class IMediaRepository {
  /// Get all albums for a user
  Future<Either<Failure, List<PhotoAlbum>>> getUserAlbums(String userId);
  
  /// Get a specific album by ID
  Future<Either<Failure, PhotoAlbum>> getAlbum(String albumId);
  
  /// Create a new album
  Future<Either<Failure, PhotoAlbum>> createAlbum({
    required String userId,
    required String name,
    String? description,
    AlbumVisibility visibility = AlbumVisibility.private,
  });
  
  /// Update an existing album
  Future<Either<Failure, PhotoAlbum>> updateAlbum({
    required String albumId,
    String? name,
    String? description,
    String? coverPhotoId,
    AlbumVisibility? visibility,
  });
  
  /// Delete an album
  Future<Either<Failure, void>> deleteAlbum(String albumId);
  
  /// Get photos in an album
  Future<Either<Failure, List<Photo>>> getAlbumPhotos(String albumId, {int? limit, int? offset});
  
  /// Get a specific photo by ID
  Future<Either<Failure, Photo>> getPhoto(String photoId);
  
  /// Upload a photo to an album
  Future<Either<Failure, Photo>> uploadPhoto({
    required String albumId,
    required String userId,
    required XFile imageFile,
    String? title,
    String? description,
    AlbumVisibility? visibility,
  });
  
  /// Update photo details
  Future<Either<Failure, Photo>> updatePhoto({
    required String photoId,
    String? title,
    String? description,
    AlbumVisibility? visibility,
  });
  
  /// Delete a photo
  Future<Either<Failure, void>> deletePhoto(String photoId);
  
  /// Set album cover photo
  Future<Either<Failure, PhotoAlbum>> setAlbumCoverPhoto({
    required String albumId,
    required String photoId,
  });
  
  /// Create a default album for a user if it doesn't exist
  Future<Either<Failure, PhotoAlbum>> getOrCreateDefaultAlbum(String userId);
  
  /// Add a comment to a photo
  Future<Either<Failure, Photo>> addPhotoComment({
    required String photoId,
    required String userId,
    required String userName,
    String? userAvatar,
    required String text,
  });
  
  /// Like a photo
  Future<Either<Failure, Photo>> likePhoto({
    required String photoId,
    required String userId,
    required String userName,
    String? userAvatar,
  });
  
  /// Unlike a photo
  Future<Either<Failure, Photo>> unlikePhoto({
    required String photoId,
    required String userId,
  });
}
