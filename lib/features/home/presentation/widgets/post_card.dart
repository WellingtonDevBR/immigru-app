import 'package:flutter/material.dart';
import 'package:immigru/features/home/domain/entities/post.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Modern card for displaying a post in the feed
class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback? onShare;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Calculate time ago
    final timeAgo = timeago.format(post.createdAt);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header with user info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // User avatar
                CircleAvatar(
                  radius: 20,
                  backgroundImage: post.userAvatar != null
                      ? NetworkImage(post.userAvatar!)
                      : null,
                  child: post.userAvatar == null
                      ? Text(
                          post.userName?[0] ?? 'U',
                          style: const TextStyle(fontSize: 18),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                
                // User name and post metadata
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName ?? 'Anonymous',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            timeAgo,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                          if (post.location != null) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.location_on,
                              size: 12,
                              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                post.location!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Category chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    post.category,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Post content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              post.content,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          
          // Post image (if available)
          if (post.imageUrl != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
                child: Image.network(
                  post.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          
          // Post actions
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                // Like button
                _buildActionButton(
                  context,
                  icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                  label: '${post.likeCount}',
                  color: post.isLiked ? Colors.red : null,
                  onPressed: onLike,
                ),
                
                // Comment button
                _buildActionButton(
                  context,
                  icon: Icons.comment_outlined,
                  label: '${post.commentCount}',
                  onPressed: onComment,
                ),
                
                // Share button
                _buildActionButton(
                  context,
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onPressed: onShare,
                ),
                
                const Spacer(),
                
                // Bookmark button
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: () {
                    // Bookmark post
                  },
                  tooltip: 'Save',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build an action button for the post
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    Color? color,
    VoidCallback? onPressed,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    final buttonColor = color ?? (isDarkMode ? Colors.white70 : Colors.black54);
    
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 18,
        color: buttonColor,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: buttonColor,
          fontSize: 12,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
