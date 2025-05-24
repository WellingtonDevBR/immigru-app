import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:immigru/shared/theme/app_colors.dart';

/// Bottom navigation bar for the Home screen
class HomeBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final VoidCallback onMenuTap;

  const HomeBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedIndex,
      backgroundColor: isDarkMode ? AppColors.darkSurface : Colors.white,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: isDarkMode ? Colors.white70 : Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      onTap: (index) {
        HapticFeedback.lightImpact();
        
        if (index == 3) {
          // Menu button opens drawer
          onMenuTap();
        } else {
          onItemSelected(index);
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.groups),
          label: 'ImmiGroves',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu),
          label: 'Menu',
        ),
      ],
    );
  }
}
