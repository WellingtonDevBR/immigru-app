import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/media/domain/entities/photo.dart';
import 'package:immigru/features/media/domain/entities/photo_album.dart';
import 'package:immigru/features/media/domain/usecases/add_photo_comment.dart' as domain_add_comment;
import 'package:immigru/features/media/domain/usecases/create_album.dart' as domain_create_album;
import 'package:immigru/features/media/domain/usecases/get_album_photos.dart';
import 'package:immigru/features/media/domain/usecases/get_or_create_default_album.dart' as domain_get_default_album;
import 'package:immigru/features/media/domain/usecases/get_user_albums.dart';
import 'package:immigru/features/media/domain/usecases/like_photo.dart' as domain_like_photo;
import 'package:immigru/features/media/domain/usecases/unlike_photo.dart' as domain_unlike_photo;
import 'package:immigru/features/media/domain/usecases/upload_photo.dart' as domain_upload_photo;
import 'package:immigru/features/media/presentation/bloc/media_event.dart';
import 'package:immigru/features/media/presentation/bloc/media_state.dart';

/// BLoC for managing media state
class MediaBloc extends Bloc<MediaEvent, MediaState> {
  final GetUserAlbums _getUserAlbums;
  final GetAlbumPhotos _getAlbumPhotos;
  final domain_create_album.CreateAlbum _createAlbum;
  final domain_upload_photo.UploadPhoto _uploadPhoto;
  final domain_get_default_album.GetOrCreateDefaultAlbum _getOrCreateDefaultAlbum;
  final domain_add_comment.AddPhotoComment _addPhotoComment;
  final domain_like_photo.LikePhoto _likePhoto;
  final domain_unlike_photo.UnlikePhoto _unlikePhoto;
  final UnifiedLogger _logger;

  /// Constructor
  MediaBloc({
    required GetUserAlbums getUserAlbums,
    required GetAlbumPhotos getAlbumPhotos,
    required domain_create_album.CreateAlbum createAlbum,
    required domain_upload_photo.UploadPhoto uploadPhoto,
    required domain_get_default_album.GetOrCreateDefaultAlbum getOrCreateDefaultAlbum,
    required domain_add_comment.AddPhotoComment addPhotoComment,
    required domain_like_photo.LikePhoto likePhoto,
    required domain_unlike_photo.UnlikePhoto unlikePhoto,
    required UnifiedLogger logger,
  })  : _getUserAlbums = getUserAlbums,
        _getAlbumPhotos = getAlbumPhotos,
        _createAlbum = createAlbum,
        _uploadPhoto = uploadPhoto,
        _getOrCreateDefaultAlbum = getOrCreateDefaultAlbum,
        _addPhotoComment = addPhotoComment,
        _likePhoto = likePhoto,
        _unlikePhoto = unlikePhoto,
        _logger = logger,
        super(MediaState.initial()) {
    on<LoadUserAlbums>(_onLoadUserAlbums);
    on<LoadAlbumPhotos>(_onLoadAlbumPhotos);
    on<CreateAlbum>(_onCreateAlbum);
    on<UploadPhoto>(_onUploadPhoto);
    on<UploadMultiplePhotos>(_onUploadMultiplePhotos);
    on<DeletePhoto>(_onDeletePhoto);
    on<DeleteAlbum>(_onDeleteAlbum);
    on<SetAlbumCoverPhoto>(_onSetAlbumCoverPhoto);
    on<GetOrCreateDefaultAlbum>(_onGetOrCreateDefaultAlbum);
    on<ClearMediaError>(_onClearMediaError);
    on<ClearSelectedAlbum>(_onClearSelectedAlbum);
    on<AddPhotoComment>(_onAddPhotoComment);
    on<LikePhoto>(_onLikePhoto);
    on<UnlikePhoto>(_onUnlikePhoto);
  }
  
  /// Handle AddPhotoComment event
  Future<void> _onAddPhotoComment(
    AddPhotoComment event,
    Emitter<MediaState> emit,
  ) async {
    _logger.d('Adding comment to photo ${event.photoId}', tag: 'MediaBloc');
    
    // Show loading state
    emit(state.copyWith(
      isPhotosLoading: true,
      photosError: () => null,
    ));
    
    // Call use case
    final result = await _addPhotoComment(
      domain_add_comment.AddPhotoCommentParams(
        photoId: event.photoId,
        userId: event.userId,
        userName: event.userName,
        userAvatar: event.userAvatar,
        text: event.text,
      ),
    );
    
    // Handle result
    result.fold(
      (failure) {
        _logger.e('Error adding comment: ${failure.message}', tag: 'MediaBloc');
        emit(state.copyWith(
          isPhotosLoading: false,
          photosError: () => failure,
        ));
      },
      (updatedPhoto) {
        _logger.d('Comment added successfully', tag: 'MediaBloc');
        
        // Update the photo in the state
        final List<Photo> currentPhotos = state.photos ?? [];
        final updatedPhotos = List<Photo>.from(currentPhotos);
        final photoIndex = updatedPhotos.indexWhere((p) => p.id == updatedPhoto.id);
        
        if (photoIndex != -1) {
          updatedPhotos[photoIndex] = updatedPhoto;
        }
        
        emit(state.copyWith(
          photos: updatedPhotos,
          isPhotosLoading: false,
        ));
      },
    );
  }
  
