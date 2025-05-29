import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:immigru/shared/theme/app_colors.dart';

/// A reusable media selection buttons widget for post creation
class MediaSelectionButtons extends StatelessWidget {
  /// Callback when photo button is tapped
  final VoidCallback onPhotoTap;
  
  /// Callback when video button is tapped
  final VoidCallback onVideoTap;

  const MediaSelectionButtons({
    super.key,
    required this.onPhotoTap,
    required this.onVideoTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? (Colors.grey[850] ?? Colors.grey).withValues(alpha: 0.3) 
            : (Colors.grey[100] ?? Colors.grey).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _buildMediaButton(
              context: context,
              icon: Icons.image_outlined,
              label: 'Photo',
              color: AppColors.sproutGreen,
              onTap: () {
                HapticFeedback.lightImpact();
                onPhotoTap();
              },
            ),
          ),
          Container(
            height: 28,
            width: 1,
            color: isDarkMode 
                ? (Colors.grey[700] ?? Colors.grey).withValues(alpha: 0.5) 
                : (Colors.grey[300] ?? Colors.grey),
          ),
          Expanded(
            child: _buildMediaButton(
              context: context,
              icon: Icons.videocam_outlined,
              label: 'Video',
              color: AppColors.skyBlue,
              onTap: () {
                HapticFeedback.lightImpact();
                onVideoTap();
              },
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build a styled media selection button
  Widget _buildMediaButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.1),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color, 
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
