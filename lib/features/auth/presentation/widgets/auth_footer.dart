import 'package:flutter/material.dart';
import 'package:immigru/shared/theme/app_text_styles.dart';

/// Footer widget for authentication screens with action prompt
class AuthFooter extends StatelessWidget {
  /// The prompt text (e.g., "Don't have an account?")
  final String promptText;
  
  /// The action text (e.g., "Sign up")
  final String actionText;
  
  /// Callback when the action text is pressed
  final VoidCallback onPressed;
  
  /// Whether the app is in dark mode
  final bool isDarkMode;
  
  /// Primary color for active elements
  final Color primaryColor;

  /// Constructor
  const AuthFooter({
    Key? key,
    required this.promptText,
    required this.actionText,
    required this.onPressed,
    required this.isDarkMode,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          promptText,
          style: AppTextStyles.bodyMedium(
            brightness: isDarkMode ? Brightness.dark : Brightness.light,
          ).copyWith(
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            actionText,
            style: AppTextStyles.buttonMedium(
              brightness: isDarkMode ? Brightness.dark : Brightness.light,
            ).copyWith(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
