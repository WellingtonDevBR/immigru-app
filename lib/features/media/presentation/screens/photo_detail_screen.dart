import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/core/utils/file_size_formatter.dart';
import 'package:immigru/features/media/domain/entities/photo.dart';
import 'package:immigru/features/media/domain/entities/photo_album.dart';
import 'package:immigru/features/media/presentation/bloc/media_bloc.dart';
import 'package:immigru/features/media/presentation/bloc/media_event.dart';
import 'package:immigru/features/media/presentation/bloc/media_state.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:share_plus/share_plus.dart';

/// Screen for displaying a photo in detail
class PhotoDetailScreen extends StatefulWidget {
  /// Photo to display
  final Photo photo;

  /// Whether this is the current user's photo
  final bool isCurrentUser;

  /// Constructor
  const PhotoDetailScreen({
    super.key,
    required this.photo,
    this.isCurrentUser = false,
  });

  @override
  State<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<PhotoDetailScreen> {
  final UnifiedLogger _logger = GetIt.instance<UnifiedLogger>();
  late final MediaBloc _mediaBloc;

  bool _showControls = true;
  bool _showInfo = false;
  bool _showComments = false;

  // Controller for the comment text field
  final TextEditingController _commentController = TextEditingController();
  String? _currentUserId;
  String? _currentUserName;
  String? _currentUserAvatar;

  @override
  void initState() {
    super.initState();

    // Get the MediaBloc from the provider
    _mediaBloc = context.read<MediaBloc>();

    // Get current user information
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      _currentUserId = currentUser.id;
      _currentUserName = currentUser.userMetadata?['name'] as String? ?? 
                         currentUser.email?.split('@').first ?? 
                         'User';
      _currentUserAvatar = currentUser.userMetadata?['avatar_url'] as String?;
    }

    // Set preferred orientation to landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Reset preferred orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // Dispose of the comment controller
    _commentController.dispose();

    super.dispose();
  }

