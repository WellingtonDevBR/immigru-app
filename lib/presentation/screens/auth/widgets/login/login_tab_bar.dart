import 'package:flutter/material.dart';

/// Custom tab bar for the login screen following industry standards
class LoginTabBar extends StatelessWidget {
  final TabController controller;
  final bool isDarkMode;
  final Color primaryColor;

  const LoginTabBar({
    super.key,
    required this.controller,
    required this.isDarkMode,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44, // Standard height for tab bars
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black12 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: TabBar(
          controller: controller,
          // Use label padding for proper spacing
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          // Use indicator size to match tab width
          indicatorSize: TabBarIndicatorSize.tab,
          // Use indicator padding for subtle inset effect
          indicatorPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          // Use indicator for a more elegant selected tab
          indicator: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(6),
          ),
          // Disable the default indicator
          dividerColor: Colors.transparent,
          // Customize the tab appearance
          labelColor: Colors.white,
          unselectedLabelColor: isDarkMode ? Colors.white70 : Colors.black54,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
          // Add padding to the tabs
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          // Custom tab implementation
          tabs: const [
            Tab(text: 'Email'),
            Tab(text: 'Phone'),
          ],
        ),
      ),
    );
  }
}