  /// Handle LikePhoto event
  Future<void> _onLikePhoto(
    LikePhoto event,
    Emitter<MediaState> emit,
  ) async {
    _logger.d('Liking photo ${event.photoId}', tag: 'MediaBloc');
    
    // Call use case
    final result = await _likePhoto(
      domain_like_photo.LikePhotoParams(
        photoId: event.photoId,
        userId: event.userId,
        userName: event.userName,
        userAvatar: event.userAvatar,
      ),
    );
    
    // Handle result
    result.fold(
      (failure) {
        _logger.e('Error liking photo: ${failure.message}', tag: 'MediaBloc');
        emit(state.copyWith(
          photosError: () => failure,
        ));
      },
      (updatedPhoto) {
        _logger.d('Photo liked successfully', tag: 'MediaBloc');
        
        // Update the photo in the state
        final List<Photo> currentPhotos = state.photos ?? [];
        final updatedPhotos = List<Photo>.from(currentPhotos);
        final photoIndex = updatedPhotos.indexWhere((p) => p.id == updatedPhoto.id);
        
        if (photoIndex != -1) {
          updatedPhotos[photoIndex] = updatedPhoto;
        }
        
        emit(state.copyWith(
          photos: updatedPhotos,
        ));
      },
    );
  }
  
  /// Handle UnlikePhoto event
  Future<void> _onUnlikePhoto(
    UnlikePhoto event,
    Emitter<MediaState> emit,
  ) async {
    _logger.d('Unliking photo ${event.photoId}', tag: 'MediaBloc');
    
    // Call use case
    final result = await _unlikePhoto(
      domain_unlike_photo.UnlikePhotoParams(
        photoId: event.photoId,
        userId: event.userId,
      ),
    );
    
    // Handle result
    result.fold(
      (failure) {
        _logger.e('Error unliking photo: ${failure.message}', tag: 'MediaBloc');
        emit(state.copyWith(
          photosError: () => failure,
        ));
      },
      (updatedPhoto) {
        _logger.d('Photo unliked successfully', tag: 'MediaBloc');
        
        // Update the photo in the state
        final List<Photo> currentPhotos = state.photos ?? [];
        final updatedPhotos = List<Photo>.from(currentPhotos);
        final photoIndex = updatedPhotos.indexWhere((p) => p.id == updatedPhoto.id);
        
        if (photoIndex != -1) {
          updatedPhotos[photoIndex] = updatedPhoto;
        }
        
        emit(state.copyWith(
          photos: updatedPhotos,
        ));
      },
    );
  }

  /// Handle LoadUserAlbums event
  Future<void> _onLoadUserAlbums(
    LoadUserAlbums event,
    Emitter<MediaState> emit,
  ) async {
    _logger.d('Loading albums for user ${event.userId}', tag: 'MediaBloc');
    
    // Show loading state
    emit(state.copyWith(
      isAlbumsLoading: true,
      albumsError: () => null,
    ));
    
    // Call use case
    final result = await _getUserAlbums(
      GetUserAlbumsParams(userId: event.userId),
    );
    
    // Handle result
    result.fold(
      (failure) {
        _logger.e('Error loading albums: ${failure.message}', tag: 'MediaBloc');
        emit(state.copyWith(
          isAlbumsLoading: false,
          albumsError: () => failure,
        ));
      },
      (albums) {
        _logger.d('Loaded ${albums.length} albums', tag: 'MediaBloc');
        final List<PhotoAlbum> typedAlbums = List<PhotoAlbum>.from(albums);
        emit(state.copyWith(
          albums: typedAlbums,
          isAlbumsLoading: false,
        ));
      },
    );
  }

