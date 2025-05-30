import 'package:flutter/material.dart';
import 'package:immigru/features/media/domain/entities/photo.dart';
import 'package:immigru/features/media/presentation/widgets/photo_item.dart';
import 'package:immigru/shared/theme/app_colors.dart';

/// Widget for displaying a grid of photos
class PhotoGrid extends StatelessWidget {
  /// List of photos to display
  final List<Photo> photos;
  
  /// Callback when a photo is tapped
  final Function(Photo) onPhotoTap;
  
  /// Callback when the add photo button is tapped
  final VoidCallback onAddPhotoTap;
  
  /// Whether the grid is loading
  final bool isLoading;
  
  /// Error message to display if there was an error loading photos
  final String? errorMessage;
  
  /// Callback when the retry button is tapped
  final VoidCallback? onRetry;

  /// Constructor
  const PhotoGrid({
    super.key,
    required this.photos,
    required this.onPhotoTap,
    required this.onAddPhotoTap,
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
              'Error loading photos',
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

    if (photos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No photos yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Add photos to this album',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onAddPhotoTap,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Add Photos'),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: photos.length + 1, // +1 for the "Add Photo" button
      itemBuilder: (context, index) {
        if (index == photos.length) {
          // Add Photo button
          return _buildAddPhotoItem(context);
        }
        
        // Photo item
        final photo = photos[index];
        return PhotoItem(
          photo: photo,
          onTap: () => onPhotoTap(photo),
        );
      },
    );
  }

  /// Build the add photo item
  Widget _buildAddPhotoItem(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onAddPhotoTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_photo_alternate,
                color: AppColors.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add Photo',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
