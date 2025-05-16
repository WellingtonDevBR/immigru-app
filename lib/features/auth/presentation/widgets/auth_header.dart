import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:immigru/shared/theme/theme_provider.dart';

/// Header widget for authentication screens
class AuthHeader extends StatelessWidget {
  /// Whether the app is in dark mode
  final bool isDarkMode;
  
  /// Primary color for active elements
  final Color primaryColor;
  
  /// Title to display in the header
  final String title;

  /// Constructor
  const AuthHeader({
    Key? key,
    required this.isDarkMode,
    required this.primaryColor,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo and title
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  'assets/icons/immigru-logo.png',
                  width: 24,
                  height: 24,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        
        // Theme toggle button
        IconButton(
          onPressed: () {
            if (themeProvider.themeMode == ThemeMode.system) {
              // If system, switch to light or dark based on current system setting
              final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
              themeProvider.setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
            } else if (themeProvider.themeMode == ThemeMode.light) {
              themeProvider.setThemeMode(ThemeMode.dark);
            } else {
              themeProvider.setThemeMode(ThemeMode.system);
            }
          },
          icon: Icon(
            themeProvider.themeMode == ThemeMode.system
                ? Icons.brightness_auto
                : themeProvider.themeMode == ThemeMode.dark
                    ? Icons.dark_mode
                    : Icons.light_mode,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
          tooltip: themeProvider.themeMode == ThemeMode.system
              ? 'Using system theme'
              : themeProvider.themeMode == ThemeMode.dark
                  ? 'Switch to system theme'
                  : 'Switch to dark mode',
        ),
      ],
    );
  }
}
