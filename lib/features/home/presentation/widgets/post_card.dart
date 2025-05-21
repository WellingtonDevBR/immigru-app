import 'package:flutter/material.dart';
import 'package:immigru/features/home/domain/entities/post.dart';
import 'package:immigru/shared/widgets/grove_like_button.dart';
import 'package:immigru/shared/widgets/seed_comment_button.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Modern card for displaying a post in the feed
class PostCard extends StatefulWidget {
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
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  // Local state to track liked and commented status for immediate UI feedback
  late bool _isLiked;
  bool _isCommented = false; // Track comment state locally

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
  }

  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.isLiked != widget.post.isLiked) {
      _isLiked = widget.post.isLiked;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Calculate time ago
    final timeAgo = timeago.format(widget.post.createdAt);

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header with user info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // User avatar
                CircleAvatar(
                  radius: 18,
                  backgroundImage: widget.post.userAvatar != null
                      ? NetworkImage(widget.post.userAvatar!)
                      : null,
                  child: widget.post.userAvatar == null
                      ? Text(
                          widget.post.userName?[0] ?? 'U',
                          style: const TextStyle(fontSize: 16),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                // User name and post time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.userName ?? 'Anonymous',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isDarkMode ? Colors.white60 : Colors.black54,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.public,
                            size: 12,
                            color: isDarkMode ? Colors.white60 : Colors.black54,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // More options
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 20,
                  onPressed: () {
                    // Show options menu
                  },
                ),
              ],
            ),
          ),
          // Post content
          if (widget.post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                widget.post.content,
                style: TextStyle(
                  fontSize: 15,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
          // Post image if available
          if (widget.post.imageUrl != null)
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 400),
              child: Image.network(
                widget.post.imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.error_outline, size: 40),
                    ),
                  );
                },
              ),
            ),
          // Likes count
          Padding(
            padding:
                const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 4),
            child: Row(
              children: [
                Icon(
                  Icons.thumb_up,
                  size: 14,
                  color: isDarkMode ? Colors.white70 : Colors.grey[700],
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.post.likeCount}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDarkMode ? Colors.white70 : Colors.grey[700],
                  ),
                ),
                const Spacer(),
                if (widget.post.commentCount > 0)
                  Text(
                    '${widget.post.commentCount} comments',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDarkMode ? Colors.white70 : Colors.grey[700],
                    ),
                  ),
              ],
            ),
          ),

          // Divider
          Divider(
              height: 1,
              thickness: 1,
              color: isDarkMode ? Colors.grey[800] : Colors.grey[300]),

          // Like, comment, share buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Tree-themed like button with text
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Update local state immediately for better UX
                        setState(() {
                          _isLiked = !_isLiked;
                        });

                        // Call the parent's onLike callback
                        widget.onLike();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GroveLikeButton(
                              key: ValueKey('grove_like_${widget.post.id}'),
                              size: 28,
                              initialLiked: _isLiked, // Use local state
                              // Don't use onLikeChanged to avoid duplicate calls
                              onLikeChanged: null,
                              animationDuration:
                                  const Duration(milliseconds: 600),
                              trunkColor: Colors.brown.shade600,
                              rootColor: Colors.brown.shade800,
                              leafColor: Colors.lightGreen.shade400,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Like',
                              style: TextStyle(
                                fontSize: 14,
                                color: _isLiked
                                    ? Colors.green.shade700
                                    : isDarkMode
                                        ? Colors.white70
                                        : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Comment button with seed animation
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Toggle comment state locally
                        setState(() {
                          _isCommented = !_isCommented;
                        });

                        // Call the parent's onComment callback
                        widget.onComment();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SeedCommentButton(
                              key: ValueKey('seed_comment_${widget.post.id}'),
                              size: 28,
                              initialCommented:
                                  _isCommented, // Use local comment state
                              // Don't use onCommentedChanged to avoid duplicate calls
                              onCommentedChanged: null,
                              animationDuration:
                                  const Duration(milliseconds: 600),
                              seedColor: Colors.brown.shade600,
                              sproutColor: Colors.green.shade400,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Comment',
                              style: TextStyle(
                                fontSize: 14,
                                color: _isCommented
                                    ? Colors.green.shade700
                                    : isDarkMode
                                        ? Colors.white70
                                        : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Share button
                if (widget.onShare != null)
                  Expanded(
                    child: InkWell(
                      onTap: widget.onShare,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.share_outlined,
                            color:
                                isDarkMode ? Colors.white70 : Colors.grey[700],
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Share',
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.grey[700],
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
    );
  }

  // No longer needed action button builder as we've implemented custom buttons
}
