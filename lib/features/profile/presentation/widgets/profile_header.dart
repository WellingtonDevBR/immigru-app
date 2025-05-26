import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:immigru/core/storage/i_supabase_storage.dart';
import 'package:immigru/features/profile/domain/entities/user_profile.dart';
import 'package:immigru/shared/widgets/loading_indicator.dart';

/// Widget for displaying the profile header with cover image
class ProfileHeader extends StatelessWidget {
  /// Helper method to get the appropriate image provider for a cover image
  /// Returns an AssetImage as fallback when URL is invalid
  ImageProvider _getCoverImage(String url) {
    // Get the processed URL from SupabaseStorageUtils
    final processedUrl = GetIt.instance<ISupabaseStorage>().getImageUrl(
      url,
      displayName: profile.displayName,
    );
    
    // Check if it's an asset path
    if (processedUrl.startsWith('assets/')) {
      return AssetImage(processedUrl);
    }
    
    // Otherwise treat as network image
    return NetworkImage(processedUrl);
  }
  /// The user profile data
  final UserProfile profile;
  
  /// Callback for when the cover image is tapped
  final VoidCallback? onTapCoverImage;
  
  /// Whether a cover image upload is in progress
  final bool isUploadingCover;

  /// Constructor
  const ProfileHeader({
    super.key,
    required this.profile,
    this.onTapCoverImage,
    this.isUploadingCover = false,
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
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              image: profile.coverImageUrl != null && profile.coverImageUrl!.isNotEmpty
                  ? DecorationImage(
                      image: _getCoverImage(profile.coverImageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: profile.coverImageUrl == null
                ? Center(
                    child: Icon(
                      Icons.image,
                      size: 50,
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  )
                : null,
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
              child: LoadingIndicator(
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        
        // Edit icon if editable
        if (onTapCoverImage != null && !isUploadingCover)
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
