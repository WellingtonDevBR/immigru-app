import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:immigru/features/auth/domain/entities/user.dart';
import 'package:immigru/shared/theme/app_colors.dart';
import 'package:immigru/core/logging/unified_logger.dart';

/// A miniature post creation widget that expands to a modal when clicked
class PostCreationWidget extends StatelessWidget {
  final User? user;
  final VoidCallback onTap;

  const PostCreationWidget({
    super.key,
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final logger = UnifiedLogger();

    return Hero(
      tag: 'post_creation_widget',
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin:
              const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 12),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // User avatar and post input field with clear CREATE POST text
              Stack(
                children: [
                  // Create post button with highlight effect
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          logger.d('Post creation widget tapped',
                              tag: 'PostCreationWidget');
                          HapticFeedback.lightImpact();
                          onTap();
                        },
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        splashColor:
                            theme.colorScheme.primary.withValues(alpha: 0.1),
                        highlightColor:
                            theme.colorScheme.primary.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: user?.photoUrl != null
                              ? NetworkImage(user!.photoUrl!)
                              : null,
                          radius: 20,
                          child: user?.photoUrl == null
                              ? Text(user?.displayName
                                      ?.substring(0, 1)
                                      .toUpperCase() ??
                                  'U')
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Create Post...',
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.grey[700],
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    'TAP HERE',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 1),
              // Post options (Photo, Video, Event)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDarkMode
                        ? [
                            AppColors.darkSurface,
                            Color.lerp(
                                AppColors.darkSurface, Colors.black, 0.05)!
                          ]
                        : [
                            Colors.white,
                            Color.lerp(Colors.white, Colors.grey[100]!, 0.5)!
                          ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPostOption(
                        icon: Icons.photo_library_outlined,
                        label: 'Photo',
                        color: Colors.green,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onTap();
                        },
                      ),
                      _buildPostOption(
                        icon: Icons.videocam_outlined,
                        label: 'Video',
                        color: Colors.red,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onTap();
                        },
                      ),
                      _buildPostOption(
                        icon: Icons.edit_note,
                        label: 'Create',
                        color: theme.colorScheme.primary,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onTap();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
