import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/core/usecases/usecase.dart';
import 'package:immigru/features/media/domain/entities/photo_album.dart';
import 'package:immigru/features/media/domain/repositories/i_media_repository.dart';

/// Use case to get or create a default album for a user
class GetOrCreateDefaultAlbum implements UseCase<PhotoAlbum, GetOrCreateDefaultAlbumParams> {
  /// Media repository
  final IMediaRepository _repository;

  /// Constructor
  GetOrCreateDefaultAlbum(this._repository);

  @override
  Future<Either<Failure, PhotoAlbum>> call(GetOrCreateDefaultAlbumParams params) async {
    return await _repository.getOrCreateDefaultAlbum(params.userId);
  }
}

/// Parameters for [GetOrCreateDefaultAlbum]
class GetOrCreateDefaultAlbumParams extends Equatable {
  /// User ID
  final String userId;

  /// Constructor
  const GetOrCreateDefaultAlbumParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
