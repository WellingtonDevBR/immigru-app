import 'package:flutter/material.dart';
import 'package:immigru/features/profile/domain/entities/user_profile.dart';
import 'package:immigru/shared/widgets/loading_indicator.dart';

/// Widget for displaying the profile header with cover image
class ProfileHeader extends StatelessWidget {
  /// Helper method to get the appropriate image provider for a cover image
  /// Returns a NetworkImage for the cover image URL
  ImageProvider _getCoverImage() {
    // Use the public URL getter from the profile entity
    final url = profile.coverImagePublicUrl;
    
    if (url == null) {
      throw Exception('Cover image URL is null - this method should only be called when hasCoverImage is true');
    }
    
    // Return as network image
    return NetworkImage(url);
  }
  /// The user profile data
  final UserProfile profile;
  
  /// Callback for when the cover image is tapped
  final VoidCallback? onTapCoverImage;
  
  /// Whether a cover image upload is in progress
  final bool isUploadingCover;
  
  /// Whether to show mobile-specific UI elements
  final bool isMobileView;

  /// Constructor
  const ProfileHeader({
    super.key,
    required this.profile,
    this.onTapCoverImage,
    this.isUploadingCover = false,
    this.isMobileView = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Cover image
        GestureDetector(
          onTap: onTapCoverImage,
          child: Container(
            decoration: BoxDecoration(
              // Use green background color when there's no cover image
              color: !profile.hasCoverImage
                  ? Colors.green.shade600 // Green background for app theme
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              image: profile.hasCoverImage
                  ? DecorationImage(
                      image: _getCoverImage(),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            // No centered content when there's no cover image
            child: null,
          ),
        ),
        
        // Gradient overlay for better text visibility
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withValues(alpha: 0.7)
                    : Colors.black.withValues(alpha: 0.5),
              ],
              stops: const [0.6, 1.0],
            ),
          ),
        ),
        
        // Upload indicator
        if (isUploadingCover)
          Container(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingIndicator(
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Uploading cover image...',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        
        // Modern floating action button for image management (always shown when editable)
        if (isMobileView && onTapCoverImage != null && !isUploadingCover)
          Positioned(
            right: 16,
            bottom: 16,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: onTapCoverImage,
                backgroundColor: Colors.white,
                elevation: 0, // We're using our own shadow
                child: Icon(
                  profile.coverImageUrl != null && profile.coverImageUrl!.isNotEmpty
                      ? Icons.edit
                      : Icons.add_photo_alternate,
                  color: Colors.green.shade600,
                  size: 24,
                ),
              ),
            ),
          ),
        
        // Edit icon if editable (desktop style)
        if (!isMobileView && onTapCoverImage != null && !isUploadingCover)
          Positioned(
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.edit,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                size: 20,
              ),
            ),
          ),
      ],
    );
  }
}
