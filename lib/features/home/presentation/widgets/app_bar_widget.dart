import 'package:flutter/material.dart';
import 'package:immigru/features/auth/domain/entities/user.dart';
import 'package:immigru/shared/theme/app_colors.dart';
import 'package:immigru/shared/widgets/app_logo.dart';

/// Modern app bar for the home screen
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final User? user;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onNotificationsPressed;

  const HomeAppBar({
    super.key,
    this.user,
    this.onMenuPressed,
    this.onSearchPressed,
    this.onNotificationsPressed,
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
      title: const AppLogo(),
      centerTitle: false,
      leading: IconButton(
        icon: Icon(
          Icons.menu,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
        onPressed: onMenuPressed,
        tooltip: 'Menu',
      ),
      actions: [
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
        
        // Notifications button
        IconButton(
          icon: Stack(
            children: [
              Icon(
                Icons.notifications_outlined,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              // Notification badge
              if (user != null)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: const Text(
                      '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          onPressed: onNotificationsPressed ?? () {
            // Show notifications
          },
          tooltip: 'Notifications',
        ),
        
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
