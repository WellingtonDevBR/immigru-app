import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/core/usecases/usecase.dart';
import 'package:immigru/features/media/domain/entities/photo.dart';
import 'package:immigru/features/media/domain/repositories/i_media_repository.dart';

/// Use case for getting photos in an album
class GetAlbumPhotos implements UseCase<List<Photo>, GetAlbumPhotosParams> {
  final IMediaRepository _repository;

  /// Constructor
  GetAlbumPhotos(this._repository);

  @override
  Future<Either<Failure, List<Photo>>> call(GetAlbumPhotosParams params) {
    return _repository.getAlbumPhotos(
      params.albumId,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

/// Parameters for the GetAlbumPhotos use case
class GetAlbumPhotosParams extends Equatable {
  /// Album ID to get photos from
  final String albumId;
  
  /// Maximum number of photos to return
  final int? limit;
  
  /// Number of photos to skip
  final int? offset;

  /// Constructor
  const GetAlbumPhotosParams({
    required this.albumId,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [albumId, limit, offset];
}
