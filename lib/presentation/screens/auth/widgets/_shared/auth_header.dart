import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  final bool isDarkMode;
  final Color primaryColor;
  final VoidCallback onThemeToggle;
  final String title;
  final IconData icon;

  const AuthHeader({
    Key? key,
    required this.isDarkMode,
    required this.primaryColor,
    required this.onThemeToggle,
    this.title = 'Immigru',
    this.icon = Icons.flight_takeoff_rounded,
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
                  icon,
                  color: primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
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
