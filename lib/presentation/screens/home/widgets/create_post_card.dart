import 'package:flutter/material.dart';
import 'package:immigru/domain/entities/user.dart';
import 'package:immigru/presentation/screens/home/widgets/create_post_dialog.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

class CreatePostCard extends StatelessWidget {
  final User? user;
  final Function(String, String?)? onCreatePost;
  
  const CreatePostCard({
    Key? key,
    required this.user,
    this.onCreatePost,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final avatarUrl = user?.avatarUrl;
    
    return Card(
      margin: EdgeInsets.zero,
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
                  _showCreatePostBottomSheet(context);
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
                _showCreatePostBottomSheet(context);
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
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
      child: avatarUrl == null
          ? Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            )
          : null,
    );
  }
  
  void _showCreatePostBottomSheet(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Important for sizing
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.5, // Takes up half the screen
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkSurface : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                // Handle bar for dragging
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        'Create Post',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                
                const Divider(),
                
                // Post content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User info
                        Row(
                          children: [
                            _buildUserAvatar(context, user?.avatarUrl),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name ?? 'Anonymous',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Public post',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Text field
                        Expanded(
                          child: TextField(
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: InputDecoration(
                              hintText: 'What\'s on your mind?',
                              hintStyle: TextStyle(
                                color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Bottom actions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppColors.darkBackground : Colors.grey.shade50,
                    border: Border(
                      top: BorderSide(
                        color: isDarkMode ? AppColors.borderDark : AppColors.borderLight,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.photo_library_outlined),
                        tooltip: 'Add photo',
                        onPressed: () {
                          // Handle photo upload
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.tag_outlined),
                        tooltip: 'Add category',
                        onPressed: () {
                          // Handle category selection
                        },
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          // Handle post submission
                          Navigator.pop(context);
                          if (onCreatePost != null) {
                            onCreatePost!('Sample post content', null);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Post'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
