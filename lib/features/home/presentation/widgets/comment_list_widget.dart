import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:immigru/features/home/domain/entities/post_comment.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Widget to display a list of comments for a post with a modern, clean design
class CommentListWidget extends StatelessWidget {
  /// List of comments to display
  final List<PostComment> comments;
  
  /// Callback when reply button is tapped
  final Function(PostComment)? onReply;
  
  /// Callback when edit button is tapped
  final Function(PostComment)? onEdit;
  
  /// Callback when delete button is tapped
  final Function(PostComment)? onDelete;
  
  /// Whether to show the reply button
  final bool showReplyButton;
  
  /// Indentation level for nested comments
  final int indentationLevel;
  
  /// Maximum allowed indentation level (depth)
  static const int maxIndentationLevel = 3;
  
  /// Debug flag to help troubleshoot comment display issues
  static const bool debugComments = true;

  /// Create a new CommentListWidget
  const CommentListWidget({
    super.key,
    required this.comments,
    this.onReply,
    this.onEdit,
    this.onDelete,
    this.showReplyButton = true,
    this.indentationLevel = 0,
  });
  
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
    // Debug logging to help identify comment structure
    if (debugComments) {
      print('Building CommentListWidget with ${comments.length} comments at indentation level $indentationLevel');
      for (var comment in comments) {
        print('Comment ID: ${comment.id}, Depth: ${comment.depth}, Content: ${comment.content}');
        print('Has ${comment.replies.length} replies');
        if (comment.replies.isNotEmpty) {
          for (var reply in comment.replies) {
            print('  Reply ID: ${reply.id}, Depth: ${reply.depth}, Content: ${reply.content}');
            print('  Has ${reply.replies.length} replies');
            
            if (reply.replies.isNotEmpty) {
              for (var nestedReply in reply.replies) {
                print('    Nested Reply ID: ${nestedReply.id}, Depth: ${nestedReply.depth}, Content: ${nestedReply.content}');
              }
            }
          }
        }
      }
    }
    
    // Empty state
    if (comments.isEmpty && indentationLevel == 0) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24.0),
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
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
                color: Theme.of(context).primaryColor.withOpacity(0.7),
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
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        
        // Calculate indentation for nested comments
        final leftPadding = indentationLevel > 0 
            ? 16.0 + (12.0 * indentationLevel) 
            : 16.0;
            
        // Determine if this is the last comment in the list
        final isLastComment = index == comments.length - 1;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(
                top: 8.0,
                bottom: 4.0,
                left: leftPadding,
                right: 16.0,
              ),
              decoration: BoxDecoration(
                color: isDarkMode 
                    ? Colors.grey[850] 
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
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
                    onLongPress: comment.isCurrentUserComment && onEdit != null 
                        ? () => onEdit!(comment) 
                        : null,
                    splashColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    highlightColor: Theme.of(context).primaryColor.withOpacity(0.05),
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
                                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: isDarkMode 
                                      ? Colors.grey[800] 
                                      : Colors.grey[200],
                                  backgroundImage: _isValidImageUrl(comment.userAvatar)
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
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).primaryColor.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'Reply',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                                color: Theme.of(context).primaryColor,
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
                            child: _buildCommentContent(context, comment.content),
                          ),
                          
                          // Action buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Left side: Reply button
                              if (showReplyButton && onReply != null)
                                _buildActionButton(
                                  context: context,
                                  icon: Icons.reply,
                                  label: 'Reply',
                                  onTap: () => onReply!(comment),
                                  color: Theme.of(context).primaryColor,
                                ),
                                
                              // Right side: Edit and Delete buttons for user's comments
                              if (comment.isCurrentUserComment)
                                Row(
                                  children: [
                                    if (onEdit != null)
                                      _buildActionButton(
                                        context: context,
                                        icon: Icons.edit,
                                        label: 'Edit',
                                        onTap: () => onEdit!(comment),
                                        color: Colors.blue,
                                      ),
                                      
                                    const SizedBox(width: 16),
                                    
                                    if (onDelete != null)
                                      _buildActionButton(
                                        context: context,
                                        icon: Icons.delete_outline,
                                        label: 'Delete',
                                        onTap: () => onDelete!(comment),
                                        color: Colors.red,
                                      ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Display replies if there are any
            if (comment.replies.isNotEmpty)
              Builder(builder: (context) {
                if (debugComments) {
                  print('Rendering ${comment.replies.length} replies for comment ${comment.id} at level ${indentationLevel}');
                  print('Comment depth: ${comment.depth}, indentation: $indentationLevel');
                }
                
                return Stack(
                  children: [
                    // Vertical line connecting replies
                    if (!isLastComment && indentationLevel < 3)
                      Positioned(
                        left: leftPadding + 18,
                        top: 0,
                        bottom: 0,
                        width: 2,
                        child: Container(
                          color: Theme.of(context).primaryColor.withOpacity(0.2),
                        ),
                      ),
                    
                    // Replies
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: CommentListWidget(
                        comments: comment.replies,
                        onReply: onReply,
                        onEdit: onEdit,
                        onDelete: onDelete,
                        showReplyButton: true,
                        indentationLevel: indentationLevel + 1,
                      ),
                    ),
                  ],
                );
              }),
              
            // Add divider only between top-level comments
            if (indentationLevel == 0 && !isLastComment)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
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
              color: color.withOpacity(0.8),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
