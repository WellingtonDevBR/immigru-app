import 'package:flutter/material.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

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
        tabs: [
          _buildAnimatedTab(0, 'For You', Icons.home_outlined, Icons.home),
          _buildAnimatedTab(1, 'All Posts', Icons.public_outlined, Icons.public),
          _buildAnimatedTab(2, 'My ImmiGroves', Icons.people_outline, Icons.people),
          _buildAnimatedTab(3, 'Events', Icons.event_outlined, Icons.event),
        ],
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
