import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/core/usecases/usecase.dart';
import 'package:immigru/features/media/domain/entities/photo.dart';
import 'package:immigru/features/media/domain/repositories/i_media_repository.dart';

/// Use case for unliking a photo
class UnlikePhoto implements UseCase<Photo, UnlikePhotoParams> {
  final IMediaRepository _repository;

  /// Constructor
  const UnlikePhoto(this._repository);

  @override
  Future<Either<Failure, Photo>> call(UnlikePhotoParams params) async {
    return await _repository.unlikePhoto(
      photoId: params.photoId,
      userId: params.userId,
    );
  }
}

/// Parameters for unliking a photo
class UnlikePhotoParams extends Equatable {
  /// ID of the photo to unlike
  final String photoId;
  
  /// ID of the user unliking the photo
  final String userId;

  /// Constructor
  const UnlikePhotoParams({
    required this.photoId,
    required this.userId,
  });

  @override
  List<Object?> get props => [photoId, userId];
}
