import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/core/usecases/usecase.dart';
import 'package:immigru/features/media/domain/entities/photo.dart';
import 'package:immigru/features/media/domain/repositories/i_media_repository.dart';

/// Use case for liking a photo
class LikePhoto implements UseCase<Photo, LikePhotoParams> {
  final IMediaRepository _repository;

  /// Constructor
  const LikePhoto(this._repository);

  @override
  Future<Either<Failure, Photo>> call(LikePhotoParams params) async {
    return await _repository.likePhoto(
      photoId: params.photoId,
      userId: params.userId,
      userName: params.userName,
      userAvatar: params.userAvatar,
    );
  }
}

/// Parameters for liking a photo
class LikePhotoParams extends Equatable {
  /// ID of the photo to like
  final String photoId;
  
  /// ID of the user liking the photo
  final String userId;
  
  /// Display name of the user liking the photo
  final String userName;
  
  /// Avatar URL of the user liking the photo
  final String? userAvatar;

  /// Constructor
  const LikePhotoParams({
    required this.photoId,
    required this.userId,
    required this.userName,
    this.userAvatar,
  });

  @override
  List<Object?> get props => [photoId, userId, userName, userAvatar];
}
