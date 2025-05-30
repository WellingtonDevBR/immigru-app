import 'package:image_picker/image_picker.dart';
import 'package:immigru/features/media/data/models/photo_album_model.dart';
import 'package:immigru/features/media/data/models/photo_model.dart';
import 'package:immigru/features/media/domain/entities/photo_album.dart';

/// Interface for media data source
abstract class IMediaDataSource {
  /// Get all albums for a user
  Future<List<PhotoAlbumModel>> getUserAlbums(String userId);
  
  /// Get a specific album by ID
  Future<PhotoAlbumModel> getAlbum(String albumId);
  
  /// Create a new album
  Future<PhotoAlbumModel> createAlbum({
    required String userId,
    required String name,
    String? description,
    AlbumVisibility visibility = AlbumVisibility.private,
  });
  
  /// Update an existing album
  Future<PhotoAlbumModel> updateAlbum({
    required String albumId,
    String? name,
    String? description,
    String? coverPhotoId,
    AlbumVisibility? visibility,
  });
  
  /// Delete an album
  Future<void> deleteAlbum(String albumId);
  
  /// Get photos in an album
  Future<List<PhotoModel>> getAlbumPhotos(String albumId, {int? limit, int? offset});
  
  /// Get a specific photo by ID
  Future<PhotoModel> getPhoto(String photoId);
  
  /// Upload a photo to an album
  Future<PhotoModel> uploadPhoto({
    required String albumId,
    required String userId,
    required XFile imageFile,
    String? title,
    String? description,
    AlbumVisibility? visibility,
  });
  
  /// Update photo details
  Future<PhotoModel> updatePhoto({
    required String photoId,
    String? title,
    String? description,
    AlbumVisibility? visibility,
  });
  
  /// Delete a photo
  Future<void> deletePhoto(String photoId);
  
  /// Set album cover photo
  Future<PhotoAlbumModel> setAlbumCoverPhoto({
    required String albumId,
    required String photoId,
  });
  
  /// Get or create a default album for a user
  Future<PhotoAlbumModel> getOrCreateDefaultAlbum(String userId);
  
  /// Add a comment to a photo
  Future<PhotoModel> addPhotoComment({
    required String photoId,
    required String userId,
    required String userName,
    String? userAvatar,
    required String text,
  });
  
  /// Like a photo
  Future<PhotoModel> likePhoto({
    required String photoId,
    required String userId,
    required String userName,
    String? userAvatar,
  });
  
  /// Unlike a photo
  Future<PhotoModel> unlikePhoto({
    required String photoId,
    required String userId,
  });
}
