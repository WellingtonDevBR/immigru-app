import 'package:flutter/material.dart';
import 'package:immigru/shared/theme/app_text_styles.dart';

/// A tab bar for switching between email and phone login methods
class LoginTabBar extends StatelessWidget {
  /// Tab controller for managing tab state
  final TabController controller;
  
  /// Whether the app is in dark mode
  final bool isDarkMode;
  
  /// Primary color for active elements
  final Color primaryColor;

  /// Constructor
  const LoginTabBar({
    Key? key,
    required this.controller,
    required this.isDarkMode,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode 
            ? Colors.grey.withValues(alpha:0.1) 
            : Colors.grey.withValues(alpha:0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: primaryColor.withValues(alpha:0.1),
          border: Border.all(
            color: primaryColor,
            width: 1.5,
          ),
        ),
        labelColor: primaryColor,
        unselectedLabelColor: isDarkMode ? Colors.white70 : Colors.black54,
        labelStyle: AppTextStyles.buttonMedium(
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
        tabs: const [
          Tab(
            text: 'Email',
            icon: Icon(Icons.email_outlined, size: 18),
          ),
          Tab(
            text: 'Phone',
            icon: Icon(Icons.phone_android_outlined, size: 18),
          ),
        ],
      ),
    );
  }
}