  /// Handle LoadAlbumPhotos event
  Future<void> _onLoadAlbumPhotos(
    LoadAlbumPhotos event,
    Emitter<MediaState> emit,
  ) async {
    _logger.d('Loading photos for album ${event.albumId}', tag: 'MediaBloc');
    
    // Show loading state
    emit(state.copyWith(
      isPhotosLoading: true,
      photosError: () => null,
    ));
    
    // Call use case
    final result = await _getAlbumPhotos(
      GetAlbumPhotosParams(
        albumId: event.albumId,
        limit: event.limit,
        offset: event.offset,
      ),
    );
    
    // Handle result
    result.fold(
      (failure) {
        _logger.e('Error loading photos: ${failure.message}', tag: 'MediaBloc');
        emit(state.copyWith(
          isPhotosLoading: false,
          photosError: () => failure,
        ));
      },
      (photos) {
        _logger.d('Loaded ${photos.length} photos', tag: 'MediaBloc');
        final List<Photo> typedPhotos = List<Photo>.from(photos);
        emit(state.copyWith(
          photos: typedPhotos,
          isPhotosLoading: false,
        ));
      },
    );
  }

  /// Handle CreateAlbum event
  Future<void> _onCreateAlbum(
    CreateAlbum event,
    Emitter<MediaState> emit,
  ) async {
    _logger.d('Creating album "${event.name}" for user ${event.userId}', tag: 'MediaBloc');
    
    // Show loading state
    emit(state.copyWith(
      isAlbumOperationInProgress: true,
      albumOperationError: () => null,
    ));
    
    // Call use case
    final result = await _createAlbum(
      domain_create_album.CreateAlbumParams(
        userId: event.userId,
        name: event.name,
        description: event.description,
        visibility: event.visibility,
      ),
    );
    
    // Handle result
    result.fold(
      (failure) {
        _logger.e('Error creating album: ${failure.message}', tag: 'MediaBloc');
        emit(state.copyWith(
          isAlbumOperationInProgress: false,
          albumOperationError: () => failure,
        ));
      },
      (album) {
        _logger.d('Created album ${album.id}', tag: 'MediaBloc');
        
        // Add the new album to the list of albums
        final updatedAlbums = List<PhotoAlbum>.from([...(state.albums ?? []), album]);
        
        emit(state.copyWith(
          albums: updatedAlbums,
          selectedAlbum: () => album,
          isAlbumOperationInProgress: false,
        ));
      },
    );
  }

  /// Handle UploadPhoto event
  Future<void> _onUploadPhoto(
    UploadPhoto event,
    Emitter<MediaState> emit,
  ) async {
    _logger.d('Uploading photo to album ${event.albumId ?? "default"} for user ${event.userId}', 
        tag: 'MediaBloc');
    
    // Show uploading state
    emit(state.copyWith(
      isUploading: true,
      uploadProgress: 0,
      uploadError: () => null,
    ));
    
    // Call use case
    final result = await _uploadPhoto(
      domain_upload_photo.UploadPhotoParams(
        albumId: event.albumId,
        userId: event.userId,
        imageFile: event.imageFile,
        title: event.title,
        description: event.description,
        visibility: event.visibility,
      ),
    );
    
    // Handle result
    result.fold(
      (failure) {
        _logger.e('Error uploading photo: ${failure.message}', tag: 'MediaBloc');
        emit(state.copyWith(
          isUploading: false,
          uploadError: () => failure,
        ));
      },
      (photo) {
        _logger.d('Uploaded photo ${photo.id}', tag: 'MediaBloc');
        
        // Add the new photo to the list of photos if we're viewing the same album
        final updatedPhotos = state.selectedAlbum?.id == photo.albumId
            ? List<Photo>.from([...(state.photos ?? []), photo])
            : state.photos;
        
        emit(state.copyWith(
          photos: updatedPhotos,
          isUploading: false,
          uploadProgress: 100,
        ));
      },
    );
  }

  /// Handle DeletePhoto event
  Future<void> _onDeletePhoto(
    DeletePhoto event,
    Emitter<MediaState> emit,
  ) async {
    // This would be implemented with a DeletePhoto use case
    // For now, we'll just log the event
    _logger.d('Delete photo event not implemented yet', tag: 'MediaBloc');
  }

  /// Handle DeleteAlbum event
  Future<void> _onDeleteAlbum(
    DeleteAlbum event,
    Emitter<MediaState> emit,
  ) async {
    // This would be implemented with a DeleteAlbum use case
    // For now, we'll just log the event
    _logger.d('Delete album event not implemented yet', tag: 'MediaBloc');
  }

