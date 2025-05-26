import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:immigru/features/home/domain/entities/post_comment.dart';
import 'package:immigru/features/home/presentation/widgets/comment_action_menu.dart';
import 'package:immigru/features/home/presentation/widgets/comment_like_button.dart';
import 'package:immigru/features/home/presentation/widgets/comment_thread_indicator.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Widget to display a list of comments for a post with a modern, clean design
class CommentListWidget extends StatefulWidget {
  /// List of comments to display
  final List<PostComment> comments;

  /// Callback when reply button is tapped
  final Function(PostComment)? onReply;

  /// Callback when edit button is tapped
  final Function(PostComment)? onEdit;

  /// Callback when delete button is tapped
  final Function(PostComment)? onDelete;

  /// Callback when like button is tapped
  final Function(PostComment)? onLike;

  /// Callback when copy button is tapped
  final Function(PostComment)? onCopy;

  /// Callback when report button is tapped
  final Function(PostComment)? onReport;

  /// Callback when hide button is tapped
  final Function(PostComment)? onHide;

  /// Whether to show the reply button
  final bool showReplyButton;

  /// Indentation level for nested comments
  final int indentationLevel;

  /// Maximum allowed indentation level (depth)
  static const int maxIndentationLevel = 3;

  /// Create a new CommentListWidget
  const CommentListWidget({
    super.key,
    required this.comments,
    this.onReply,
    this.onEdit,
    this.onDelete,
    this.onLike,
    this.onCopy,
    this.onReport,
    this.onHide,
    this.showReplyButton = true,
    this.indentationLevel = 0,
  });
  
  @override
  State<CommentListWidget> createState() => _CommentListWidgetState();

}

class _CommentListWidgetState extends State<CommentListWidget> {
  // Map to track which comment threads are expanded
  final Map<String, bool> _expandedThreads = {};
  
  @override
  void initState() {
    super.initState();
    // Initialize all threads as expanded by default
    for (final comment in widget.comments) {
      if (comment.replies.isNotEmpty) {
        _expandedThreads[comment.id] = true;
      }
    }
  }
  
  // Build vertical thread lines for Facebook-style comment threading
  List<Widget> _buildThreadLines(int level) {
    // Facebook uses a specific light gray color for thread lines
    const lineColor = Color(0xFFBEC2C9);
    
    return List.generate(level, (i) {
      final currentLevel = i + 1;
      return Positioned(
        left: 36.0 + ((currentLevel - 1) * 12.0),
        top: 0,
        bottom: 0,
        width: 1.5,
        child: Container(color: lineColor),
      );
    });
  }
  
  // Toggle the expanded state of a comment thread
  void _toggleThread(String commentId) {
    setState(() {
      _expandedThreads[commentId] = !(_expandedThreads[commentId] ?? false);
    });
  }
  
  // Check if a thread is expanded
  bool _isThreadExpanded(String commentId) {
    return _expandedThreads[commentId] ?? false;
  }

