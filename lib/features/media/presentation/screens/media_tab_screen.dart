import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/features/auth/domain/entities/user.dart';
import 'package:immigru/features/media/domain/entities/photo.dart';
import 'package:immigru/features/media/domain/entities/photo_album.dart';
import 'package:immigru/features/media/presentation/bloc/media_bloc.dart';
import 'package:immigru/features/media/presentation/bloc/media_event.dart';
import 'package:immigru/features/media/presentation/bloc/media_state.dart';
import 'package:immigru/features/media/presentation/screens/photo_detail_screen.dart';
import 'package:immigru/features/media/presentation/widgets/album_grid.dart';
import 'package:immigru/features/media/presentation/widgets/photo_grid.dart';
import 'package:immigru/shared/widgets/error_message_widget.dart';

/// Screen for displaying the media tab in the profile screen
class MediaTabScreen extends StatefulWidget {
  /// User whose media to display
  final User user;
  
  /// Whether this is the current user's profile
  final bool isCurrentUser;
  
  /// Constructor
  const MediaTabScreen({
    super.key,
    required this.user,
    this.isCurrentUser = false,
  });

  @override
  State<MediaTabScreen> createState() => _MediaTabScreenState();
}

class _MediaTabScreenState extends State<MediaTabScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final UnifiedLogger _logger = GetIt.instance<UnifiedLogger>();
  
  bool _isViewingAlbum = false;
  PhotoAlbum? _selectedAlbum;
  XFile? _pendingPhotoForUpload;
  
  // Debounce variables to prevent multiple requests
  String? _lastLoadedAlbumId;
  DateTime? _lastPhotoLoadTime;
  bool _isUploadComplete = false;
  DateTime? _lastUploadCompleteTime;
  
  // Track upload state changes
  bool _wasUploading = false;
  
  // Album loading debounce
  bool _albumsLoaded = false;
  DateTime? _lastAlbumsLoadTime;

  @override
  void initState() {
    super.initState();
    // Load albums once when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadUserAlbums();
      }
    });
  }

  /// Load the user's albums
  void _loadUserAlbums() {
    // Implement debounce logic to prevent redundant requests
    final now = DateTime.now();
    
    // If we've already loaded albums and it's been less than 1 second since the last request, skip
    if (_albumsLoaded && 
        _lastAlbumsLoadTime != null && 
        now.difference(_lastAlbumsLoadTime!).inMilliseconds < 1000) {
      _logger.d('Skipping redundant album load for user ${widget.user.id}', tag: 'MediaTabScreen');
      return;
    }
    
    _logger.d('Loading albums for user ${widget.user.id}', tag: 'MediaTabScreen');
    
    // Update debounce tracking
    _albumsLoaded = true;
    _lastAlbumsLoadTime = now;
    
    context.read<MediaBloc>().add(LoadUserAlbums(userId: widget.user.id));
  }

  /// Load photos for the selected album
  void _loadAlbumPhotos(String albumId) {
    // Implement debounce logic to prevent redundant requests
    final now = DateTime.now();
    
    // If we're already loading this album and it's been less than 1 second since the last request, skip
    if (_lastLoadedAlbumId == albumId && 
        _lastPhotoLoadTime != null && 
        now.difference(_lastPhotoLoadTime!).inMilliseconds < 500) {
      _logger.d('Skipping redundant photo load for album $albumId', tag: 'MediaTabScreen');
      return;
    }
    
    _logger.d('Loading photos for album $albumId', tag: 'MediaTabScreen');
    
    // Update debounce tracking
    _lastLoadedAlbumId = albumId;
    _lastPhotoLoadTime = now;
    
    context.read<MediaBloc>().add(LoadAlbumPhotos(albumId: albumId));
  }

  /// Show the create album dialog
  Future<void> _showCreateAlbumDialog() async {
    if (!widget.isCurrentUser) return;
    
    // Capture the MediaBloc before showing the dialog to avoid context issues
    final mediaBloc = context.read<MediaBloc>();
    
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    AlbumVisibility visibility = AlbumVisibility.private;
    
    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text('Create Album'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Album name
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Album Name',
                    hintText: 'Enter album name',
                  ),
                  maxLength: 100,
                ),
                
                const SizedBox(height: 16),
                
                // Album description
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'Enter album description',
                  ),
                  maxLength: 500,
                  maxLines: 3,
                ),
                
                const SizedBox(height: 16),
                
                // Album visibility
                const Text('Visibility'),
                
                RadioListTile<AlbumVisibility>(
                  title: const Text('Private'),
                  subtitle: const Text('Only you can see this album'),
                  value: AlbumVisibility.private,
                  groupValue: visibility,
                  onChanged: (value) {
                    setState(() {
                      visibility = value!;
                    });
                  },
                ),
                
                RadioListTile<AlbumVisibility>(
                  title: const Text('Friends'),
                  subtitle: const Text('Your friends can see this album'),
                  value: AlbumVisibility.friends,
                  groupValue: visibility,
                  onChanged: (value) {
                    setState(() {
                      visibility = value!;
                    });
                  },
                ),
                
                RadioListTile<AlbumVisibility>(
                  title: const Text('Public'),
                  subtitle: const Text('Everyone can see this album'),
                  value: AlbumVisibility.public,
                  groupValue: visibility,
                  onChanged: (value) {
                    setState(() {
                      visibility = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Please enter an album name')),
                  );
                  return;
                }
                
                Navigator.pop(dialogContext);
                
                // Create the album using the captured MediaBloc instance
                mediaBloc.add(
                  CreateAlbum(
                    userId: widget.user.id,
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim().isNotEmpty
                        ? descriptionController.text.trim()
                        : null,
                    visibility: visibility,
                  ),
                );
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  /// Show the add photo dialog
  Future<void> _showAddPhotoDialog(String albumId) async {
    if (!widget.isCurrentUser) return;
    
    await showModalBottomSheet(
      context: context,
      builder: (dialogContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(dialogContext);
                _takePhoto(albumId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(dialogContext);
                _pickPhoto(albumId);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Take a photo with the camera
  Future<void> _takePhoto(String albumId) async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (photo != null) {
        _uploadPhoto(albumId, photo);
      }
    } catch (e) {
      _logger.e('Error taking photo: $e', tag: 'MediaTabScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking photo: $e')),
        );
      }
    }
  }

  /// Pick a photo from the gallery
  Future<void> _pickPhoto(String albumId) async {
    try {
      final List<XFile> photos = await _imagePicker.pickMultiImage(
        imageQuality: 80,
      );
      
      if (photos.isNotEmpty) {
        if (photos.length == 1) {
          // Single photo upload
          _uploadPhoto(albumId, photos.first);
        } else {
          // Multiple photo upload
          _uploadMultiplePhotos(albumId, photos);
        }
      }
    } catch (e) {
      _logger.e('Error picking photos: $e', tag: 'MediaTabScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking photos: $e')),
        );
      }
    }
  }

  /// Upload a photo to an album
  void _uploadPhoto(String albumId, XFile photo) {
    _logger.d('Uploading photo to album $albumId', tag: 'MediaTabScreen');
    
    // Show a loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Uploading photo...')),
    );
    
    context.read<MediaBloc>().add(
      UploadPhoto(
        albumId: albumId,
        userId: widget.user.id,
        imageFile: photo,
      ),
    );
  }
  
  /// Upload multiple photos to an album
  void _uploadMultiplePhotos(String albumId, List<XFile> photos) {
    _logger.d('Uploading ${photos.length} photos to album $albumId', tag: 'MediaTabScreen');
    
    // Show a loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Uploading ${photos.length} photos...')),
    );
    
    context.read<MediaBloc>().add(
      UploadMultiplePhotos(
        albumId: albumId,
        userId: widget.user.id,
        imageFiles: photos,
      ),
    );
  }

  /// View a photo in detail
  void _viewPhoto(Photo photo) {
    // Get the MediaBloc instance before navigating
    final mediaBloc = context.read<MediaBloc>();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: mediaBloc,
          child: PhotoDetailScreen(
            photo: photo,
            isCurrentUser: widget.isCurrentUser,
          ),
        ),
      ),
    );
  }

  /// Show the add photo dialog for direct upload without selecting an album first
  Future<void> _showAddPhotoDirectlyDialog() async {
    if (!widget.isCurrentUser) return;
    
    // Capture the MediaBloc before showing the dialog to avoid context issues
    final mediaBloc = context.read<MediaBloc>();
    
    await showModalBottomSheet(
      context: context,
      builder: (dialogContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(dialogContext);
                _takePhotoDirectly(mediaBloc);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(dialogContext);
                _pickPhotoDirectly(mediaBloc);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Take a photo with the camera and upload to default album
  Future<void> _takePhotoDirectly([MediaBloc? bloc]) async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (photo != null) {
        // Get or create default album and then upload
        _logger.d('Getting default album for direct upload', tag: 'MediaTabScreen');
        
        // Use the provided bloc if available, otherwise try to get it from context
        final mediaBloc = bloc ?? context.read<MediaBloc>();
        mediaBloc.add(GetOrCreateDefaultAlbum(userId: widget.user.id));
        
        // The photo will be uploaded when the default album is retrieved in the listener
        _pendingPhotoForUpload = photo;
      }
    } catch (e) {
      _logger.e('Error taking photo: $e', tag: 'MediaTabScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking photo: $e')),
        );
      }
    }
  }

  /// Pick a photo from gallery and upload to default album
  Future<void> _pickPhotoDirectly([MediaBloc? bloc]) async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (photo != null) {
        // Get or create default album and then upload
        _logger.d('Getting default album for direct upload', tag: 'MediaTabScreen');
        
        // Use the provided bloc if available, otherwise try to get it from context
        final mediaBloc = bloc ?? context.read<MediaBloc>();
        mediaBloc.add(GetOrCreateDefaultAlbum(userId: widget.user.id));
        
        // The photo will be uploaded when the default album is retrieved in the listener
        _pendingPhotoForUpload = photo;
      }
    } catch (e) {
      _logger.e('Error picking photo: $e', tag: 'MediaTabScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking photo: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return BlocConsumer<MediaBloc, MediaState>(
      listener: (context, state) {
        // Handle errors
        if (state.albumsError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading albums: ${state.albumsError!.message}')),
          );
        }
        
        if (state.photosError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading photos: ${state.photosError!.message}')),
          );
        }
        
        if (state.uploadError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading photo: ${state.uploadError!.message}')),
          );
        }
        
        if (state.albumOperationError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.albumOperationError!.message}')),
          );
        }
        
        // When a photo upload completes successfully (transition from uploading to not uploading)
        if (_wasUploading && !state.isUploading && state.uploadProgress == 100 && !_isUploadComplete) {
          // Show success message only once
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo uploaded successfully')),
          );
          
          // Mark upload as complete to prevent multiple messages
          _isUploadComplete = true;
          _lastUploadCompleteTime = DateTime.now();
          
          // Reload photos for the current album if we're viewing an album
          if (_isViewingAlbum && _selectedAlbum != null) {
            _loadAlbumPhotos(_selectedAlbum!.id);
          }
        }
        
        // Update tracking variable for next state change
        _wasUploading = state.isUploading;
        
        // Reset upload complete flag after 2 seconds to allow future uploads
        if (_isUploadComplete && _lastUploadCompleteTime != null &&
            DateTime.now().difference(_lastUploadCompleteTime!).inSeconds >= 2) {
          _isUploadComplete = false;
        }
        
        // When an album is created or retrieved, select it and view its photos
        if (state.selectedAlbum != null) {
          setState(() {
            _selectedAlbum = state.selectedAlbum;
            _isViewingAlbum = true;
          });
          
          _loadAlbumPhotos(state.selectedAlbum!.id);
          
          // If we have a pending photo for upload, upload it now
          if (_pendingPhotoForUpload != null) {
            _uploadPhoto(state.selectedAlbum!.id, _pendingPhotoForUpload!);
            _pendingPhotoForUpload = null;
          }
        }
      },
      builder: (context, state) {
        // Show loading indicator if loading albums for the first time
        if (state.isAlbumsLoading && state.albums == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        // Show error message if there was an error loading albums
        if (state.albumsError != null && state.albums == null) {
          return ErrorMessageWidget(
            message: 'Error loading albums: ${state.albumsError!.message}',
            onRetry: _loadUserAlbums,
          );
        }
        
        // If viewing an album, show the photo grid
        if (_isViewingAlbum && _selectedAlbum != null) {
          return Column(
            children: [
              // Album header
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Back button
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        // Clear the selected album in the MediaBloc state first
                        context.read<MediaBloc>().add(ClearSelectedAlbum());
                        
                        // Then update local state
                        setState(() {
                          _isViewingAlbum = false;
                          _selectedAlbum = null;
                        });
                        
                        // Clear any pending photo loads to prevent stale data
                        _lastLoadedAlbumId = null;
                        _lastPhotoLoadTime = null;
                        
                        // Force a reload of the albums to ensure we're showing the latest data
                        _loadUserAlbums();
                      },
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Album name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedAlbum!.name,
                            style: Theme.of(context).textTheme.titleLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          if (_selectedAlbum!.description != null)
                            Text(
                              _selectedAlbum!.description!,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    
                    // Photo count
                    Text(
                      '${_selectedAlbum!.photoCount} ${_selectedAlbum!.photoCount == 1 ? 'photo' : 'photos'}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              
              // Photo grid
              Expanded(
                child: PhotoGrid(
                  photos: state.photos ?? [],
                  onPhotoTap: _viewPhoto,
                  onAddPhotoTap: () => _showAddPhotoDialog(_selectedAlbum!.id),
                  isLoading: state.isPhotosLoading && state.photos == null,
                  errorMessage: state.photosError?.message,
                  onRetry: () => _loadAlbumPhotos(_selectedAlbum!.id),
                ),
              ),
            ],
          );
        }
        
        // Otherwise, show the album grid
        return Stack(
          children: [
            AlbumGrid(
              albums: state.albums ?? [],
              onAlbumTap: (album) {
                // Check if we're already viewing this album to prevent redundant state changes
                if (_selectedAlbum?.id == album.id && _isViewingAlbum) {
                  return;
                }
                
                // Update state immediately
                setState(() {
                  _selectedAlbum = album;
                  _isViewingAlbum = true;
                });
                
                // Load photos with debounce logic
                _loadAlbumPhotos(album.id);
              },
              onCreateAlbumTap: _showCreateAlbumDialog,
              isLoading: state.isAlbumsLoading,
              errorMessage: state.albumsError?.message,
              onRetry: _loadUserAlbums,
            ),
            
            // Add photo directly FAB (only for current user)
            if (widget.isCurrentUser)
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton(
                  onPressed: _showAddPhotoDirectlyDialog,
                  tooltip: 'Add Photo',
                  child: const Icon(Icons.add_a_photo),
                ),
              ),
          ],
        );
      },
    );
  }
}
