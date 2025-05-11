import 'package:flutter/material.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

class CommunityFeedItem extends StatelessWidget {
  final String category;
  final String userName;
  final String timeAgo;
  final String location;
  final String content;
  final int commentCount;
  final String? imageUrl;

  const CommunityFeedItem({
    super.key,
    required this.category,
    required this.userName,
    required this.timeAgo,
    required this.location,
    required this.content,
    this.commentCount = 0,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category avatar
                _buildCategoryAvatar(context),
                const SizedBox(width: 12),
                
                // Post metadata
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category
                      Text(
                        category,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode 
                              ? AppColors.textPrimaryDark 
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      // User info and time
                      Row(
                        children: [
                          Text(
                            userName,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode 
                                  ? AppColors.textSecondaryDark 
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(
                              color: isDarkMode 
                                  ? AppColors.textSecondaryDark 
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode 
                                  ? AppColors.textSecondaryDark 
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // Location
                      Text(
                        location,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode 
                              ? AppColors.textSecondaryDark 
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Post type indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Update',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode 
                          ? AppColors.textSecondaryDark 
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Post content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode 
                    ? AppColors.textPrimaryDark 
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
          
          // Post image (if any)
          if (imageUrl != null)
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          
          // Post actions
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                // Like button
                _buildActionButton(
                  context,
                  Icons.favorite_border,
                  'Like',
                  onPressed: () {
                    // TODO: Handle like action
                  },
                ),
                
                // Comment button
                _buildActionButton(
                  context,
                  Icons.chat_bubble_outline,
                  commentCount > 0 ? '$commentCount' : 'Comment',
                  onPressed: () {
                    // TODO: Handle comment action
                  },
                ),
                
                // Share button
                _buildActionButton(
                  context,
                  Icons.share_outlined,
                  'Share',
                  onPressed: () {
                    // TODO: Handle share action
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryAvatar(BuildContext context) {
    // Generate a color based on the category name
    final int hashCode = category.hashCode;
    final color = Color((hashCode & 0xFFFFFF) | 0xFF000000).withValues(alpha: 0.8);
    
    return Hero(
      tag: 'category-$category',
      child: CircleAvatar(
        radius: 20,
        backgroundColor: color.withValues(alpha: 0.2),
        child: Text(
          category.substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label, {
    required VoidCallback onPressed,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Expanded(
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 18,
          color: isDarkMode ? AppColors.iconDark : AppColors.iconLight,
        ),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode 
                ? AppColors.textSecondaryDark 
                : AppColors.textSecondaryLight,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }
}
