import 'package:flutter/material.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

/// Tab bar widget for switching between email and phone signup
class SignupTabBar extends StatelessWidget {
  final TabController tabController;

  const SignupTabBar({
    Key? key,
    required this.tabController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    final primaryColor = AppColors.primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black26 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: primaryColor,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: isDarkMode ? Colors.white70 : Colors.black54,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        tabs: const [
          Tab(text: 'Email'),
          Tab(text: 'Phone'),
        ],
      ),
    );
  }
}
