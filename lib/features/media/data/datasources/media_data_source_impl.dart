import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:immigru/core/error/exceptions.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/core/storage/i_supabase_storage.dart';
import 'package:immigru/features/media/data/datasources/media_data_source.dart';
import 'package:immigru/features/media/data/models/photo_album_model.dart';
import 'package:immigru/features/media/data/models/photo_model.dart';
import 'package:immigru/features/media/domain/entities/photo_album.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Implementation of media data source using Supabase
class MediaDataSourceImpl implements IMediaDataSource {
  final SupabaseClient _supabaseClient;
  final ISupabaseStorage _storageService;
  final UnifiedLogger _logger;
  
  // Default album name for users who don't specify an album
  final String _defaultAlbumName = 'Default Album';

  /// Constructor
  MediaDataSourceImpl({
    required SupabaseClient supabaseClient,
    required ISupabaseStorage storageService,
    required UnifiedLogger logger,
  })  : _supabaseClient = supabaseClient,
        _storageService = storageService,
        _logger = logger;

  @override
  Future<List<PhotoAlbumModel>> getUserAlbums(String userId) async {
    try {
      _logger.d('Getting albums for user $userId', tag: 'MediaDataSource');
      
      // Get all albums for the user without trying to join with Photo table
      final response = await _supabaseClient
          .from('PhotoAlbum')
          .select()
          .eq('UserId', userId)
          .order('CreatedAt', ascending: false);
      
      _logger.d('Got ${response.length} albums for user $userId', tag: 'MediaDataSource');
      
      return (response as List<dynamic>)
          .map((json) => PhotoAlbumModel.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      _logger.e('Error getting albums for user $userId: $e', 
          tag: 'MediaDataSource', error: e, stackTrace: stackTrace);
      throw ServerException(message: 'Failed to get albums: $e');
    }
  }

  @override
  Future<PhotoAlbumModel> getAlbum(String albumId) async {
    try {
      _logger.d('Getting album $albumId', tag: 'MediaDataSource');
      
      // Get the album without trying to join with Photo table
      final response = await _supabaseClient
          .from('PhotoAlbum')
          .select()
          .eq('Id', albumId)
          .single();
      
      _logger.d('Got album $albumId', tag: 'MediaDataSource');
      
      return PhotoAlbumModel.fromJson(response);
    } catch (e, stackTrace) {
      _logger.e('Error getting album $albumId: $e', 
          tag: 'MediaDataSource', error: e, stackTrace: stackTrace);
      throw ServerException(message: 'Failed to get album: $e');
    }
  }

  @override
  Future<PhotoAlbumModel> createAlbum({
    required String userId,
    required String name,
    String? description,
    AlbumVisibility visibility = AlbumVisibility.private,
  }) async {
    try {
      _logger.d('Creating album "$name" for user $userId', tag: 'MediaDataSource');
      
      // Convert visibility enum to string
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
      
      // Create the album
      final response = await _supabaseClient.from('PhotoAlbum').insert({
        'UserId': userId,
        'Name': name,
        'Description': description,
        'Visibility': visibilityString,
      }).select().single();

      _logger.d('Created album "${response['Id']}" for user $userId', tag: 'MediaDataSource');
      
      // Return the created album
      return PhotoAlbumModel.fromJson(response);
    } catch (e, stackTrace) {
      _logger.e('Error creating album for user $userId: $e', 
          tag: 'MediaDataSource', error: e, stackTrace: stackTrace);
      throw ServerException(message: 'Failed to create album: $e');
    }
  }

  @override
  Future<PhotoAlbumModel> updateAlbum({
    required String albumId,
    String? name,
    String? description,
    String? coverPhotoId,
    AlbumVisibility? visibility,
  }) async {
    try {
      _logger.d('Updating album $albumId', tag: 'MediaDataSource');
      
      // Build update map with only the fields that are provided
      final Map<String, dynamic> updateData = {};
      
      if (name != null) updateData['Name'] = name;
      if (description != null) updateData['Description'] = description;
      if (coverPhotoId != null) updateData['CoverPhotoId'] = coverPhotoId;
      
      if (visibility != null) {
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
        updateData['Visibility'] = visibilityString;
      }

      // Update the album and ignore the response as we'll get the updated album later
      await _supabaseClient
          .from('PhotoAlbum')
          .update(updateData)
          .eq('Id', albumId);

      _logger.d('Updated album $albumId', tag: 'MediaDataSource');
      
      // Get the updated album with cover photo info
      return await getAlbum(albumId);
    } catch (e, stackTrace) {
      _logger.e('Error updating album $albumId: $e', 
          tag: 'MediaDataSource', error: e, stackTrace: stackTrace);
      throw ServerException(message: 'Failed to update album: $e');
    }
  }

  @override
  Future<void> deleteAlbum(String albumId) async {
    try {
      _logger.d('Deleting album $albumId', tag: 'MediaDataSource');
      
      // Check if the album exists before proceeding
      await getAlbum(albumId); // This will throw an exception if the album doesn't exist
      
      // Get all photos in the album
      final photos = await getAlbumPhotos(albumId);
      
      // Delete all photos from storage
      for (final photo in photos) {
        try {
          // Extract bucket and path from storage path
          final parts = photo.storagePath.split('/');
          final bucket = parts[0];
          final filePath = photo.storagePath.substring(bucket.length + 1);
          
          await _storageService.removeFile(bucket, filePath);
          
          if (photo.thumbnailUrl != null) {
            // Extract thumbnail path from URL
            final thumbnailPath = photo.thumbnailUrl!.split('/').last;
            final thumbnailStoragePath = '${path.dirname(photo.storagePath)}/thumbnails/$thumbnailPath';
            
            // Extract bucket and path for thumbnail
            final thumbParts = thumbnailStoragePath.split('/');
            final thumbBucket = thumbParts[0];
            final thumbFilePath = thumbnailStoragePath.substring(thumbBucket.length + 1);
            
            await _storageService.removeFile(thumbBucket, thumbFilePath);
          }
        } catch (e) {
          // Log but continue with other photos
          _logger.w('Error deleting photo file ${photo.id}: $e', tag: 'MediaDataSource');
        }
      }
      
      // Delete the album from the database (this will cascade delete the photos)
      await _supabaseClient.from('PhotoAlbum').delete().eq('Id', albumId);
      
      _logger.d('Deleted album $albumId', tag: 'MediaDataSource');
    } catch (e, stackTrace) {
      _logger.e('Error deleting album $albumId: $e', 
          tag: 'MediaDataSource', error: e, stackTrace: stackTrace);
      throw ServerException(message: 'Failed to delete album: $e');
    }
  }

  @override
  Future<List<PhotoModel>> getAlbumPhotos(String albumId, {int? limit, int? offset}) async {
    try {
      _logger.d('Getting photos for album $albumId', tag: 'MediaDataSource');
      
      // Get photos without trying to join with UserProfile table
      var query = _supabaseClient
          .from('Photo')
          .select('''
            *,
            PhotoComment(*),
            PhotoLike(*)
          ''')
          .eq('AlbumId', albumId)
          .order('CreatedAt', ascending: false);
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 20) - 1);
      }
      
