import 'package:flutter/material.dart';
import 'package:immigru/shared/theme/app_text_styles.dart';

/// Custom button for authentication screens
class AuthButton extends StatelessWidget {
  /// Button text
  final String text;
  
  /// Whether the button is in loading state
  final bool isLoading;
  
  /// Callback for when the button is pressed
  final VoidCallback? onPressed;
  
  /// Button color
  final Color? color;
  
  /// Text color
  final Color? textColor;
  
  /// Constructor
  const AuthButton({
    super.key,
    required this.text,
    this.isLoading = false,
    this.onPressed,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Theme.of(context).colorScheme.primary,
          foregroundColor: textColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          disabledBackgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.8),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: AppTextStyles.buttonLarge(brightness: Theme.of(context).brightness).copyWith(
                  color: textColor ?? Colors.white,
                ),
              ),
      ),
    );
  }
}