  /// Validates if a URL is a valid image URL
  bool _isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return url.startsWith('http') &&
        (url.endsWith('.jpg') ||
            url.endsWith('.jpeg') ||
            url.endsWith('.png') ||
            url.endsWith('.gif') ||
            url.endsWith('.webp'));
  }

  /// Build a comment content widget with mention highlighting
  Widget _buildCommentContent(BuildContext context, String content) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final mentionColor = Theme.of(context).primaryColor;

    // Check if the content contains a mention (e.g., "@username")
    final mentionRegex = RegExp(r'@([\w]+)');
    final match = mentionRegex.firstMatch(content);

    if (match != null) {
      final mentionedUsername = match.group(1);
      final beforeMention = content.substring(0, match.start);
      final mention = content.substring(match.start, match.end);
      final afterMention = content.substring(match.end);

      // If we have a mention, create a rich text widget with highlighting
      if (mentionedUsername != null) {
        return RichText(
          text: TextSpan(
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              height: 1.4, // Better line height for readability
            ),
            children: [
              TextSpan(text: beforeMention),
              TextSpan(
                text: mention,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: mentionColor,
                ),
              ),
              TextSpan(text: afterMention),
            ],
          ),
        );
      }
    }

    // If no mention or invalid format, just return the content as is
    return Text(
      content,
      style: TextStyle(
        color: textColor,
        fontSize: 14,
        height: 1.4, // Better line height for readability
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Empty state
    if (widget.comments.isEmpty && widget.indentationLevel == 0) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24.0),
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 48,
                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No comments yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Be the first to share your thoughts!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.comments.length,
      itemBuilder: (context, index) {
        final comment = widget.comments[index];
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        // Calculate indentation for nested comments - Facebook-style spacing
        final leftPadding = widget.indentationLevel <= CommentListWidget.maxIndentationLevel
            ? 16.0 + (widget.indentationLevel * 24.0) // Facebook-style indentation
            : 16.0 + (CommentListWidget.maxIndentationLevel * 24.0);
        final isLastComment = index == widget.comments.length - 1;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Add thread indicator and comment container
            Stack(
              clipBehavior: Clip.none, // Allow thread indicators to extend outside stack
              children: [
                // Draw continuous vertical lines for all parent levels
                if (widget.indentationLevel > 0)
                  ..._buildThreadLines(widget.indentationLevel),
                    
                // Add thread indicator for nested comments with Facebook-style positioning
                if (widget.indentationLevel > 0)
                  CommentThreadIndicator(
                    level: widget.indentationLevel,
                    leftPadding: leftPadding,
                    isExpanded: true,
                    isFirstInThread: index == 0,
                    isLastInThread: isLastComment,
                    showParentLines: widget.indentationLevel > 1,
                  ),
                Container(
                  margin: EdgeInsets.only(
                    top: 4.0,
                    bottom: 1.0,
                    left: leftPadding,
                    right: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[850] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onLongPress: () {
                          // Show the comment action menu when long-pressed
                          HapticFeedback.mediumImpact();
                          CommentActionMenu.show(
                            context: context,
                            comment: comment,
                            isCurrentUserComment: comment.isCurrentUserComment,
                            onReply: widget.onReply,
                            onEdit: comment.isCurrentUserComment ? widget.onEdit : null,
                            onDelete:
                                comment.isCurrentUserComment ? widget.onDelete : null,
                            onCopy: widget.onCopy,
                            onReport:
                                !comment.isCurrentUserComment ? widget.onReport : null,
                            onHide: !comment.isCurrentUserComment ? widget.onHide : null,
                          );
                        },
                        splashColor:
                            Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        highlightColor:
                            Theme.of(context).primaryColor.withValues(alpha: 0.05),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header: Avatar, username, timestamp
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // User avatar
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .primaryColor
                                            .withValues(alpha: 0.1),
                                        width: 2,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: isDarkMode
                                          ? Colors.grey[800]
                                          : Colors.grey[200],
                                      backgroundImage:
                                          _isValidImageUrl(comment.userAvatar)
                                              ? NetworkImage(comment.userAvatar!)
                                              : null,
                                      child: !_isValidImageUrl(comment.userAvatar)
                                          ? Icon(
                                              Icons.person,
                                              size: 20,
                                              color: isDarkMode
                                                  ? Colors.white70
                                                  : Colors.black54,
                                            )
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                  // Username and metadata
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            // Username
                                            Text(
                                              comment.userName ?? 'User',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: comment.isCurrentUserComment
                                                    ? Theme.of(context).primaryColor
                                                    : isDarkMode
                                                        ? Colors.white
                                                        : Colors.black87,
                                              ),
                                            ),

                                            // Reply badge for nested comments
                                            if (comment.depth > 1) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .primaryColor
                                                      .withValues(alpha: 0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  'Reply',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w500,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),

                                        // Timestamp
                                        Text(
                                          timeago.format(comment.createdAt),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDarkMode
                                                ? Colors.grey[400]
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // Comment content
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0),
                                child:
                                    _buildCommentContent(context, comment.content),
                              ),

                              // Action buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Left side: Like and Reply buttons
                                  Row(
                                    children: [
                                      // Like button
                                      CommentLikeButton(
                                        isLiked: comment.isLikedByCurrentUser,
                                        likeCount: comment.likeCount,
                                        onTap: widget.onLike != null
                                            ? () => widget.onLike!(comment)
                                            : () {}, // Empty function to avoid null issues
                                      ),

                                      const SizedBox(width: 16),

                                      // Reply button
                                      if (widget.showReplyButton && widget.onReply != null)
                                        _buildActionButton(
                                          context: context,
                                          icon: Icons.reply,
                                          label: 'Reply',
                                          onTap: () => widget.onReply!(comment),
                                          color: Theme.of(context).primaryColor,
                                        ),
                                    ],
                                  ),

                                  // Right side is now empty as edit/delete are moved to the long-press menu
                                  const SizedBox(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Display replies if there are any - more compact design
            if (comment.replies.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Show replies toggle button directly after comment with minimal spacing
                  if (comment.replies.length > 1)
                    Transform.translate(
                      offset: const Offset(0, -4), // Move slightly upward to reduce spacing
                      child: Padding(
                        padding: EdgeInsets.only(left: leftPadding, top: 0, bottom: 0),
                        child: InkWell(
                          onTap: () => _toggleThread(comment.id),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isThreadExpanded(comment.id) 
                                      ? Icons.keyboard_arrow_up 
                                      : Icons.keyboard_arrow_down,
                                  size: 14,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _isThreadExpanded(comment.id)
                                      ? 'Hide replies'
                                      : '${comment.replies.length} replies',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  
                  // Show replies if expanded - with no extra padding
                  if (_isThreadExpanded(comment.id))
                    Container(
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.zero,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Visual indicator for replies - positioned precisely
                          if (widget.indentationLevel < 3)
                            Positioned(
                              left: leftPadding - 8,
                              top: 0,
                              bottom: 0,
                              width: 1.5,
                              child: Container(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
                              ),
                            ),

                          // Replies - with minimal padding
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: CommentListWidget(
                              comments: comment.replies,
                              onReply: widget.onReply,
                              onEdit: widget.onEdit,
                              onDelete: widget.onDelete,
                              onLike: widget.onLike,
                              onCopy: widget.onCopy,
                              onReport: widget.onReport,
                              onHide: widget.onHide,
                              showReplyButton: true,
                              indentationLevel: widget.indentationLevel + 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),


            // Add divider only between top-level comments
            if (widget.indentationLevel == 0 && !isLastComment)
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Divider(height: 1, color: Colors.grey.withValues(alpha: 0.2)),
              ),
          ],
        );
      },
    );
  }

  /// Helper method to build consistent action buttons
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: color.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