      final response = await query;
      
      _logger.d('Got ${response.length} photos with comments and likes for album $albumId', tag: 'MediaDataSource');
      
      return (response as List<dynamic>)
          .map((json) => PhotoModel.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      _logger.e('Error getting photos for album $albumId: $e', 
          tag: 'MediaDataSource', error: e, stackTrace: stackTrace);
      throw ServerException(message: 'Failed to get photos: $e');
    }
  }

  @override
  Future<PhotoModel> getPhoto(String photoId) async {
    try {
      _logger.d('Getting photo $photoId', tag: 'MediaDataSource');
      
      final response = await _supabaseClient
          .from('Photo')
          .select('''
            *,
            PhotoComment(*, UserProfile:UserProfile(Id, DisplayName, AvatarUrl)),
            PhotoLike(*, UserProfile:UserProfile(Id, DisplayName, AvatarUrl))
          ''')
          .eq('Id', photoId)
          .single();
      
      _logger.d('Got photo $photoId with comments and likes', tag: 'MediaDataSource');
      
      return PhotoModel.fromJson(response);
    } catch (e, stackTrace) {
      _logger.e('Error getting photo $photoId: $e', 
          tag: 'MediaDataSource', error: e, stackTrace: stackTrace);
      throw ServerException(message: 'Failed to get photo: $e');
    }
  }

  @override
  Future<PhotoModel> uploadPhoto({
    required String albumId,
    required String userId,
    required XFile imageFile,
    String? title,
    String? description,
    AlbumVisibility? visibility,
  }) async {
    try {
      _logger.d('Uploading photo to album $albumId for user $userId', tag: 'MediaDataSource');
      
      final File file = File(imageFile.path);
      final String extension = path.extension(imageFile.path).toLowerCase();
      final String fileName = '${const Uuid().v4()}$extension';
      
      // Storage path: users/{userId}/albums/{albumId}/photos/{fileName}
      final String storagePath = 'users/$userId/albums/$albumId/photos/$fileName';
      
      // Upload the file to storage
      final List<int> fileBytes = await file.readAsBytes();
      final String bucket = 'users';
      final String filePath = '$userId/albums/$albumId/photos/$fileName';
      
      final String fileUrl = await _storageService.uploadFile(
        bucket,
        filePath,
        fileBytes,
        contentType: 'image/${extension.replaceAll('.', '')}',
      );
      
      // Generate thumbnail
      final String? thumbnailUrl = await _generateThumbnail(
        file: file,
        userId: userId,
        albumId: albumId,
        fileName: fileName,
      );
      
      // Convert visibility enum to string if provided
      String? visibilityString;
      if (visibility != null) {
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
      }
      
      // Get image dimensions and size
      final fileSize = await file.length();
      // In a real implementation, you would use a package like flutter_image_compress
      // to get the width and height of the image
      final int? width = null; // Placeholder
      final int? height = null; // Placeholder
      
      // Insert the photo record
      final response = await _supabaseClient.from('Photo').insert({
        'AlbumId': albumId,
        'UserId': userId,
        'StoragePath': storagePath,
        'Url': fileUrl,
        'ThumbnailUrl': thumbnailUrl,
        'Title': title,
        'Description': description,
        'Width': width,
        'Height': height,
        'Size': fileSize,
        'Format': extension.replaceAll('.', ''),
        'Visibility': visibilityString,
      }).select().single();
      
      _logger.d('Uploaded photo ${response['Id']} to album $albumId', tag: 'MediaDataSource');
      
      // If this is the first photo in the album, set it as the cover photo
      final album = await getAlbum(albumId);
      if (album.coverPhotoId == null) {
        await setAlbumCoverPhoto(
          albumId: albumId,
          photoId: response['Id'],
        );
      }
      
      return PhotoModel.fromJson(response);
    } catch (e, stackTrace) {
      _logger.e('Error uploading photo to album $albumId: $e', 
          tag: 'MediaDataSource', error: e, stackTrace: stackTrace);
      throw ServerException(message: 'Failed to upload photo: $e');
    }
  }
  
  /// Generate a thumbnail for the image
  /// This is a simplified implementation - in a real app you would use
  /// a package like flutter_image_compress to create a real thumbnail
  Future<String?> _generateThumbnail({
    required File file,
    required String userId,
    required String albumId,
    required String fileName,
  }) async {
    try {
      // In a real implementation, you would resize the image here
      // For now, we'll just use the original image as the thumbnail
      final String thumbnailFileName = 'thumb_$fileName';
      
      // Upload the thumbnail
      final List<int> fileBytes = await file.readAsBytes();
      final String bucket = 'users';
      final String thumbPath = '$userId/albums/$albumId/photos/thumbnails/$thumbnailFileName';
      
      final String thumbnailUrl = await _storageService.uploadFile(
        bucket,
        thumbPath,
        fileBytes,
        contentType: 'image/${path.extension(file.path).replaceAll('.', '')}',
      );
      
      return thumbnailUrl;
    } catch (e, stackTrace) {
      _logger.w('Error generating thumbnail: $e', 
          tag: 'MediaDataSource', error: e, stackTrace: stackTrace);
      return null; // Return null but don't throw - we can still create the photo without a thumbnail
    }
  }

  @override
  Future<PhotoModel> updatePhoto({
    required String photoId,
    String? title,
    String? description,
    AlbumVisibility? visibility,
  }) async {
    try {
      _logger.d('Updating photo $photoId', tag: 'MediaDataSource');
      
      // Build update map with only the fields that are provided
      final Map<String, dynamic> updateData = {};
      
      if (title != null) updateData['Title'] = title;
      if (description != null) updateData['Description'] = description;
      
      if (visibility != null) {
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
        updateData['Visibility'] = visibilityString;
      }
      
      // Update the photo and ignore the response as we'll get the updated photo later
      await _supabaseClient
          .from('Photo')
          .update(updateData)
          .eq('Id', photoId);
      
      _logger.d('Updated photo $photoId', tag: 'MediaDataSource');
      
      // Get the updated photo with full details
      return await getPhoto(photoId);
    } catch (e, stackTrace) {
      _logger.e('Error updating photo $photoId: $e', 
          tag: 'MediaDataSource', error: e, stackTrace: stackTrace);
      throw ServerException(message: 'Failed to update photo: $e');
    }
  }

  @override
  Future<void> deletePhoto(String photoId) async {
    try {
      _logger.d('Deleting photo $photoId', tag: 'MediaDataSource');
      
      // Get the photo first to check if it exists and get the storage path
      final photo = await getPhoto(photoId);
      
      // Delete the photo from storage
      try {
        // Extract bucket and path from storage path
        final parts = photo.storagePath.split('/');
        final bucket = parts[0];
        final filePath = photo.storagePath.substring(bucket.length + 1);
        
        await _storageService.removeFile(bucket, filePath);
        
        if (photo.thumbnailUrl != null) {
          // Extract thumbnail path from URL
          final thumbnailPath = photo.thumbnailUrl!.split('/').last;
          final thumbnailStoragePath = '${path.dirname(photo.storagePath)}/thumbnails/$thumbnailPath';
          
          // Extract bucket and path for thumbnail
          final thumbParts = thumbnailStoragePath.split('/');
          final thumbBucket = thumbParts[0];
          final thumbFilePath = thumbnailStoragePath.substring(thumbBucket.length + 1);
          
          await _storageService.removeFile(thumbBucket, thumbFilePath);
        }
      } catch (e) {
        // Log but continue with database deletion
        _logger.w('Error deleting photo file $photoId: $e', tag: 'MediaDataSource');
      }
      
      // Delete the photo from the database
      await _supabaseClient.from('Photo').delete().eq('Id', photoId);
      
      // Check if this photo was used as a cover photo for any albums
      final albumsWithThisCover = await _supabaseClient
          .from('PhotoAlbum')
          .select()
          .eq('CoverPhotoId', photoId);
      
      // For each album that used this photo as cover, set cover to null
      for (final album in albumsWithThisCover) {
        await _supabaseClient
            .from('PhotoAlbum')
            .update({'CoverPhotoId': null})
            .eq('Id', album['Id']);
      }
      
      _logger.d('Deleted photo $photoId', tag: 'MediaDataSource');
    } catch (e, stackTrace) {
      _logger.e('Error deleting photo $photoId: $e', 
          tag: 'MediaDataSource', error: e, stackTrace: stackTrace);
      throw ServerException(message: 'Failed to delete photo: $e');
    }
  }

  @override
  Future<PhotoAlbumModel> setAlbumCoverPhoto({
    required String albumId,
    required String photoId,
  }) async {
    try {
      _logger.d('Setting cover photo $photoId for album $albumId', tag: 'MediaDataSource');
      
      // Update the album with the new cover photo
      await _supabaseClient
          .from('PhotoAlbum')
          .update({'CoverPhotoId': photoId})
          .eq('Id', albumId);
      
      _logger.d('Set cover photo $photoId for album $albumId', tag: 'MediaDataSource');
      
      // Get the updated album
      return await getAlbum(albumId);
    } catch (e, stackTrace) {
      _logger.e('Error setting cover photo $photoId for album $albumId: $e', 
          tag: 'MediaDataSource', error: e, stackTrace: stackTrace);
      throw ServerException(message: 'Failed to set cover photo: $e');
    }
  }

  @override
  Future<PhotoAlbumModel> getOrCreateDefaultAlbum(String userId) async {
    try {
      _logger.d('Getting or creating default album for user $userId', tag: 'MediaDataSource');
      
      // First try to find an existing default album
      final existingAlbums = await _supabaseClient
          .from('PhotoAlbum')
          .select()
          .eq('UserId', userId)
          .eq('Name', _defaultAlbumName)
          .limit(1);
      
      if (existingAlbums.isNotEmpty) {
        _logger.d('Found existing default album for user $userId', tag: 'MediaDataSource');
        return PhotoAlbumModel.fromJson(existingAlbums.first);
      }
      
      // Create a new default album if none exists
      _logger.d('Creating default album for user $userId', tag: 'MediaDataSource');
      
      final response = await _supabaseClient.from('PhotoAlbum').insert({
        'UserId': userId,
        'Name': _defaultAlbumName,
        'Description': 'Default album for your photos',
        'Visibility': 'private',
      }).select().single();
      
      return PhotoAlbumModel.fromJson(response);
    } catch (e, stackTrace) {
      _logger.e('Error getting or creating default album for user $userId: $e', 
          tag: 'MediaDataSource', error: e, stackTrace: stackTrace);
      throw ServerException(message: 'Failed to get or create default album: $e');
    }
  }

  @override
  Future<PhotoModel> addPhotoComment({
    required String photoId,
    required String userId,
    required String userName,
    String? userAvatar,
    required String text,
  }) async {
    try {
      _logger.d('Adding comment to photo $photoId by user $userId', tag: 'MediaDataSource');
      
      // Insert the comment into the PhotoComment table
      await _supabaseClient.from('PhotoComment').insert({
        'PhotoId': photoId,
        'UserId': userId,
        'Content': text,
      });
      
      // Get the updated photo with the new comment
      final response = await _supabaseClient
          .from('Photo')
          .select('''
            *,
            PhotoComment(*, UserProfile:UserProfile(Id, DisplayName, AvatarUrl)),
            PhotoLike(*, UserProfile:UserProfile(Id, DisplayName, AvatarUrl))
          ''')
          .eq('Id', photoId)
          .single();
      
      // Create the photo model with comments
      final photoModel = PhotoModel.fromJson(response);
      
      _logger.d('Added comment to photo $photoId successfully', tag: 'MediaDataSource');
      
      return photoModel;
    } catch (e, stackTrace) {
      _logger.e('Error adding comment to photo $photoId: $e', 
          tag: 'MediaDataSource', error: e, stackTrace: stackTrace);
      throw ServerException(message: 'Failed to add comment: $e');
    }
  }

  @override
  Future<PhotoModel> likePhoto({
    required String photoId,
    required String userId,
    required String userName,
    String? userAvatar,
  }) async {
    try {
      _logger.d('Liking photo $photoId by user $userId', tag: 'MediaDataSource');
      
      // Check if the user already liked the photo
      final existingLikes = await _supabaseClient
          .from('PhotoLike')
          .select()
          .eq('PhotoId', photoId)
          .eq('UserId', userId);
      
      // If the user hasn't liked the photo yet, add the like
      if (existingLikes.isEmpty) {
        await _supabaseClient.from('PhotoLike').insert({
          'PhotoId': photoId,
          'UserId': userId,
        });
      }
      
      // Get the updated photo with the new like count
      final response = await _supabaseClient
          .from('Photo')
          .select('''
            *,
            PhotoComment(*, UserProfile:UserProfile(Id, DisplayName, AvatarUrl)),
            PhotoLike(*, UserProfile:UserProfile(Id, DisplayName, AvatarUrl))
          ''')
          .eq('Id', photoId)
          .single();
      
      // Create the photo model with likes
      final photoModel = PhotoModel.fromJson(response);
      
      _logger.d('Liked photo $photoId successfully', tag: 'MediaDataSource');
      
      return photoModel;
    } catch (e, stackTrace) {
      _logger.e('Error liking photo $photoId: $e', 
          tag: 'MediaDataSource', error: e, stackTrace: stackTrace);
      throw ServerException(message: 'Failed to like photo: $e');
    }
  }

  @override
  Future<PhotoModel> unlikePhoto({
    required String photoId,
    required String userId,
  }) async {
    try {
      _logger.d('Unliking photo $photoId by user $userId', tag: 'MediaDataSource');
      
      // Delete the like from the PhotoLike table
      await _supabaseClient
          .from('PhotoLike')
          .delete()
          .eq('PhotoId', photoId)
          .eq('UserId', userId);
      
      // Get the updated photo with the new like count
      final response = await _supabaseClient
          .from('Photo')
          .select('''
            *,
            PhotoComment(*, UserProfile:UserProfile(Id, DisplayName, AvatarUrl)),
            PhotoLike(*, UserProfile:UserProfile(Id, DisplayName, AvatarUrl))
          ''')
          .eq('Id', photoId)
          .single();
      
      // Create the photo model with updated likes
      final photoModel = PhotoModel.fromJson(response);
      
      _logger.d('Unliked photo $photoId successfully', tag: 'MediaDataSource');
      
      return photoModel;
    } catch (e, stackTrace) {
      _logger.e('Error unliking photo $photoId: $e', 
          tag: 'MediaDataSource', error: e, stackTrace: stackTrace);
      throw ServerException(message: 'Failed to unlike photo: $e');
    }
  }
}
