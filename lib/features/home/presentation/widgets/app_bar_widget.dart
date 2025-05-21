import 'package:flutter/material.dart';
import 'package:immigru/features/auth/domain/entities/user.dart';
import 'package:immigru/shared/theme/app_colors.dart';
import 'package:immigru/shared/widgets/app_logo.dart';

/// Modern app bar for the home screen with Facebook-like design
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final User? user;
  final VoidCallback? onSearchPressed;
  final bool hasUnreadMessages;
  final int unreadMessageCount;

  const HomeAppBar({
    super.key,
    this.user,
    this.onSearchPressed,
    this.hasUnreadMessages = false,
    this.unreadMessageCount = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

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
          onPressed: onSearchPressed ?? () {
            // Show search dialog
            showSearch(
              context: context,
              delegate: _HomeSearchDelegate(),
            );
          },
          tooltip: 'Search',
        ),
        
        // Add a small spacing
        const SizedBox(width: 8),
      ],
    );
  }
}

/// Search delegate for the home screen
class _HomeSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Implement search results
    return Center(
      child: Text('Search results for: $query'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Implement search suggestions
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('Immigration News'),
          onTap: () {
            query = 'Immigration News';
            showResults(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('Legal Advice'),
          onTap: () {
            query = 'Legal Advice';
            showResults(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('Community Events'),
          onTap: () {
            query = 'Community Events';
            showResults(context);
          },
        ),
      ],
    );
  }
}
