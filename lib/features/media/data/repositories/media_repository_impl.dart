import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:immigru/core/error/exceptions.dart';
import 'package:immigru/core/error/failures.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/core/network/network_info.dart';
import 'package:immigru/features/media/data/datasources/media_data_source.dart';
import 'package:immigru/features/media/domain/entities/photo.dart';
import 'package:immigru/features/media/domain/entities/photo_album.dart';
import 'package:immigru/features/media/domain/repositories/i_media_repository.dart';

/// Implementation of the media repository
class MediaRepositoryImpl implements IMediaRepository {
  final IMediaDataSource _dataSource;
  final INetworkInfo _networkInfo;
  final UnifiedLogger _logger;

  /// Constructor
  MediaRepositoryImpl({
    required IMediaDataSource dataSource,
    required INetworkInfo networkInfo,
    required UnifiedLogger logger,
  })  : _dataSource = dataSource,
        _networkInfo = networkInfo,
        _logger = logger;

  @override
  Future<Either<Failure, List<PhotoAlbum>>> getUserAlbums(String userId) async {
    if (await _networkInfo.isConnected) {
      try {
        final albums = await _dataSource.getUserAlbums(userId);
        return Right(albums);
      } on ServerException catch (e) {
        _logger.e('Server exception getting user albums: ${e.message}', 
            tag: 'MediaRepository');
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        _logger.e('Unexpected error getting user albums: $e', 
            tag: 'MediaRepository');
        return Left(ServerFailure(message: 'Failed to get albums: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, PhotoAlbum>> getAlbum(String albumId) async {
    if (await _networkInfo.isConnected) {
      try {
        final album = await _dataSource.getAlbum(albumId);
        return Right(album);
      } on ServerException catch (e) {
        _logger.e('Server exception getting album: ${e.message}', 
            tag: 'MediaRepository');
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        _logger.e('Unexpected error getting album: $e', 
            tag: 'MediaRepository');
        return Left(ServerFailure(message: 'Failed to get album: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, PhotoAlbum>> createAlbum({
    required String userId,
    required String name,
    String? description,
    AlbumVisibility visibility = AlbumVisibility.private,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final album = await _dataSource.createAlbum(
          userId: userId,
          name: name,
          description: description,
          visibility: visibility,
        );
        return Right(album);
      } on ServerException catch (e) {
        _logger.e('Server exception creating album: ${e.message}', 
            tag: 'MediaRepository');
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        _logger.e('Unexpected error creating album: $e', 
            tag: 'MediaRepository');
        return Left(ServerFailure(message: 'Failed to create album: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, PhotoAlbum>> updateAlbum({
    required String albumId,
    String? name,
    String? description,
    String? coverPhotoId,
    AlbumVisibility? visibility,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final album = await _dataSource.updateAlbum(
          albumId: albumId,
          name: name,
          description: description,
          coverPhotoId: coverPhotoId,
          visibility: visibility,
        );
        return Right(album);
      } on ServerException catch (e) {
        _logger.e('Server exception updating album: ${e.message}', 
            tag: 'MediaRepository');
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        _logger.e('Unexpected error updating album: $e', 
            tag: 'MediaRepository');
        return Left(ServerFailure(message: 'Failed to update album: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAlbum(String albumId) async {
    if (await _networkInfo.isConnected) {
      try {
        await _dataSource.deleteAlbum(albumId);
        return const Right(null);
      } on ServerException catch (e) {
        _logger.e('Server exception deleting album: ${e.message}', 
            tag: 'MediaRepository');
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        _logger.e('Unexpected error deleting album: $e', 
            tag: 'MediaRepository');
        return Left(ServerFailure(message: 'Failed to delete album: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<Photo>>> getAlbumPhotos(String albumId, {int? limit, int? offset}) async {
    if (await _networkInfo.isConnected) {
      try {
        final photos = await _dataSource.getAlbumPhotos(
          albumId,
          limit: limit,
          offset: offset,
        );
        return Right(photos);
      } on ServerException catch (e) {
        _logger.e('Server exception getting album photos: ${e.message}', 
            tag: 'MediaRepository');
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        _logger.e('Unexpected error getting album photos: $e', 
            tag: 'MediaRepository');
        return Left(ServerFailure(message: 'Failed to get photos: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Photo>> getPhoto(String photoId) async {
    if (await _networkInfo.isConnected) {
      try {
        final photo = await _dataSource.getPhoto(photoId);
        return Right(photo);
      } on ServerException catch (e) {
        _logger.e('Server exception getting photo: ${e.message}', 
            tag: 'MediaRepository');
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        _logger.e('Unexpected error getting photo: $e', 
            tag: 'MediaRepository');
        return Left(ServerFailure(message: 'Failed to get photo: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Photo>> uploadPhoto({
    required String albumId,
    required String userId,
    required XFile imageFile,
    String? title,
    String? description,
    AlbumVisibility? visibility,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final photo = await _dataSource.uploadPhoto(
          albumId: albumId,
          userId: userId,
          imageFile: imageFile,
          title: title,
          description: description,
          visibility: visibility,
        );
        return Right(photo);
      } on ServerException catch (e) {
        _logger.e('Server exception uploading photo: ${e.message}', 
            tag: 'MediaRepository');
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        _logger.e('Unexpected error uploading photo: $e', 
            tag: 'MediaRepository');
        return Left(ServerFailure(message: 'Failed to upload photo: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Photo>> updatePhoto({
    required String photoId,
    String? title,
    String? description,
    AlbumVisibility? visibility,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final photo = await _dataSource.updatePhoto(
          photoId: photoId,
          title: title,
          description: description,
          visibility: visibility,
        );
        return Right(photo);
      } on ServerException catch (e) {
        _logger.e('Server exception updating photo: ${e.message}', 
            tag: 'MediaRepository');
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        _logger.e('Unexpected error updating photo: $e', 
            tag: 'MediaRepository');
        return Left(ServerFailure(message: 'Failed to update photo: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePhoto(String photoId) async {
    if (await _networkInfo.isConnected) {
      try {
        await _dataSource.deletePhoto(photoId);
        return const Right(null);
      } on ServerException catch (e) {
        _logger.e('Server exception deleting photo: ${e.message}', 
            tag: 'MediaRepository');
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        _logger.e('Unexpected error deleting photo: $e', 
            tag: 'MediaRepository');
        return Left(ServerFailure(message: 'Failed to delete photo: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, PhotoAlbum>> setAlbumCoverPhoto({
    required String albumId,
    required String photoId,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final album = await _dataSource.setAlbumCoverPhoto(
          albumId: albumId,
          photoId: photoId,
        );
        return Right(album);
      } on ServerException catch (e) {
        _logger.e('Server exception setting album cover photo: ${e.message}', 
            tag: 'MediaRepository');
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        _logger.e('Unexpected error setting album cover photo: $e', 
            tag: 'MediaRepository');
        return Left(ServerFailure(message: 'Failed to set album cover photo: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, PhotoAlbum>> getOrCreateDefaultAlbum(String userId) async {
    if (await _networkInfo.isConnected) {
      try {
        final album = await _dataSource.getOrCreateDefaultAlbum(userId);
        return Right(album);
      } on ServerException catch (e) {
        _logger.e('Server exception getting default album: ${e.message}', 
            tag: 'MediaRepository');
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        _logger.e('Unexpected error getting default album: $e', 
            tag: 'MediaRepository');
        return Left(ServerFailure(message: 'Failed to get default album: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Photo>> addPhotoComment({
    required String photoId,
    required String userId,
    required String userName,
    String? userAvatar,
    required String text,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final photo = await _dataSource.addPhotoComment(
          photoId: photoId,
          userId: userId,
          userName: userName,
          userAvatar: userAvatar,
          text: text,
        );
        return Right(photo);
      } on ServerException catch (e) {
        _logger.e('Server exception adding photo comment: ${e.message}', 
            tag: 'MediaRepository');
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        _logger.e('Unexpected error adding photo comment: $e', 
            tag: 'MediaRepository');
        return Left(ServerFailure(message: 'Failed to add comment: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Photo>> likePhoto({
    required String photoId,
    required String userId,
    required String userName,
    String? userAvatar,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final photo = await _dataSource.likePhoto(
          photoId: photoId,
          userId: userId,
          userName: userName,
          userAvatar: userAvatar,
        );
        return Right(photo);
      } on ServerException catch (e) {
        _logger.e('Server exception liking photo: ${e.message}', 
            tag: 'MediaRepository');
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        _logger.e('Unexpected error liking photo: $e', 
            tag: 'MediaRepository');
        return Left(ServerFailure(message: 'Failed to like photo: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Photo>> unlikePhoto({
    required String photoId,
    required String userId,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final photo = await _dataSource.unlikePhoto(
          photoId: photoId,
          userId: userId,
        );
        return Right(photo);
      } on ServerException catch (e) {
        _logger.e('Server exception unliking photo: ${e.message}', 
            tag: 'MediaRepository');
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        _logger.e('Unexpected error unliking photo: $e', 
            tag: 'MediaRepository');
        return Left(ServerFailure(message: 'Failed to unlike photo: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}
