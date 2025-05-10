import 'package:flutter/material.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

/// Data class for tab items
class TabItemData {
  final String label;
  final IconData outlinedIcon;
  final IconData? filledIcon;

  const TabItemData({
    required this.label,
    required this.outlinedIcon,
    this.filledIcon,
  });
}

/// A responsive tab navigation that adapts to different screen sizes
class TabNavigation extends StatelessWidget {
  final TabController tabController;
  final int currentIndex;
  final List<TabItemData> tabs;

  const TabNavigation({
    Key? key,
    required this.tabController,
    required this.currentIndex,
    required this.tabs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final platform = Theme.of(context).platform;
    final isIOS = platform == TargetPlatform.iOS;
    
    // Platform-specific styling following industry standards
    // iOS: Uses SF Pro Display font, more rounded corners, subtle shadows
    // Android: Uses Roboto font, less rounded corners, more pronounced shadows
    
    // Use proper theme colors for background
    final backgroundColor = isDarkMode 
        ? AppColors.surfaceDark  // Use proper dark theme surface color
        : AppColors.surfaceLight; // Use proper light theme surface color

    return LayoutBuilder(
      builder: (context, constraints) {
        final tabCount = tabs.length;
        final minTabWidth = 50.0; // Minimum width for very small screens
        final tabWidth = constraints.maxWidth / tabCount;
        
        // Always make scrollable for small screens or when tabs would be too narrow
        final isScrollable = tabWidth < minTabWidth || constraints.maxWidth <= 400;
        
        // Only use vertical margins to ensure full horizontal width
        // Adjust padding based on screen width for internal spacing
        final horizontalPadding = constraints.maxWidth < 360 ? 4.0 : 8.0;
        
        // Platform-specific styling
        final borderRadius = isIOS ? 22.0 : 16.0; // iOS uses more rounded corners
        
        return Container(
          // Remove bottom margin to eliminate any gap
          margin: const EdgeInsets.only(
            top: 8,
            bottom: 0,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding, 
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            // Only round the top corners to blend with content below
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(borderRadius),
              topRight: Radius.circular(borderRadius),
            ),
            // Remove bottom shadow to prevent white line
            boxShadow: [],
          // Remove border to prevent white line
          border: null,
          ),
          // Fill the entire width of the parent
          width: double.infinity,
          child: Theme(
            // Override tab theme for better interactivity
            data: Theme.of(context).copyWith(
              splashColor: primaryColor.withOpacity(0.1),
              highlightColor: primaryColor.withOpacity(0.05),
            ),
            child: TabBar(
              controller: tabController,
              isScrollable: isScrollable,
              // Add physics for better scrolling experience
              physics: const BouncingScrollPhysics(),
              // Add padding for better touch targets
              padding: EdgeInsets.symmetric(
                horizontal: isIOS ? 4.0 : 2.0,
                vertical: 2.0,
              ),
              // Completely remove the indicator and divider
              indicatorColor: Colors.transparent,
              indicatorWeight: 0,
              indicatorSize: TabBarIndicatorSize.label,
              // Remove the divider at the bottom of the TabBar
              dividerColor: Colors.transparent,
              // Hide any potential scroll indicators
              indicatorPadding: EdgeInsets.zero,
              // More generous padding for better touch targets
              labelPadding: EdgeInsets.symmetric(
                horizontal: isScrollable ? 8.0 : 4.0,
              ),
              // More interactive indicator
              indicator: BoxDecoration(
                color: primaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(isIOS ? 18 : 16),
                // Platform-specific indicator styling
                boxShadow: [
                  if (!isIOS) // Android uses shadow for indicator, iOS doesn't
                    BoxShadow(
                      color: primaryColor.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 0,
                      offset: const Offset(0, 1),
                    ),
                ],
                // iOS uses gradient for indicator
                gradient: isIOS ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    primaryColor.withOpacity(0.2),
                    primaryColor.withOpacity(0.1),
                  ],
                ) : null,
              ),
              // Smoother animation duration
              labelColor: primaryColor,
              unselectedLabelColor: isDarkMode 
                  ? AppColors.textSecondaryDark 
                  : AppColors.textSecondaryLight,
              // Dynamic tab alignment based on scrollable state
              tabAlignment: isScrollable ? TabAlignment.start : TabAlignment.fill,
              // Build tabs with animation
              tabs: tabs.asMap().entries.map((entry) {
                final index = entry.key;
                final tab = entry.value;
                return _buildAnimatedTab(
                  context,
                  index,
                  tab.label,
                  tab.outlinedIcon,
                  tab.filledIcon ?? tab.outlinedIcon,
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedTab(
    BuildContext context,
    int index,
    String label,
    IconData outlinedIcon,
    IconData filledIcon,
  ) {
    final isSelected = currentIndex == index;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final platform = Theme.of(context).platform;
    final isIOS = platform == TargetPlatform.iOS;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Check if we're on a very small screen
        final isVerySmallScreen = constraints.maxWidth < 70;
        final isExtremelySmallScreen = constraints.maxWidth < 50;
        
        // For extremely small screens, just show the icon
        if (isExtremelySmallScreen) {
          return Tab(
            height: 36, // Smaller height
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              child: Icon(
                isSelected ? filledIcon : outlinedIcon,
                size: isSelected ? 20 : 18, // Slightly larger for better visibility
                color: isSelected ? primaryColor : isDarkMode 
                    ? AppColors.textSecondaryDark 
                    : AppColors.textSecondaryLight,
              ),
            ),
          );
        }
        
        return Tab(
          height: 40, // Slightly taller for better touch targets
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: isVerySmallScreen ? 4 : 8, 
              vertical: 6,
            ),
            decoration: isSelected ? BoxDecoration(
              // Add subtle highlight for selected tab
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  primaryColor.withOpacity(0.05),
                  primaryColor.withOpacity(0.01),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ) : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated icon that changes between outlined and filled
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Icon(
                    isSelected ? filledIcon : outlinedIcon,
                    key: ValueKey<bool>(isSelected),
                    size: isSelected ? (isIOS ? 20 : 18) : (isIOS ? 18 : 16), // iOS uses slightly larger icons
                    color: isSelected ? primaryColor : isDarkMode 
                        ? AppColors.textSecondaryDark 
                        : AppColors.textSecondaryLight,
                  ),
                ),
                SizedBox(width: isVerySmallScreen ? 4 : 6),
                // Text label with animation
                Flexible(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: isVerySmallScreen ? (isIOS ? 10 : 11) : (isIOS ? 11 : 12), // Platform-specific font sizing
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? primaryColor : isDarkMode 
                          ? AppColors.textSecondaryDark 
                          : AppColors.textSecondaryLight,
                    ),
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
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
        TabItemData(
          label: 'For You',
          outlinedIcon: Icons.home_outlined,
          filledIcon: Icons.home,
        ),
        TabItemData(
          label: 'All Posts',
          outlinedIcon: Icons.public_outlined,
          filledIcon: Icons.public,
        ),
        TabItemData(
          label: 'ImmiGrove',
          outlinedIcon: Icons.people_outline_rounded,
          filledIcon: Icons.people_rounded,
        ),
        TabItemData(
          label: 'Events',
          outlinedIcon: Icons.event_outlined,
          filledIcon: Icons.event,
        ),
      ],
    );
  }
}
