import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:immigru/shared/theme/app_colors.dart';

/// A reusable category picker widget for post creation
class CategoryPicker extends StatelessWidget {
  /// The currently selected category
  final String selectedCategory;
  
  /// Callback when a category is selected
  final Function(String) onCategorySelected;

  const CategoryPicker({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Category data with colors
    final categoryData = [
      {'name': 'General', 'color': AppColors.sproutGreen, 'icon': Icons.public},
      {'name': 'Question', 'color': AppColors.skyBlue, 'icon': Icons.help_outline},
      {'name': 'Event', 'color': Colors.purple, 'icon': Icons.event},
      {'name': 'News', 'color': Colors.orange, 'icon': Icons.article_outlined},
      {'name': 'Other', 'color': Colors.grey, 'icon': Icons.more_horiz},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(
                Icons.category_outlined,
                size: 16,
                color: theme.colorScheme.primary.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 8),
              Text(
                'Category',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: theme.colorScheme.primary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categoryData.length,
            itemBuilder: (context, index) {
              final category = categoryData[index];
              final isSelected = selectedCategory == category['name'];
              final color = category['color'] as Color;
              
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? color.withValues(alpha: 0.15)
                        : isDarkMode 
                            ? (Colors.grey[850] ?? Colors.grey).withValues(alpha: 0.5) 
                            : (Colors.grey[100] ?? Colors.grey).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected 
                          ? color 
                          : isDarkMode 
                              ? (Colors.grey[800] ?? Colors.grey) 
                              : (Colors.grey[300] ?? Colors.grey),
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.2),
                        blurRadius: 4,
                        spreadRadius: 0,
                        offset: const Offset(0, 1),
                      ),
                    ] : null,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        onCategorySelected(category['name'] as String);
                        HapticFeedback.lightImpact();
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              category['icon'] as IconData,
                              size: 16,
                              color: isSelected 
                                  ? color 
                                  : isDarkMode 
                                      ? (Colors.grey[400] ?? Colors.grey) 
                                      : (Colors.grey[600] ?? Colors.grey),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              category['name'] as String,
                              style: TextStyle(
                                color: isSelected 
                                    ? color 
                                    : isDarkMode 
                                        ? (Colors.grey[300] ?? Colors.grey) 
                                        : (Colors.grey[700] ?? Colors.grey),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
