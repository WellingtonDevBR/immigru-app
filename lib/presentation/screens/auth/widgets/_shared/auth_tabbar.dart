import 'package:flutter/material.dart';

/// Unified tab bar for auth screens (login/signup) with consistent style
class AuthTabBar extends StatelessWidget {
  final TabController controller;
  final bool isDarkMode;
  final Color primaryColor;
  final List<String> tabs;

  const AuthTabBar({
    super.key,
    required this.controller,
    required this.isDarkMode,
    required this.primaryColor,
    this.tabs = const ['Email', 'Phone'],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black12 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: TabBar(
          controller: controller,
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          indicator: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(6),
          ),
          dividerColor: Colors.transparent,
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
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          tabs: tabs.map((label) => Tab(text: label)).toList(),
        ),
      ),
    );
  }
}
