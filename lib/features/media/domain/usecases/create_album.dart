import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/core/usecases/usecase.dart';
import 'package:immigru/features/media/domain/entities/photo_album.dart';
import 'package:immigru/features/media/domain/repositories/i_media_repository.dart';

/// Use case for creating a new album
class CreateAlbum implements UseCase<PhotoAlbum, CreateAlbumParams> {
  final IMediaRepository _repository;

  /// Constructor
  CreateAlbum(this._repository);

  @override
  Future<Either<Failure, PhotoAlbum>> call(CreateAlbumParams params) {
    return _repository.createAlbum(
      userId: params.userId,
      name: params.name,
      description: params.description,
      visibility: params.visibility,
    );
  }
}

/// Parameters for the CreateAlbum use case
class CreateAlbumParams extends Equatable {
  /// User ID who owns the album
  final String userId;
  
  /// Name of the album
  final String name;
  
  /// Optional description of the album
  final String? description;
  
  /// Visibility setting for the album
  final AlbumVisibility visibility;

  /// Constructor
  const CreateAlbumParams({
    required this.userId,
    required this.name,
    this.description,
    this.visibility = AlbumVisibility.private,
  });

  @override
  List<Object?> get props => [userId, name, description, visibility];
}
