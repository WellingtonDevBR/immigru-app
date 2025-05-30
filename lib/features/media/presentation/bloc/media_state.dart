import 'package:equatable/equatable.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/media/domain/entities/photo.dart';
import 'package:immigru/features/media/domain/entities/photo_album.dart';

/// State for the media feature
class MediaState extends Equatable {
  /// List of user albums
  final List<PhotoAlbum>? albums;
  
  /// Whether albums are loading
  final bool isAlbumsLoading;
  
  /// Error when loading albums
  final Failure? albumsError;
  
  /// Currently selected album
  final PhotoAlbum? selectedAlbum;
  
  /// Whether the selected album is loading
  final bool isAlbumLoading;
  
  /// Error when loading the selected album
  final Failure? albumError;
  
  /// Photos in the selected album
  final List<Photo>? photos;
  
  /// Whether photos are loading
  final bool isPhotosLoading;
  
  /// Error when loading photos
  final Failure? photosError;
  
  /// Whether a photo upload is in progress
  final bool isUploading;
  
  /// Progress of the current upload (0-100)
  final int uploadProgress;
  
  /// Error when uploading a photo
  final Failure? uploadError;
  
  /// Whether an album operation is in progress
  final bool isAlbumOperationInProgress;
  
  /// Error when performing an album operation
  final Failure? albumOperationError;

  /// Constructor
  const MediaState({
    this.albums,
    this.isAlbumsLoading = false,
    this.albumsError,
    this.selectedAlbum,
    this.isAlbumLoading = false,
    this.albumError,
    this.photos,
    this.isPhotosLoading = false,
    this.photosError,
    this.isUploading = false,
    this.uploadProgress = 0,
    this.uploadError,
    this.isAlbumOperationInProgress = false,
    this.albumOperationError,
  });

  /// Initial state
  factory MediaState.initial() {
    return const MediaState();
  }

  @override
  List<Object?> get props => [
        albums,
        isAlbumsLoading,
        albumsError,
        selectedAlbum,
        isAlbumLoading,
        albumError,
        photos,
        isPhotosLoading,
        photosError,
        isUploading,
        uploadProgress,
        uploadError,
        isAlbumOperationInProgress,
        albumOperationError,
      ];

  /// Create a copy of this state with modified properties
  MediaState copyWith({
    List<PhotoAlbum>? albums,
    bool? isAlbumsLoading,
    Failure? Function()? albumsError,
    PhotoAlbum? Function()? selectedAlbum,
    bool? isAlbumLoading,
    Failure? Function()? albumError,
    List<Photo>? photos,
    bool? isPhotosLoading,
    Failure? Function()? photosError,
    bool? isUploading,
    int? uploadProgress,
    Failure? Function()? uploadError,
    bool? isAlbumOperationInProgress,
    Failure? Function()? albumOperationError,
  }) {
    return MediaState(
      albums: albums ?? this.albums,
      isAlbumsLoading: isAlbumsLoading ?? this.isAlbumsLoading,
      albumsError: albumsError != null ? albumsError() : this.albumsError,
      selectedAlbum: selectedAlbum != null ? selectedAlbum() : this.selectedAlbum,
      isAlbumLoading: isAlbumLoading ?? this.isAlbumLoading,
      albumError: albumError != null ? albumError() : this.albumError,
      photos: photos ?? this.photos,
      isPhotosLoading: isPhotosLoading ?? this.isPhotosLoading,
      photosError: photosError != null ? photosError() : this.photosError,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      uploadError: uploadError != null ? uploadError() : this.uploadError,
      isAlbumOperationInProgress: isAlbumOperationInProgress ?? this.isAlbumOperationInProgress,
      albumOperationError: albumOperationError != null ? albumOperationError() : this.albumOperationError,
    );
  }
}
