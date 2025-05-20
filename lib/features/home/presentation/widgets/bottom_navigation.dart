import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:immigru/shared/theme/app_colors.dart';

/// Modern bottom navigation bar for the home screen
class HomeBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const HomeBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: NavigationBar(
          height: 60,
          backgroundColor: Colors.transparent,
          indicatorColor: theme.colorScheme.primary.withValues(alpha:0.1),
          selectedIndex: currentIndex,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          onDestinationSelected: (index) {
            HapticFeedback.lightImpact();
            onTabSelected(index);
          },
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.home_outlined,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
              selectedIcon: Icon(
                Icons.home,
                color: theme.colorScheme.primary,
              ),
              label: 'For You',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.explore_outlined,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
              selectedIcon: Icon(
                Icons.explore,
                color: theme.colorScheme.primary,
              ),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.people_outline,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
              selectedIcon: Icon(
                Icons.people,
                color: theme.colorScheme.primary,
              ),
              label: 'ImmiGroves',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.event_outlined,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
              selectedIcon: Icon(
                Icons.event,
                color: theme.colorScheme.primary,
              ),
              label: 'Events',
            ),
          ],
        ),
      ),
    );
  }
}
