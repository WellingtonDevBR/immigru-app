import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:immigru/core/storage/i_supabase_storage.dart';
import 'package:immigru/features/profile/domain/entities/user_profile.dart';
import 'package:immigru/shared/widgets/loading_indicator.dart';

/// Widget for displaying the profile stats section with avatar and counters
class ProfileStatsSection extends StatelessWidget {
  /// Helper method to get the appropriate image provider for a profile image
  /// Returns an AssetImage as fallback when URL is invalid
  ImageProvider? _getProfileImage(String? url) {
    if (url == null || url.isEmpty) return null;
    
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
    return Row(
      children: [
        // Avatar
        GestureDetector(
          onTap: onTapAvatar,
          child: Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  backgroundImage: _getProfileImage(profile.avatarUrl),
                  child: profile.avatarUrl == null
                      ? Text(
                          profile.displayName.isNotEmpty
                              ? profile.displayName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        )
                      : null,
                ),
              ),
              
              // Upload indicator
              if (isUploadingAvatar)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: LoadingIndicator(
                        size: 24,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              
              // Edit icon if editable
              if (onTapAvatar != null && !isUploadingAvatar)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.surface,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.add_a_photo,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        const SizedBox(width: 24),
        
        // Stats counters
        Expanded(
          child: isStatsLoading
              ? Center(
                  child: LoadingIndicator(
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn(
                      'Posts',
                      stats?['postsCount'] ?? 0,
                    ),
                    _buildStatColumn(
                      'Followers',
                      stats?['followersCount'] ?? 0,
                    ),
                    _buildStatColumn(
                      'Following',
                      stats?['followingCount'] ?? 0,
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  /// Build a stat column with label and count
  Widget _buildStatColumn(String label, int count) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Column(
          children: [
            Text(
              count.toString(),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        );
      },
    );
  }
}
