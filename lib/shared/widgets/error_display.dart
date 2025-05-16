import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A shared widget for displaying errors consistently across the app
class ErrorDisplay extends StatelessWidget {
  /// The error message to display
  final String message;
  
  /// Optional error code for categorizing errors
  final String? errorCode;
  
  /// Optional callback when the close button is pressed
  final VoidCallback? onClose;
  
  /// Whether to show haptic feedback when displaying the error
  final bool withHapticFeedback;
  
  /// Whether to show the error in a banner style (full width)
  final bool asBanner;

  /// Constructor
  const ErrorDisplay({
    super.key,
    required this.message,
    this.errorCode,
    this.onClose,
    this.withHapticFeedback = true,
    this.asBanner = true,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    
    // Provide haptic feedback for errors
    if (withHapticFeedback) {
      HapticFeedback.heavyImpact();
    }
    
    // Colors for error display - more vibrant colors for better visibility
    final bgColor = isDarkMode ? Colors.red.shade900.withValues(alpha:0.9) : Colors.red.shade50;
    final borderColor = isDarkMode ? Colors.red.shade300 : Colors.red.shade400;
    final textColor = isDarkMode ? Colors.white : Colors.red.shade800;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.red.shade900.withValues(alpha:0.3) : Colors.red.shade200.withValues(alpha:0.5),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: textColor,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (errorCode != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          'Authentication Error',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    Text(
                      message,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (onClose != null)
                IconButton(
                  onPressed: onClose,
                  icon: Icon(
                    Icons.close,
                    color: textColor,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Extension to display error messages easily from any context
extension ErrorDisplayExtension on BuildContext {
  /// Show an error message as a snackbar
  void showErrorSnackbar(String message, {String? errorCode}) {
    // Clear any existing snackbars first
    ScaffoldMessenger.of(this).clearSnackBars();
    
    // Provide haptic feedback for errors
    HapticFeedback.heavyImpact();
    
    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Authentication Error',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(message),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.red.shade800,
      duration: const Duration(seconds: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      behavior: SnackBarBehavior.fixed,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      elevation: 8,
      action: SnackBarAction(
        label: 'DISMISS',
        textColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(this).hideCurrentSnackBar();
        },
      ),
    );
    
    ScaffoldMessenger.of(this).showSnackBar(snackBar);
  }
}
