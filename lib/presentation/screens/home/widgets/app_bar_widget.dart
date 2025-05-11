import 'package:flutter/material.dart';
import 'package:immigru/core/services/logger_service.dart';
import 'package:immigru/domain/entities/user.dart';
import 'package:immigru/presentation/theme/app_colors.dart';
import 'package:immigru/presentation/widgets/app_logo.dart';

/// A professional app bar for the home screen with just the logo and search button
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final User? user;
  final VoidCallback onSignOut;
  final LoggerService logger;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onChatPressed;

  const HomeAppBar({
    super.key,
    required this.user,
    required this.onSignOut,
    required this.logger,
    this.onSearchPressed,
    this.onChatPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Get the platform and adjust accordingly
    final platform = Theme.of(context).platform;
    final isIOS = platform == TargetPlatform.iOS;

    // Platform-specific measurements following industry standards
    // iOS: Uses SF Pro Display font, larger horizontal padding, more rounded corners
    // Android: Uses Roboto font, tighter padding, more square corners
    final horizontalPadding = isIOS ? 16.0 : 12.0;
    final elevation =
        isIOS ? 0.0 : 1.0; // iOS prefers flat, Android uses elevation
    final iconSize = isIOS ? 24.0 : 22.0; // iOS icons slightly larger

    return AppBar(
      title: const AppLogo(),
      centerTitle: isIOS, // iOS centers title, Android aligns left
      backgroundColor: isDarkMode ? AppColors.darkSurface : Colors.white,
      elevation: elevation,
      titleSpacing: horizontalPadding, // Proper safe area margin
      // Platform-specific shape
      shape: isIOS
          ? null
          : const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(4)),
            ),
      // Add padding to ensure content doesn't hit screen edges
      leadingWidth: 0, // Remove default leading space
      actions: [
        // Search button
        IconButton(
          icon: Icon(
            isIOS ? Icons.search : Icons.search_outlined,
            size: iconSize,
          ),
          onPressed: onSearchPressed,
          tooltip: 'Search',
          // Platform-specific styling
          style: ButtonStyle(
            tapTargetSize: isIOS
                ? MaterialTapTargetSize.padded
                : MaterialTapTargetSize.shrinkWrap,
            minimumSize: WidgetStateProperty.all(
                Size(isIOS ? 44 : 48, isIOS ? 44 : 48)),
          ),
        ),
        // Chat button
        IconButton(
          icon: Icon(
            isIOS ? Icons.chat_bubble_outline : Icons.chat_outlined,
            size: iconSize,
          ),
          onPressed: onChatPressed,
          tooltip: 'Chat',
          // Platform-specific styling
          style: ButtonStyle(
            tapTargetSize: isIOS
                ? MaterialTapTargetSize.padded
                : MaterialTapTargetSize.shrinkWrap,
            minimumSize: WidgetStateProperty.all(
                Size(isIOS ? 44 : 48, isIOS ? 44 : 48)),
          ),
        ),
        // Add proper padding at the end for iOS
        if (isIOS) const SizedBox(width: 4),
      ],
    );
  }
}
