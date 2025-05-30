import 'package:flutter/material.dart';
import 'package:immigru/features/home/domain/entities/post_comment.dart';

/// Widget for entering a new comment
class CommentInputWidget extends StatefulWidget {
  /// ID of the post to comment on
  final String postId;
  
  /// Callback when a comment is submitted
  final Function(String, String?, String?) onSubmit;
  
  /// Parent comment (if this is a reply)
  final PostComment? parentComment;
  
  /// Maximum depth level for comments
  static const int maxDepth = 3;
  
  /// Create a new CommentInputWidget
  const CommentInputWidget({
    super.key,
    required this.postId,
    required this.onSubmit,
    this.parentComment,
  });

  @override
  State<CommentInputWidget> createState() => _CommentInputWidgetState();
}

class _CommentInputWidgetState extends State<CommentInputWidget> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_commentController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });
    
    // Determine root comment ID for proper threading
    final String? rootCommentId = widget.parentComment == null ? null :
        (widget.parentComment!.depth == 1 ? widget.parentComment!.id : widget.parentComment!.rootCommentId);

    widget.onSubmit(
      _commentController.text.trim(),
      widget.parentComment?.id,
      rootCommentId,
    ).then((_) {
      // Clear the input field after successful submission
      _commentController.clear();
      setState(() {
        _isSubmitting = false;
      });
    }).catchError((error) {
      setState(() {
        _isSubmitting = false;
      });
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to post comment: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show who we're replying to if this is a reply
          if (widget.parentComment != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Text(
                    'Replying to ',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    widget.parentComment!.userName ?? 'User',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const Spacer(),
                  // Cancel reply button
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              // User avatar (placeholder)
              const CircleAvatar(
                radius: 16,
                child: Icon(Icons.person, size: 16),
              ),
              const SizedBox(width: 12),
              // Comment input field
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: widget.parentComment != null
                        ? 'Write a reply...'
                        : 'Write a comment...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                  maxLines: 3,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              // Submit button with proper theme-aware colors
              Container(
                margin: const EdgeInsets.only(left: 8.0),
                decoration: BoxDecoration(
                  // Use colorScheme.primary which adapts to theme brightness
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  icon: _isSubmitting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            // Use onPrimary for proper contrast
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        )
                      : Icon(
                          Icons.send,
                          // Use onPrimary for proper contrast with primary color
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 20,
                        ),
                  iconSize: 24,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
