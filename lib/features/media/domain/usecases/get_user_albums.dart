import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/core/usecases/usecase.dart';
import 'package:immigru/features/media/domain/entities/photo_album.dart';
import 'package:immigru/features/media/domain/repositories/i_media_repository.dart';

/// Use case for getting all albums for a user
class GetUserAlbums implements UseCase<List<PhotoAlbum>, GetUserAlbumsParams> {
  final IMediaRepository _repository;

  /// Constructor
  GetUserAlbums(this._repository);

  @override
  Future<Either<Failure, List<PhotoAlbum>>> call(GetUserAlbumsParams params) {
    return _repository.getUserAlbums(params.userId);
  }
}

/// Parameters for the GetUserAlbums use case
class GetUserAlbumsParams extends Equatable {
  /// User ID to get albums for
  final String userId;

  /// Constructor
  const GetUserAlbumsParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
