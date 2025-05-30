import 'package:flutter/material.dart';
import 'package:immigru/features/media/domain/entities/photo_album.dart';
import 'package:immigru/features/media/presentation/widgets/album_item.dart';
import 'package:immigru/shared/theme/app_colors.dart';

/// Widget for displaying a grid of albums
class AlbumGrid extends StatelessWidget {
  /// List of albums to display
  final List<PhotoAlbum> albums;
  
  /// Callback when an album is tapped
  final Function(PhotoAlbum) onAlbumTap;
  
  /// Callback when the create album button is tapped
  final VoidCallback onCreateAlbumTap;
  
  /// Whether the grid is loading
  final bool isLoading;
  
  /// Error message to display if there was an error loading albums
  final String? errorMessage;
  
  /// Callback when the retry button is tapped
  final VoidCallback? onRetry;

  /// Constructor
  const AlbumGrid({
    super.key,
    required this.albums,
    required this.onAlbumTap,
    required this.onCreateAlbumTap,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error loading albums',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (onRetry != null)
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: albums.length + 1, // +1 for the "Create Album" button
      itemBuilder: (context, index) {
        if (index == albums.length) {
          // Create Album button
          return _buildCreateAlbumItem(context);
        }
        
        // Album item
        final album = albums[index];
        return AlbumItem(
          album: album,
          onTap: () => onAlbumTap(album),
        );
      },
    );
  }

  /// Build the create album item
  Widget _buildCreateAlbumItem(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onCreateAlbumTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_photo_alternate,
                color: AppColors.primaryColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create Album',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
