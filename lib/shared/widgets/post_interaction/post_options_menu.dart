import 'package:flutter/material.dart';
import 'package:immigru/features/home/domain/entities/post.dart';

/// A standardized options menu for posts
/// This ensures consistent styling and behavior across the app
class PostOptionsMenu extends StatelessWidget {
  final Post post;
  final bool isCurrentUserAuthor;
  final VoidCallback onShare;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  
  const PostOptionsMenu({
    super.key,
    required this.post,
    required this.isCurrentUserAuthor,
    required this.onShare,
    this.onEdit,
    this.onDelete,
  });
  
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.more_horiz),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      iconSize: 20,
      onPressed: () {
        _showOptionsMenu(context);
      },
    );
  }
  
  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(context);
                  onShare();
                },
              ),
              // Only show edit and delete options if the current user is the author
              if (isCurrentUserAuthor && onEdit != null) ...[  
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit Post'),
                  onTap: () {
                    Navigator.pop(context);
                    onEdit!();
                  },
                ),
              ],
              if (isCurrentUserAuthor && onDelete != null) ...[
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete Post', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    onDelete!();
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
