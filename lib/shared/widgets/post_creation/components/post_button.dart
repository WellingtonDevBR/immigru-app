import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A reusable post button widget with enhanced styling
class PostButton extends StatelessWidget {
  /// Whether the button is enabled
  final bool enabled;
  
  /// Whether the post is currently submitting
  final bool isSubmitting;
  
  /// Callback when the button is tapped
  final VoidCallback onTap;

  const PostButton({
    super.key,
    required this.enabled,
    required this.isSubmitting,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 48,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: !enabled || isSubmitting
            ? null
            : LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  Color.lerp(theme.colorScheme.primary, 
                           theme.colorScheme.secondary, 0.6)!,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
        color: isDarkMode
            ? Colors.grey[800]
            : theme.colorScheme.primary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        boxShadow: !enabled || isSubmitting
            ? null
            : [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: enabled && !isSubmitting
              ? () {
                  HapticFeedback.mediumImpact();
                  onTap();
                }
              : null,
          borderRadius: BorderRadius.circular(24),
          splashColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          highlightColor: theme.colorScheme.primary.withValues(alpha: 0.2),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isSubmitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      key: const ValueKey('post-button-content'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.send_rounded,
                          color: !enabled
                              ? isDarkMode
                                  ? Colors.grey[600]
                                  : Colors.white.withValues(alpha: 0.8)
                              : Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Post',
                          style: TextStyle(
                            color: !enabled
                                ? isDarkMode
                                    ? Colors.grey[600]
                                    : Colors.white.withValues(alpha: 0.8)
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
