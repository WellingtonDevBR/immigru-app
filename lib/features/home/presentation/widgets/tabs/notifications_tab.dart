import 'package:flutter/material.dart';
import 'package:immigru/features/auth/domain/entities/user.dart';
import 'package:immigru/core/logging/unified_logger.dart';

/// Notifications tab for the home screen
class NotificationsTab extends StatefulWidget {
  final User? user;

  const NotificationsTab({
    super.key,
    this.user,
  });

  @override
  State<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {
  final _logger = UnifiedLogger();

  @override
  void initState() {
    super.initState();
    _logger.d('Notifications tab initialized', tag: 'NotificationsTab');
    // In a real implementation, we would fetch notifications here
    // BlocProvider.of<HomeBloc>(context).add(FetchNotifications(userId: widget.user?.id));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () async {
        _logger.d('Refreshing notifications', tag: 'NotificationsTab');
        // In a real implementation, we would refresh notifications here
        // BlocProvider.of<HomeBloc>(context).add(FetchNotifications(userId: widget.user?.id));
        await Future.delayed(const Duration(seconds: 1));
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Notifications',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          // Demo notifications
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildNotificationItem(context, index);
              },
              childCount: 10, // Demo count
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, int index) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Demo notification types
    final notificationTypes = [
      'liked your post',
      'commented on your post',
      'mentioned you in a comment',
      'invited you to join an ImmiGrove',
      'shared your post',
    ];

    final randomType = notificationTypes[index % notificationTypes.length];
    final isUnread = index < 3; // First 3 are unread for demo

    return Container(
      color: isUnread
          ? (isDarkMode
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.primary.withValues(alpha: 0.05))
          : Colors.transparent,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage:
              NetworkImage('https://i.pravatar.cc/150?img=${index + 10}'),
        ),
        title: RichText(
          text: TextSpan(
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black87,
              fontSize: 14,
            ),
            children: [
              TextSpan(
                text: 'User ${index + 1} ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: randomType),
            ],
          ),
        ),
        subtitle: Text(
          index < 2 ? 'Just now' : '$index hours ago',
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.more_horiz,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
          onPressed: () {
            _logger.d('Notification options pressed', tag: 'NotificationsTab');
            // Show options menu
          },
        ),
        onTap: () {
          _logger.d('Notification tapped: $index', tag: 'NotificationsTab');
          // Navigate to the relevant content
        },
      ),
    );
  }
}
