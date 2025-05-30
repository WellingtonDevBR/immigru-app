import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/core/usecases/usecase.dart';
import 'package:immigru/features/media/domain/entities/photo.dart';
import 'package:immigru/features/media/domain/repositories/i_media_repository.dart';

/// Use case for adding a comment to a photo
class AddPhotoComment implements UseCase<Photo, AddPhotoCommentParams> {
  final IMediaRepository _repository;

  /// Constructor
  const AddPhotoComment(this._repository);

  @override
  Future<Either<Failure, Photo>> call(AddPhotoCommentParams params) async {
    return await _repository.addPhotoComment(
      photoId: params.photoId,
      userId: params.userId,
      userName: params.userName,
      userAvatar: params.userAvatar,
      text: params.text,
    );
  }
}

/// Parameters for adding a comment to a photo
class AddPhotoCommentParams extends Equatable {
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
  const AddPhotoCommentParams({
    required this.photoId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.text,
  });

  @override
  List<Object?> get props => [photoId, userId, userName, userAvatar, text];
}
