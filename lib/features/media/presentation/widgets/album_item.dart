import 'package:flutter/material.dart';
import 'package:immigru/features/media/domain/entities/photo_album.dart';
import 'package:immigru/shared/theme/app_colors.dart';

/// Widget for displaying an album item in a grid
class AlbumItem extends StatelessWidget {
  /// Album to display
  final PhotoAlbum album;
  
  /// Callback when the album is tapped
  final VoidCallback onTap;

  /// Constructor
  const AlbumItem({
    super.key,
    required this.album,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Album cover image
            Expanded(
              child: _buildAlbumCover(context),
            ),
            
            // Album info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Album name
                  Text(
                    album.name,
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Photo count
                  Row(
                    children: [
                      Icon(
                        Icons.photo,
                        size: 16,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${album.photoCount} ${album.photoCount == 1 ? 'photo' : 'photos'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the album cover image
  Widget _buildAlbumCover(BuildContext context) {
    final theme = Theme.of(context);
    
    // If there's a cover photo, display it
    if (album.coverPhotoUrl != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          // Cover photo
          Image.network(
            album.coverPhotoUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder(context);
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }
              return _buildLoadingPlaceholder(context);
            },
          ),
          
          // Visibility indicator
          if (album.visibility != AlbumVisibility.public)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      album.visibility == AlbumVisibility.private
                          ? Icons.lock
                          : Icons.people,
                      size: 14,
                      color: theme.colorScheme.onSurface,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      album.visibility == AlbumVisibility.private
                          ? 'Private'
                          : 'Friends',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    }
    
    // If there's no cover photo, display a placeholder
    return _buildPlaceholder(context);
  }

  /// Build a placeholder for when there's no cover photo
  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: AppColors.primaryColor.withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          Icons.photo_library,
          size: 48,
          color: AppColors.primaryColor.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  /// Build a loading placeholder
  Widget _buildLoadingPlaceholder(BuildContext context) {
    return Container(
      color: AppColors.primaryColor.withValues(alpha: 0.1),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
