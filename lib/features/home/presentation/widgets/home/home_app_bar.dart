import 'package:flutter/material.dart';
import 'package:immigru/features/auth/domain/entities/user.dart';
import 'package:immigru/shared/theme/app_colors.dart';
import 'package:immigru/shared/widgets/app_logo.dart';

/// Custom AppBar for the Home screen
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final User? user;
  final bool hasUnreadMessages;
  final int unreadMessageCount;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const HomeAppBar({
    super.key,
    required this.user,
    this.hasUnreadMessages = false,
    this.unreadMessageCount = 0,
    this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AppBar(
      backgroundColor: isDarkMode ? AppColors.darkSurface : Colors.white,
      elevation: 0,
      title: const AppLogo(height: 28),
      centerTitle: false,
      automaticallyImplyLeading: false, // Remove default drawer button
      // No leading widget to remove the menu button from top app bar
      actions: [
        // Chat button with badge for unread messages
        IconButton(
          icon: Badge(
            label: Text('$unreadMessageCount'),
            isLabelVisible: hasUnreadMessages,
            child: Icon(
              Icons.chat_bubble_outline,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          onPressed: () => Navigator.pushNamed(context, '/chat'),
          tooltip: 'Chat',
        ),
        // Search button
        IconButton(
          icon: Icon(
            Icons.search,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pushNamed(context, '/search'),
          tooltip: 'Search',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
