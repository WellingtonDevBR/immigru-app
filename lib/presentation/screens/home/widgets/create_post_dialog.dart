import 'package:flutter/material.dart';
import 'package:immigru/domain/entities/user.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

/// Dialog to create a new post
class CreatePostDialog {
  /// Shows the create post dialog
  static Future<void> show(BuildContext context, User? user, Function(String, String?) onPost) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.all(16),
          content: SingleChildScrollView(
            child: CreatePostCard(
              user: user,
              onPost: onPost,
            ),
          ),
        );
      },
    );
  }
}

class CreatePostCard extends StatelessWidget {
  final User? user;
  final Function(String, String?)? onPost;
  
  const CreatePostCard({
    super.key,
    required this.user,
    this.onPost,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final avatarUrl = user?.avatarUrl;
    
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDarkMode ? AppColors.borderDark : AppColors.borderLight,
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // User avatar
            _buildUserAvatar(context, avatarUrl),
            const SizedBox(width: 12),
            
            // Post input field
            Expanded(
              child: InkWell(
                onTap: () {
                  if (onPost != null) {
                    // Show a dialog to create a post
                    _showCreatePostDialog(context);
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Share an update...',
                    style: TextStyle(
                      color: isDarkMode 
                          ? AppColors.textSecondaryDark 
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ),
            ),
            
            // Image upload button
            IconButton(
              icon: Icon(
                Icons.photo_outlined,
                color: isDarkMode ? AppColors.iconDark : AppColors.iconLight,
              ),
              onPressed: () {
                // TODO: Handle image upload
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUserAvatar(BuildContext context, String? avatarUrl) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
      child: avatarUrl == null
          ? Icon(
              Icons.person,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
    );
  }
  
  void _showCreatePostDialog(BuildContext context) {
    final TextEditingController contentController = TextEditingController();
    String? selectedImagePath;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Create Post',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserAvatar(context, user?.avatarUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: contentController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'What\'s on your mind?',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.photo),
                      onPressed: () {
                        // TODO: Implement image picker
                        selectedImagePath = 'sample_image_path.jpg';
                      },
                      tooltip: 'Add Photo',
                    ),
                    IconButton(
                      icon: const Icon(Icons.location_on),
                      onPressed: () {
                        // TODO: Implement location picker
                      },
                      tooltip: 'Add Location',
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    if (contentController.text.isNotEmpty && onPost != null) {
                      onPost!(contentController.text, selectedImagePath);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Post'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
