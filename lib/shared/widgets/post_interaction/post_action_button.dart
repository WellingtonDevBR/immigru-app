import 'package:flutter/material.dart';

/// A standardized button for post actions (like, comment, share)
/// This ensures consistent styling and behavior across the app
class PostActionButton extends StatelessWidget {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onPressed;
  final int? count;
  final Color? activeColor;
  
  const PostActionButton({
    super.key,
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onPressed,
    this.count,
    this.activeColor,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    final color = isActive 
        ? activeColor ?? Colors.green.shade600 
        : isDarkMode ? Colors.white70 : Colors.grey[600];
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Use animated icon with scale effect for better visual feedback
              AnimatedScale(
                scale: isActive ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    isActive ? (activeIcon ?? icon) : icon,
                    color: color,
                    size: 24,
                  ),
                ),
              ),
              
              const SizedBox(width: 6),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        color: color,
                      ),
                    ),
                    if (count != null && count! > 0) ...[  
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isActive 
                              ? Colors.green.withValues(alpha: 0.1) 
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isActive 
                                ? Colors.green.shade700 
                                : Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
