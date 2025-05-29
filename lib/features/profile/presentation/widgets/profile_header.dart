import 'package:flutter/material.dart';
import 'package:immigru/features/profile/domain/entities/user_profile.dart';
import 'package:immigru/shared/widgets/loading_indicator.dart';
import 'dart:ui';

/// Widget for displaying the profile header with cover image
class ProfileHeader extends StatelessWidget {
  /// Helper method to get the appropriate image provider for a cover image
  /// Returns a NetworkImage for the cover image URL
  ImageProvider _getCoverImage() {
    // Use the public URL getter from the profile entity
    final url = profile.coverImagePublicUrl;

    if (url == null) {
      throw Exception(
          'Cover image URL is null - this method should only be called when hasCoverImage is true');
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        // Cover image with animated loading effect
        GestureDetector(
          onTap: onTapCoverImage,
          child: Hero(
            tag: 'cover-${profile.user.id}',
            child: Container(
              decoration: BoxDecoration(
                // Use a gradient background when there's no cover image
                gradient: !profile.hasCoverImage
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          primaryColor,
                          primaryColor.withValues(alpha: 0.7),
                        ],
                      )
                    : null,
                image: profile.hasCoverImage
                    ? DecorationImage(
                        image: _getCoverImage(),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              // Add subtle pattern overlay for more visual interest
              child: !profile.hasCoverImage
                  ? Opacity(
                      opacity: 0.1,
                      child: Image.asset(
                        'assets/images/pattern_overlay.png',
                        fit: BoxFit.cover,
                      ),
                    )
                  : null,
            ),
          ),
        ),

        // Modern gradient overlay with animated properties
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: isDark ? 0.8 : 0.6),
              ],
              stops: const [0.5, 1.0],
            ),
          ),
        ),

        // Subtle top gradient for status bar visibility
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 60,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Upload indicator with animated transition
        if (isUploadingCover)
          AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 300),
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: theme.colorScheme.surface.withValues(alpha: 0.5),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LoadingIndicator(
                          size: 40,
                          color: primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Uploading cover image...',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Modern floating action button for image management with animated effects
        if (isMobileView && onTapCoverImage != null && !isUploadingCover)
          Positioned(
            right: 16,
            bottom: 16,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTapCoverImage,
                    borderRadius: BorderRadius.circular(30),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryColor,
                            primaryColor.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Container(
                        width: 60,
                        height: 60,
                        alignment: Alignment.center,
                        child: Icon(
                          profile.hasCoverImage
                              ? Icons.edit_outlined
                              : Icons.add_photo_alternate_outlined,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Edit icon if editable (desktop style) with hover effect
        if (!isMobileView && onTapCoverImage != null && !isUploadingCover)
          Positioned(
            right: 16,
            bottom: 16,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor,
                      primaryColor.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
