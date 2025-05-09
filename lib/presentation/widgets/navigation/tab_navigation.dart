import 'package:flutter/material.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

/// A reusable tab navigation component that can be used across the app
/// with animated tab indicators and icons
class TabNavigation extends StatelessWidget {
  final TabController tabController;
  final int currentIndex;
  final List<TabItem> tabs;

  const TabNavigation({
    Key? key,
    required this.tabController,
    required this.currentIndex,
    required this.tabs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? AppColors.primaryDark : AppColors.primaryLight;
    
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: tabController,
        labelColor: primaryColor,
        unselectedLabelColor: isDarkMode 
            ? AppColors.textSecondaryDark 
            : AppColors.textSecondaryLight,
        indicatorColor: primaryColor,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        tabs: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          return _buildAnimatedTab(
            index, 
            tab.label, 
            tab.outlinedIcon, 
            tab.filledIcon ?? tab.outlinedIcon,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAnimatedTab(int index, String label, IconData outlinedIcon, IconData filledIcon) {
    final isSelected = currentIndex == index;
    
    return Tab(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? filledIcon : outlinedIcon),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Data class for tab items
class TabItem {
  final String label;
  final IconData outlinedIcon;
  final IconData? filledIcon;

  const TabItem({
    required this.label,
    required this.outlinedIcon,
    this.filledIcon,
  });
}

/// Home screen specific tab navigation with predefined tabs
class HomeTabNavigation extends StatelessWidget {
  final TabController tabController;
  final int currentIndex;

  const HomeTabNavigation({
    Key? key,
    required this.tabController,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabNavigation(
      tabController: tabController,
      currentIndex: currentIndex,
      tabs: const [
        TabItem(
          label: 'For You',
          outlinedIcon: Icons.home_outlined,
          filledIcon: Icons.home,
        ),
        TabItem(
          label: 'All Posts',
          outlinedIcon: Icons.public_outlined,
          filledIcon: Icons.public,
        ),
        TabItem(
          label: 'My ImmiGroves',
          outlinedIcon: Icons.people_outline,
          filledIcon: Icons.people,
        ),
        TabItem(
          label: 'Events',
          outlinedIcon: Icons.event_outlined,
          filledIcon: Icons.event,
        ),
      ],
    );
  }
}
