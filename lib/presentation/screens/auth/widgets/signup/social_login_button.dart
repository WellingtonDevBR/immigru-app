import 'package:flutter/material.dart';

/// Reusable social login button widget for authentication screens
class SocialLoginButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final bool isDarkMode;
  final String text;
  final IconData icon;

  const SocialLoginButton({
    Key? key,
    required this.isLoading,
    required this.onPressed,
    required this.isDarkMode,
    required this.text,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: isDarkMode ? Colors.white : Colors.black87,
        side: BorderSide(color: isDarkMode ? Colors.white30 : Colors.black12),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