  /// Handle SetAlbumCoverPhoto event
  Future<void> _onSetAlbumCoverPhoto(
    SetAlbumCoverPhoto event,
    Emitter<MediaState> emit,
  ) async {
    // This would be implemented with a SetAlbumCoverPhoto use case
    // For now, we'll just log the event
    _logger.d('Set album cover photo event not implemented yet', tag: 'MediaBloc');
  }

  /// Handle GetOrCreateDefaultAlbum event
  Future<void> _onGetOrCreateDefaultAlbum(
    GetOrCreateDefaultAlbum event,
    Emitter<MediaState> emit,
  ) async {
    _logger.d('Getting or creating default album for user ${event.userId}', tag: 'MediaBloc');
    
    // Show loading state
    emit(state.copyWith(
      isAlbumsLoading: true,
      albumOperationError: () => null,
    ));
    
    // Get or create default album
    final result = await _getOrCreateDefaultAlbum(domain_get_default_album.GetOrCreateDefaultAlbumParams(userId: event.userId));
    
    result.fold(
      (failure) {
        _logger.e('Failed to get or create default album: ${failure.message}', tag: 'MediaBloc');
        emit(state.copyWith(
          isAlbumsLoading: false,
          albumOperationError: () => failure,
        ));
      },
      (album) {
        _logger.d('Successfully got or created default album: ${album.id}', tag: 'MediaBloc');
        emit(state.copyWith(
          isAlbumsLoading: false,
          selectedAlbum: () => album,
        ));
      },
    );
  }

  /// Handle ClearMediaError event
  void _onClearMediaError(
    ClearMediaError event,
    Emitter<MediaState> emit,
  ) {
    _logger.d('Clearing media errors', tag: 'MediaBloc');
    
    emit(state.copyWith(
      albumsError: () => null,
      albumError: () => null,
      photosError: () => null,
      uploadError: () => null,
      albumOperationError: () => null,
    ));
  }
  
  /// Handle ClearSelectedAlbum event
  void _onClearSelectedAlbum(
    ClearSelectedAlbum event,
    Emitter<MediaState> emit,
  ) {
    _logger.d('Clearing selected album', tag: 'MediaBloc');
    
    emit(state.copyWith(
      selectedAlbum: () => null,
      photos: null,
    ));
  }
  
  /// Handle UploadMultiplePhotos event
  Future<void> _onUploadMultiplePhotos(
    UploadMultiplePhotos event,
    Emitter<MediaState> emit,
  ) async {
    _logger.d('Uploading ${event.imageFiles.length} photos to album ${event.albumId} for user ${event.userId}', 
        tag: 'MediaBloc');
    
    // Show uploading state
    emit(state.copyWith(
      isUploading: true,
      uploadProgress: 0,
      uploadError: () => null,
    ));
    
    final List<Photo> uploadedPhotos = [];
    int totalPhotos = event.imageFiles.length;
    int completedUploads = 0;
    bool hasError = false;
    
    // Upload each photo sequentially
    for (final imageFile in event.imageFiles) {
      // Call use case for each photo
      final result = await _uploadPhoto(
        domain_upload_photo.UploadPhotoParams(
          albumId: event.albumId,
          userId: event.userId,
          imageFile: imageFile,
          title: event.title,
          description: event.description,
          visibility: event.visibility,
        ),
      );
      
      // Handle result for each photo
      result.fold(
        (failure) {
          _logger.e('Error uploading photo: ${failure.message}', tag: 'MediaBloc');
          hasError = true;
          // Continue with other uploads even if one fails
        },
        (photo) {
          _logger.d('Uploaded photo ${photo.id}', tag: 'MediaBloc');
          uploadedPhotos.add(photo);
        },
      );
      
      // Update progress
      completedUploads++;
      emit(state.copyWith(
        uploadProgress: (completedUploads / totalPhotos * 100).round(),
      ));
    }
    
    // Final state update after all uploads
    if (uploadedPhotos.isNotEmpty) {
      // Add the new photos to the list of photos if we're viewing the same album
      final updatedPhotos = state.selectedAlbum?.id == event.albumId
          ? List<Photo>.from([...(state.photos ?? []), ...uploadedPhotos])
          : state.photos;
      
      emit(state.copyWith(
        photos: updatedPhotos,
        isUploading: false,
        uploadProgress: 100,
        uploadError: hasError ? () => Failure(message: 'Some photos failed to upload') : null,
      ));
    } else if (hasError) {
      // All uploads failed
      emit(state.copyWith(
        isUploading: false,
        uploadError: () => const Failure(message: 'Failed to upload photos'),
      ));
    }
  }
  
  // Implementation removed as we now use the domain use case
  
  // Implementation removed as we now use the domain use case
  
  // Implementation removed as we now use the domain use case
}
