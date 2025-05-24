import 'package:flutter/material.dart';
import 'package:immigru/features/home/domain/entities/post_comment.dart';

/// A bottom sheet menu that displays actions for a comment
class CommentActionMenu extends StatelessWidget {
  /// The comment to show actions for
  final PostComment comment;
  
  /// Whether the comment belongs to the current user
  final bool isCurrentUserComment;
  
  /// Callback when the reply action is selected
  final Function(PostComment)? onReply;
  
  /// Callback when the edit action is selected
  final Function(PostComment)? onEdit;
  
  /// Callback when the delete action is selected
  final Function(PostComment)? onDelete;
  
  /// Callback when the copy action is selected
  final Function(PostComment)? onCopy;
  
  /// Callback when the report action is selected
  final Function(PostComment)? onReport;
  
  /// Callback when the hide action is selected
  final Function(PostComment)? onHide;
  
  /// Create a new CommentActionMenu
  const CommentActionMenu({
    super.key,
    required this.comment,
    required this.isCurrentUserComment,
    this.onReply,
    this.onEdit,
    this.onDelete,
    this.onCopy,
    this.onReport,
    this.onHide,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Comment preview
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: comment.userAvatar != null && comment.userAvatar!.isNotEmpty
                      ? NetworkImage(comment.userAvatar!)
                      : null,
                  child: comment.userAvatar == null || comment.userAvatar!.isEmpty
                      ? const Icon(Icons.person, size: 16)
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.userName ?? 'User',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        comment.content,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Actions
          if (isCurrentUserComment) ...[
            // User's own comment actions - edit, copy, delete
            _buildActionItem(
              context: context,
              icon: Icons.edit,
              label: 'Edit',
              onTap: onEdit != null ? () => onEdit!(comment) : null,
            ),
            _buildActionItem(
              context: context,
              icon: Icons.content_copy,
              label: 'Copy',
              onTap: onCopy != null ? () => onCopy!(comment) : null,
            ),
            _buildActionItem(
              context: context,
              icon: Icons.delete_outline,
              label: 'Delete',
              onTap: onDelete != null ? () => onDelete!(comment) : null,
              isDestructive: true,
            ),
          ] else ...[
            // Other user's comment actions - copy, hide, report
            _buildActionItem(
              context: context,
              icon: Icons.content_copy,
              label: 'Copy',
              onTap: onCopy != null ? () => onCopy!(comment) : null,
            ),
            _buildActionItem(
              context: context,
              icon: Icons.visibility_off,
              label: 'Hide',
              onTap: onHide != null ? () => onHide!(comment) : null,
            ),
            _buildActionItem(
              context: context,
              icon: Icons.flag,
              label: 'Report',
              onTap: onReport != null ? () => onReport!(comment) : null,
              isDestructive: true,
            ),
          ],
          
          const SizedBox(height: 8),
          
          // Cancel button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  foregroundColor: isDarkMode ? Colors.white : Colors.black87,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ),
          
          // Add extra padding at the bottom for devices with bottom navigation bar
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
  
  /// Build an action item for the menu
  Widget _buildActionItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final color = isDestructive 
        ? Colors.red 
        : (isDarkMode ? Colors.white : Colors.black87);
    
    return InkWell(
      onTap: onTap != null 
          ? () {
              Navigator.of(context).pop();
              onTap();
            } 
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Show the comment action menu as a bottom sheet
  static Future<void> show({
    required BuildContext context,
    required PostComment comment,
    required bool isCurrentUserComment,
    Function(PostComment)? onReply,
    Function(PostComment)? onEdit,
    Function(PostComment)? onDelete,
    Function(PostComment)? onCopy,
    Function(PostComment)? onReport,
    Function(PostComment)? onHide,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentActionMenu(
        comment: comment,
        isCurrentUserComment: isCurrentUserComment,
        onReply: onReply,
        onEdit: onEdit,
        onDelete: onDelete,
        onCopy: onCopy,
        onReport: onReport,
        onHide: onHide,
      ),
    );
  }
}
