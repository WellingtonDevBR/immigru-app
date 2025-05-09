import 'package:flutter/material.dart';

/// A feature item widget that displays a feature with an icon, title, and description
class FeatureItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String description;
  final VoidCallback? onTap;
  final bool isSelected;

  const FeatureItem({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
    this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode 
        ? color.withOpacity(0.15)
        : color.withOpacity(0.1);
    final borderColor = isSelected 
        ? color 
        : Colors.transparent;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: color,
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Predefined feature items for the home screen
class ImmigrationFeatures {
  static List<FeatureItem> getFeatures({
    required List<VoidCallback> onTapCallbacks,
    required int selectedIndex,
  }) {
    final List<Map<String, dynamic>> featureData = [
      {
        'title': 'Documents',
        'icon': Icons.description_outlined,
        'color': const Color(0xFF2EAA76), // Primary green
        'description': 'Manage your immigration documents in one place',
      },
      {
        'title': 'Timeline',
        'icon': Icons.timeline_outlined,
        'color': const Color(0xFF4A6FFF), // Blue
        'description': 'Track your immigration journey progress',
      },
      {
        'title': 'Community',
        'icon': Icons.people_outline_rounded,
        'color': const Color(0xFFFF6B6B), // Red/Pink
        'description': 'Connect with others on similar journeys',
      },
      {
        'title': 'Resources',
        'icon': Icons.menu_book_outlined,
        'color': const Color(0xFFFFB84D), // Orange
        'description': 'Access guides and immigration resources',
      },
    ];
    
    return List.generate(
      featureData.length,
      (index) => FeatureItem(
        title: featureData[index]['title'],
        icon: featureData[index]['icon'],
        color: featureData[index]['color'],
        description: featureData[index]['description'],
        onTap: onTapCallbacks.length > index ? onTapCallbacks[index] : null,
        isSelected: index == selectedIndex,
      ),
    );
  }
}
