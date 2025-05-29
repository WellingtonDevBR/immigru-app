import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:immigru/core/storage/i_supabase_storage.dart';
import 'package:immigru/features/profile/domain/entities/user_profile.dart';
import 'package:immigru/shared/widgets/loading_indicator.dart';

/// Widget for displaying the profile stats section with avatar and counters
class ProfileStatsSection extends StatelessWidget {
  /// Helper method to get the appropriate image provider for a profile image
  /// Returns a fallback image when URL is invalid
  ImageProvider _getProfileImage(String? url) {
    if (url == null || url.isEmpty) {
      // Return UI Avatars as fallback
      final displayName =
          profile.displayName.isEmpty ? "User" : profile.displayName;
      final fallbackUrl =
          'https://ui-avatars.com/api/?background=2eaa76&color=FFFFFF&name=${Uri.encodeComponent(displayName)}';
      debugPrint('DEBUG: Using fallback avatar: $fallbackUrl');
      return NetworkImage(fallbackUrl);
    }

    try {
      // If URL is already a full URL, use it directly
      if (url.startsWith('http')) {
        debugPrint('DEBUG: Using direct avatar URL: $url');
        return NetworkImage(url);
      }

      // For file names, get the processed URL from SupabaseStorageUtils
      final processedUrl = GetIt.instance<ISupabaseStorage>().getImageUrl(
        url,
        displayName: profile.displayName,
      );

      // Check if it's an asset path
      if (processedUrl.startsWith('assets/')) {
        return AssetImage(processedUrl);
      }

      // Otherwise treat as network image
      debugPrint('DEBUG: Using processed avatar URL: $processedUrl');
      return NetworkImage(processedUrl);
    } catch (e) {
      debugPrint('Error loading profile image: $e');
      // Return UI Avatars as fallback
      final displayName =
          profile.displayName.isEmpty ? "User" : profile.displayName;
      final fallbackUrl =
          'https://ui-avatars.com/api/?background=2eaa76&color=FFFFFF&name=${Uri.encodeComponent(displayName)}';
      debugPrint('DEBUG: Using fallback avatar after error: $fallbackUrl');
      return NetworkImage(fallbackUrl);
    }
  }

  /// The user profile data
  final UserProfile profile;

  /// User stats (posts, followers, following)
  final Map<String, int>? stats;

  /// Whether stats are currently loading
  final bool isStatsLoading;

  /// Callback for when the avatar is tapped
  final VoidCallback? onTapAvatar;

  /// Whether an avatar upload is in progress
  final bool isUploadingAvatar;

  /// Constructor
  const ProfileStatsSection({
    super.key,
    required this.profile,
    this.stats,
    this.isStatsLoading = false,
    this.onTapAvatar,
    this.isUploadingAvatar = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Profile header with centered avatar and name below
        Column(
          children: [
            // Avatar with larger size and positioned up for overlap with cover
            Center(
              child: Center(
                // Position avatar exactly half on cover image and half below
                // offset: const Offset(0, -60),
                child: GestureDetector(
                  onTap: onTapAvatar,
                  child: Stack(
                    children: [
                      // Avatar container with animation
                      Hero(
                        tag: 'avatar-${profile.user.id}',
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.scaffoldBackgroundColor,
                              width: 4,
                            ),
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
                            shape: const CircleBorder(),
                            clipBehavior: Clip.hardEdge,
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Ink(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: profile.avatarUrl != null
                                      ? _getProfileImage(profile.avatarUrl)
                                      : NetworkImage(
                                          'https://ui-avatars.com/api/?background=2eaa76&color=FFFFFF&name=${Uri.encodeComponent(profile.displayName.isEmpty ? "User" : profile.displayName)}'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: profile.avatarUrl == null
                                  ? Center(
                                      child: Text(
                                        profile.displayName.isNotEmpty
                                            ? profile.displayName[0]
                                                .toUpperCase()
                                            : '?',
                                        style: TextStyle(
                                          fontSize: 42,
                                          fontWeight: FontWeight.bold,
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),

                      // Camera icon button for profile picture edit
                      if (onTapAvatar != null && !isUploadingAvatar)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.scaffoldBackgroundColor,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),

                      // Upload indicator with blur effect
                      if (isUploadingAvatar)
                        Positioned.fill(
                          child: ClipOval(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface
                                      .withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: LoadingIndicator(
                                    size: 30,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // User name and info centered below avatar
            Center(
              // offset: const Offset(0, -60),
              child: Column(
                children: [
                  // Display name with larger font
                  Text(
                    profile.displayName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Username with subtle styling
                  if (profile.userName.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '@${profile.userName}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),

        // Add spacing between name and stats
        SizedBox(height: 24),

        // Stats counters with simple design
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: isStatsLoading
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: LoadingIndicator(
                        size: 24,
                        color: primaryColor,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: _buildSimpleStatColumn(
                          stats?['postsCount'] ?? 0,
                          'Posts',
                          theme,
                          primaryColor,
                        ),
                      ),
                      _buildVerticalDivider(theme),
                      Expanded(
                        child: _buildSimpleStatColumn(
                          stats?['followersCount'] ?? 0,
                          'Followers',
                          theme,
                          primaryColor,
                        ),
                      ),
                      _buildVerticalDivider(theme),
                      Expanded(
                        child: _buildSimpleStatColumn(
                          stats?['followingCount'] ?? 0,
                          'Following',
                          theme,
                          primaryColor,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  /// Build a simple stat column with count and label
  Widget _buildSimpleStatColumn(
      int count, String label, ThemeData theme, Color primaryColor) {
    return Column(
      children: [
        // Icon with subtle background
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getIconForStat(label),
            color: primaryColor,
            size: 18,
          ),
        ),
        const SizedBox(height: 8),
        // Count with large bold text
        Text(
          count.toString(),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        // Label with medium emphasis
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  /// Get icon for stat type
  IconData _getIconForStat(String label) {
    switch (label) {
      case 'Posts':
        return Icons.article_outlined;
      case 'Followers':
        return Icons.people_outline;
      case 'Following':
        return Icons.person_add_alt_outlined;
      default:
        return Icons.bar_chart_outlined;
    }
  }

  /// Build a vertical divider between stats
  Widget _buildVerticalDivider(ThemeData theme) {
    return Container(
      height: 30,
      width: 1,
      color: theme.dividerColor.withValues(alpha: 0.5),
    );
  }
}
