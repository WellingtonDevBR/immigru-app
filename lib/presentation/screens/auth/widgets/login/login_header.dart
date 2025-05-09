import 'package:flutter/material.dart';

/// Widget for the login screen header with app logo and theme toggle
class LoginHeader extends StatelessWidget {
  final bool isDarkMode;
  final Color primaryColor;
  final VoidCallback onThemeToggle;

  const LoginHeader({
    Key? key,
    required this.isDarkMode,
    required this.primaryColor,
    required this.onThemeToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.flight_takeoff_rounded,
                  color: primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Immigru',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          // Theme toggle button
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              onPressed: onThemeToggle,
              icon: Icon(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: isDarkMode ? Colors.white70 : Colors.black54,
                size: 20,
              ),
              tooltip: isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }
}
