import 'package:flutter/material.dart';
import 'package:immigru/domain/entities/user.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

class CreatePostCard extends StatelessWidget {
  final User? user;
  
  const CreatePostCard({
    Key? key,
    required this.user,
  }) : super(key: key);

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
                  // TODO: Navigate to create post screen
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
    return Hero(
      tag: 'user-avatar',
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
        child: avatarUrl == null
            ? Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.primary,
              )
            : null,
      ),
    );
  }
}
