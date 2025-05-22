import 'package:flutter/material.dart';
import 'package:immigru/features/home/domain/entities/post_comment.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Widget to display a list of comments for a post
class CommentListWidget extends StatelessWidget {
  /// List of comments to display
  final List<PostComment> comments;
  
  /// Callback when reply button is tapped
  final Function(PostComment)? onReply;
  
  /// Whether to show the reply button
  final bool showReplyButton;
  
  /// Indentation level for nested comments
  final int indentationLevel;

  /// Create a new CommentListWidget
  const CommentListWidget({
    Key? key,
    required this.comments,
    this.onReply,
    this.showReplyButton = true,
    this.indentationLevel = 0,
  }) : super(key: key);
  
  /// Validates if the provided URL is a valid image URL
  bool _isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    if (url == 'custom') return false; // Filter out invalid 'custom' URL
    
    // Basic URL validation
    return url.startsWith('http://') || url.startsWith('https://') || url.startsWith('data:image/');
  }

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty && indentationLevel == 0) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No comments yet. Be the first to comment!'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: 8.0,
                bottom: 4.0,
                left: 16.0 + (indentationLevel * 16.0),
                right: 16.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: _isValidImageUrl(comment.userAvatar)
                        ? NetworkImage(comment.userAvatar!)
                        : null,
                    child: !_isValidImageUrl(comment.userAvatar)
                        ? const Icon(Icons.person, size: 16)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              comment.userName ?? 'User',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              timeago.format(comment.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          comment.content,
                          style: const TextStyle(),
                        ),
                        if (showReplyButton && onReply != null) ...[  
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () => onReply!(comment),
                            child: Text(
                              'Reply',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Display replies if there are any
            if (comment.replies.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(
                  left: indentationLevel > 0 ? 0 : 16.0,
                ),
                child: CommentListWidget(
                  comments: comment.replies,
                  onReply: onReply,
                  showReplyButton: showReplyButton,
                  indentationLevel: indentationLevel + 1,
                ),
              ),
            const Divider(),
          ],
        );
      },
    );
  }
}