  /// Toggle controls visibility
  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (!_showControls) {
        _showInfo = false;
      }
    });
  }

  /// Toggle info panel visibility
  void _toggleInfo() {
    setState(() {
      _showInfo = !_showInfo;
    });
  }

  /// Share the photo
  void _sharePhoto() {
    _logger.d('Sharing photo ${widget.photo.id}', tag: 'PhotoDetailScreen');

    Share.share(
      'Check out this photo: ${widget.photo.url}',
      subject: widget.photo.title ?? 'Shared photo',
    );
  }

  /// Delete the photo
  void _deletePhoto() {
    _logger.d('Deleting photo ${widget.photo.id}', tag: 'PhotoDetailScreen');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Photo'),
        content: const Text(
            'Are you sure you want to delete this photo? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);

              // Delete the photo
              _mediaBloc.add(
                DeletePhoto(photoId: widget.photo.id),
              );

              // Go back to the album
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Set this photo as the album cover
  void _setAsAlbumCover() {
    _logger.d(
        'Setting photo ${widget.photo.id} as cover for album ${widget.photo.albumId}',
        tag: 'PhotoDetailScreen');

    _mediaBloc.add(
      SetAlbumCoverPhoto(
        albumId: widget.photo.albumId,
        photoId: widget.photo.id,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Set as album cover')),
    );
  }

  /// Toggle comments section visibility
  void _toggleComments() {
    setState(() {
      _showComments = !_showComments;
    });
  }

  /// Like the photo
  void _likePhoto() {
    if (_currentUserId == null) {
      // Show login prompt if user is not logged in
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to like photos')),
      );
      return;
    }
    
    if (widget.photo.likes?.any((like) => like.userId == _currentUserId) ??
        false) {
      // User already liked the photo, so unlike it
      _mediaBloc.add(
        UnlikePhoto(
          photoId: widget.photo.id,
          userId: _currentUserId!,
        ),
      );
    } else {
      // User hasn't liked the photo, so like it
      _mediaBloc.add(
        LikePhoto(
          photoId: widget.photo.id,
          userId: _currentUserId!,
          userName: _currentUserName ?? 'User',
          userAvatar: _currentUserAvatar,
        ),
      );
    }
  }

  /// Add a comment to the photo
  void _addComment() {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;
    
    if (_currentUserId == null) {
      // Show login prompt if user is not logged in
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add comments')),
      );
      return;
    }

    _mediaBloc.add(
      AddPhotoComment(
        photoId: widget.photo.id,
        userId: _currentUserId!,
        userName: _currentUserName ?? 'User',
        userAvatar: _currentUserAvatar,
        text: commentText,
      ),
    );

    // Clear the comment field
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<MediaBloc, MediaState>(
        bloc: _mediaBloc,
        builder: (context, state) {
          // Get the latest version of the photo from the state if available
          final Photo currentPhoto = state.photos?.firstWhere(
                (p) => p.id == widget.photo.id,
                orElse: () => widget.photo,
              ) ??
              widget.photo;

          return Stack(
            fit: StackFit.expand,
            children: [
              // Photo
              GestureDetector(
                onTap: _toggleControls,
                child: Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 3.0,
                    child: Hero(
                      tag: 'photo_${currentPhoto.id}',
                      child: Image.network(
                        currentPhoto.url,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.white,
                              size: 48,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // Controls
              if (_showControls)
                AnimatedOpacity(
                  opacity: _showControls ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                        stops: const [0.0, 0.2, 0.8, 1.0],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Top bar
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Back button
                                IconButton(
                                  icon: const Icon(Icons.arrow_back),
                                  color: Colors.white,
                                  onPressed: () => Navigator.pop(context),
                                ),

                                const Spacer(),

                                // Info button
                                IconButton(
                                  icon: const Icon(Icons.info_outline),
                                  color: Colors.white,
                                  onPressed: _toggleInfo,
                                ),

                                // Comments button
                                IconButton(
                                  icon: const Icon(Icons.comment),
                                  color: Colors.white,
                                  onPressed: _toggleComments,
                                ),

                                // Share button
                                IconButton(
                                  icon: const Icon(Icons.share),
                                  color: Colors.white,
                                  onPressed: _sharePhoto,
                                ),

                                // More options for owner
                                if (widget.isCurrentUser)
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert,
                                        color: Colors.white),
                                    onSelected: (value) {
                                      if (value == 'delete') {
                                        _deletePhoto();
                                      } else if (value == 'cover') {
                                        _setAsAlbumCover();
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem<String>(
                                        value: 'cover',
                                        child: Text('Set as album cover'),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Text('Delete',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),

                          // Photo title and description
                          if (currentPhoto.title != null ||
                              currentPhoto.description != null)
                            Container(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (currentPhoto.title != null)
                                    Text(
                                      currentPhoto.title!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  if (currentPhoto.description != null)
                                    Text(
                                      currentPhoto.description!,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.8),
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),

                          // Like and comment buttons
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Like button
                                IconButton(
                                  icon: Icon(
                                    currentPhoto.likes != null && currentPhoto.likes!.any((like) => like.userId == 'current_user_id')
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: currentPhoto.likes != null && currentPhoto.likes!.any((like) => like.userId == 'current_user_id')
                                        ? Colors.red
                                        : Colors.white,
                                  ),
                                  onPressed: _likePhoto,
                                ),
                                Text(
                                  '${currentPhoto.likeCount ?? 0}',
                                  style: const TextStyle(color: Colors.white),
                                ),

                                const SizedBox(width: 16),

                                // Comment button
                                IconButton(
                                  icon: const Icon(Icons.comment,
                                      color: Colors.white),
                                  onPressed: _toggleComments,
                                ),
                                Text(
                                  '${currentPhoto.commentCount ?? 0}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Info panel
              if (_showInfo && _showControls)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 56,
                  right: 0,
                  width: size.width * 0.7,
                  child: Card(
                    margin: const EdgeInsets.all(16),
                    color: theme.colorScheme.surface.withValues(alpha: 0.9),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Photo Information',
                            style: theme.textTheme.titleMedium,
                          ),

                          const Divider(),

                          // Photo details
                          _buildInfoRow(
                              'Date', _formatDate(currentPhoto.createdAt)),
                          _buildInfoRow(
                              'Size', _formatFileSize(currentPhoto.size)),
                          if (currentPhoto.width != null &&
                              currentPhoto.height != null)
                            _buildInfoRow('Dimensions',
                                '${currentPhoto.width} × ${currentPhoto.height}'),
                          if (currentPhoto.format != null)
                            _buildInfoRow(
                                'Format', currentPhoto.format!.toUpperCase()),

                          _buildInfoRow('Visibility',
                              _formatVisibility(currentPhoto.visibility)),
                          _buildInfoRow(
                              'Likes', '${currentPhoto.likeCount ?? 0}'),
                          _buildInfoRow(
                              'Comments', '${currentPhoto.commentCount ?? 0}'),
                        ],
                      ),
                    ),
                  ),
                ),

              // Comments panel
              if (_showComments && _showControls)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: size.height * 0.5,
                  child: Container(
                    color: theme.colorScheme.surface,
                    child: SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: _toggleComments,
                                ),
                                Text(
                                  'Comments (${currentPhoto.commentCount ?? 0})',
                                  style: theme.textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ),

                          const Divider(height: 1),

                          // Comments list
                          Expanded(
                            child: currentPhoto.comments != null &&
                                    currentPhoto.comments!.isNotEmpty
                                ? ListView.builder(
                                    itemCount: currentPhoto.comments!.length,
                                    itemBuilder: (context, index) {
                                      final comment =
                                          currentPhoto.comments![index];
                                      return ListTile(
                                        leading: CircleAvatar(
                                          backgroundImage: comment.userAvatar !=
                                                  null
                                              ? NetworkImage(comment.userAvatar!)
                                              : null,
                                          child: comment.userAvatar == null
                                              ? Text(comment.userName[0])
                                              : null,
                                        ),
                                        title: Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                comment.userName,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _formatDate(comment.createdAt),
                                              style: theme.textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                        subtitle: Text(comment.text),
                                      );
                                    },
                                  )
                                : const Center(
                                    child: Text('No comments yet'),
                                  ),
                          ),

                          // Comment input - Wrap in a container with fixed height to avoid overflow
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _commentController,
                                    decoration: const InputDecoration(
                                      hintText: 'Add a comment...',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.send),
                                  onPressed: _addComment,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Build an info row with label and value
Widget _buildInfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    ),
  );
}

/// Format a date for display
String _formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
}

/// Format a file size for display
String _formatFileSize(int? size) {
  return FileSizeFormatter.formatFileSize(size);
}

/// Format visibility for display
String _formatVisibility(AlbumVisibility visibility) {
  switch (visibility) {
    case AlbumVisibility.public:
      return 'Public';
    case AlbumVisibility.friends:
      return 'Friends';
    case AlbumVisibility.private:
      return 'Private';
  }
}
