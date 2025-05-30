import 'package:flutter/material.dart';
import 'package:immigru/features/media/domain/entities/photo.dart';
import 'package:immigru/features/media/domain/entities/photo_album.dart';
import 'package:immigru/shared/theme/app_colors.dart';

/// Widget for displaying a photo item in a grid
class PhotoItem extends StatelessWidget {
  /// Photo to display
  final Photo photo;
  
  /// Callback when the photo is tapped
  final VoidCallback onTap;

  /// Constructor
  const PhotoItem({
    super.key,
    required this.photo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo image
            _buildPhotoImage(context),
            
            // Visibility indicator
            if (photo.visibility != AlbumVisibility.public)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    photo.visibility == AlbumVisibility.private
                        ? Icons.lock
                        : Icons.people,
                    size: 12,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build the photo image
  Widget _buildPhotoImage(BuildContext context) {
    // Use thumbnail if available, otherwise use the full image
    final imageUrl = photo.thumbnailUrl ?? photo.url;
    
    return Image.network(
      imageUrl,
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
    );
  }

  /// Build a placeholder for when the image fails to load
  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: AppColors.primaryColor.withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          Icons.broken_image,
          size: 24,
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
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}
