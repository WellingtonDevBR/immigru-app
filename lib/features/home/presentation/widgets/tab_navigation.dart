import 'package:flutter/material.dart';
import 'package:immigru/shared/theme/app_colors.dart';

/// Modern tab navigation for the home screen
class HomeTabNavigation extends StatelessWidget {
  final TabController tabController;
  final int currentIndex;

  const HomeTabNavigation({
    super.key,
    required this.tabController,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      color: isDarkMode ? AppColors.darkSurface : Colors.white,
      child: TabBar(
        controller: tabController,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: isDarkMode ? Colors.white70 : Colors.black54,
        indicatorColor: theme.colorScheme.primary,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: 'For You'),
          Tab(text: 'Explore'),
          Tab(text: 'ImmiGroves'),
          Tab(text: 'Events'),
        ],
      ),
    );
  }
}
