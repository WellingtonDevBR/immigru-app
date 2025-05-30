import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/core/usecases/usecase.dart';
import 'package:immigru/features/media/domain/entities/photo.dart';
import 'package:immigru/features/media/domain/entities/photo_album.dart';
import 'package:immigru/features/media/domain/repositories/i_media_repository.dart';

/// Use case for uploading a photo to an album
class UploadPhoto implements UseCase<Photo, UploadPhotoParams> {
  final IMediaRepository _repository;

  /// Constructor
  UploadPhoto(this._repository);

  @override
  Future<Either<Failure, Photo>> call(UploadPhotoParams params) async {
    // If no album ID is provided, get or create the default album
    if (params.albumId == null) {
      final albumResult = await _repository.getOrCreateDefaultAlbum(params.userId);
      
      return albumResult.fold(
        (failure) => Left(failure),
        (album) => _repository.uploadPhoto(
          albumId: album.id,
          userId: params.userId,
          imageFile: params.imageFile,
          title: params.title,
          description: params.description,
          visibility: params.visibility,
        ),
      );
    }
    
    // If album ID is provided, upload directly to that album
    return _repository.uploadPhoto(
      albumId: params.albumId!,
      userId: params.userId,
      imageFile: params.imageFile,
      title: params.title,
      description: params.description,
      visibility: params.visibility,
    );
  }
}

/// Parameters for the UploadPhoto use case
class UploadPhotoParams extends Equatable {
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
  const UploadPhotoParams({
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
