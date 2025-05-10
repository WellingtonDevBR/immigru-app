import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:immigru/core/services/logger_service.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

/// A professional bottom navigation bar for the home screen
class HomeBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;
  final LoggerService logger;
  final VoidCallback onMenuPressed;

  const HomeBottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.logger,
    required this.onMenuPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Get platform to apply platform-specific styling
    final platform = Theme.of(context).platform;
    final isIOS = platform == TargetPlatform.iOS;
    
    // Apply platform-specific styling
    // iOS: Uses translucent background with blur effect, no elevation, larger icons
    // Android: Uses solid background with elevation, Material 3 design language
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode 
            ? AppColors.darkSurface 
            : isIOS ? Colors.white.withOpacity(0.95) : Colors.white,
        boxShadow: [
          if (!isIOS) // Android uses elevation, iOS doesn't
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
        ],
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(isIOS ? 0 : 12), // iOS doesn't use rounded corners for bottom nav
        ),
        // iOS specific border
        border: isIOS ? Border(
          top: BorderSide(
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
            width: 0.5,
          ),
        ) : null,
      ),
      // Add bottom padding for iOS to account for home indicator
      padding: EdgeInsets.only(bottom: isIOS ? 4.0 : 0.0),
      // Apply platform-specific blur effect for iOS
      child: isIOS && !isDarkMode ? ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: _buildBottomNavigationBar(context, isDarkMode, isIOS),
        ),
      ) : _buildBottomNavigationBar(context, isDarkMode, isIOS),
    );
  }
  
  Widget _buildBottomNavigationBar(BuildContext context, bool isDarkMode, bool isIOS) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        logger.debug('BottomNavigation', 'Tab selected: $index');
        if (index == 3) {
          // Menu button pressed
          onMenuPressed();
        } else {
          onTabSelected(index);
        }
      },
      backgroundColor: Colors.transparent,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      // Platform-specific styling
      selectedFontSize: isIOS ? 10.0 : 12.0, // iOS uses smaller labels
      unselectedFontSize: isIOS ? 10.0 : 12.0,
      iconSize: isIOS ? 28.0 : 24.0, // iOS uses larger icons
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: isDarkMode ? AppColors.iconDark : AppColors.iconLight,
      // Platform-specific item spacing
      landscapeLayout: isIOS ? BottomNavigationBarLandscapeLayout.spread : BottomNavigationBarLandscapeLayout.centered,
      items: [
        BottomNavigationBarItem(
          icon: Icon(isIOS ? Icons.home_outlined : Icons.home_outlined),
          activeIcon: Icon(isIOS ? Icons.home : Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(isIOS ? Icons.people_alt_outlined : Icons.people_outline),
          activeIcon: Icon(isIOS ? Icons.people_alt : Icons.people),
          label: 'People',
        ),
        BottomNavigationBarItem(
          icon: Icon(isIOS ? Icons.notifications_outlined : Icons.notifications_none_outlined),
          activeIcon: Icon(isIOS ? Icons.notifications : Icons.notifications),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(isIOS ? Icons.menu : Icons.menu_outlined),
          activeIcon: Icon(isIOS ? Icons.menu : Icons.menu),
          label: 'Menu',
        ),
      ],
    );
  }
}
