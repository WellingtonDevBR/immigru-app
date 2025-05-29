import 'package:flutter/material.dart';

/// A reusable character counter widget with visual indicator
class CharacterCounter extends StatelessWidget {
  /// The current text to count characters for
  final String text;
  
  /// The maximum allowed character count
  final int maxCount;

  const CharacterCounter({
    super.key,
    required this.text,
    this.maxCount = 500,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Calculate percentage for visual indicator
    final percentage = text.length / maxCount;
    
    // Determine color based on character count
    final color = text.length > maxCount * 0.8
        ? text.length >= maxCount
            ? Colors.red
            : Colors.amber[700]
        : theme.colorScheme.primary;
    
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 4, right: 4, bottom: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Visual indicator
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode 
                    ? (Colors.grey[800] ?? Colors.grey).withValues(alpha: 0.7) 
                    : (Colors.grey[200] ?? Colors.grey).withValues(alpha: 0.7),
                boxShadow: [
                  BoxShadow(
                    color: color?.withValues(alpha: 0.1) ?? Colors.transparent,
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background circle
                  Center(
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDarkMode 
                            ? (Colors.grey[700] ?? Colors.grey).withValues(alpha: 0.7) 
                            : (Colors.grey[300] ?? Colors.grey).withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  // Progress circle
                  Center(
                    child: CircularProgressIndicator(
                      value: percentage,
                      strokeWidth: 2,
                      backgroundColor: Colors.transparent,
                      color: color,
                    ),
                  ),
                  // Text counter for high counts
                  if (text.length > maxCount * 0.8)
                    Center(
                      child: Text(
                        '${(maxCount - text.length).abs()}',
                        style: TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                          color: text.length >= maxCount ? Colors.white : color,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            // Text counter
            Text(
              '${text.length}/$maxCount',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
