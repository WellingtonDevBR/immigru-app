import 'package:flutter/material.dart';
import 'package:immigru/core/services/logger_service.dart';

class HomeFloatingActionButton extends StatelessWidget {
  final int currentIndex;
  final VoidCallback onCreatePost;
  final LoggerService logger;

  const HomeFloatingActionButton({
    super.key,
    required this.currentIndex,
    required this.onCreatePost,
    required this.logger,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width >= 768;
    
    // Determine icon and label based on current tab
    IconData icon;
    String label;
    Color backgroundColor = Theme.of(context).colorScheme.primary;
    
    switch (currentIndex) {
      case 0: // For You
      case 1: // All Posts
        icon = Icons.edit;
        label = 'Post';
        break;
      case 2: // My ImmiGroves
        icon = Icons.upload_file;
        label = 'Document';
        backgroundColor = Colors.green;
        break;
      case 3: // Events
        icon = Icons.event_available;
        label = 'Event';
        backgroundColor = Colors.orange;
        break;
      default:
        icon = Icons.add;
        label = 'Create';
    }
    
    // For tablet and desktop, use an extended FAB with label
    if (isTablet) {
      return FloatingActionButton.extended(
        onPressed: () => _handlePress(context),
        backgroundColor: backgroundColor,
        icon: Icon(icon),
        label: Text(label),
        elevation: 4,
        highlightElevation: 8,
      );
    }
    
    // For mobile, use a regular FAB with animation
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(28),
      ),
      child: FloatingActionButton(
        onPressed: () => _handlePress(context),
        backgroundColor: backgroundColor,
        tooltip: 'Create new $label',
        elevation: 0, // We're using our own shadow
        highlightElevation: 0,
        child: Icon(
          icon,
          size: 24,
        ),
      ),
    );
  }

  void _handlePress(BuildContext context) {
    // Show different actions based on current tab
    switch (currentIndex) {
      case 0: // For You
      case 1: // All Posts
        onCreatePost();
        break;
      case 2: // My ImmiGroves
        // TODO: Implement create new ImmiGrove
        logger.debug('HomeScreen', 'Create new ImmiGrove');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document upload feature coming soon!'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 3: // Events
        // TODO: Implement create new event
        logger.debug('HomeScreen', 'Create new event');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Create event feature coming soon!'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        break;
    }
  }
}
