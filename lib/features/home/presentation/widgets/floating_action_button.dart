import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Modern floating action button for the home screen
class HomeFloatingActionButton extends StatelessWidget {
  final int currentIndex;
  final VoidCallback onCreatePost;

  const HomeFloatingActionButton({
    super.key,
    required this.currentIndex,
    required this.onCreatePost,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Different FAB for different tabs
    Widget fab;
    
    switch (currentIndex) {
      case 0: // For You tab
      case 1: // Explore tab
        fab = FloatingActionButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            onCreatePost();
          },
          backgroundColor: theme.colorScheme.primary,
          tooltip: 'Create Post',
          child: const Icon(Icons.add),
        );
        break;
      case 2: // ImmiGroves tab
        fab = FloatingActionButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            // Show ImmiGrove joining options
          },
          backgroundColor: theme.colorScheme.primary,
          tooltip: 'Join ImmiGrove',
          child: const Icon(Icons.group_add),
        );
        break;
      case 3: // Events tab
        fab = FloatingActionButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            // Show event creation or registration
          },
          backgroundColor: theme.colorScheme.primary,
          tooltip: 'Register for Event',
          child: const Icon(Icons.event_available),
        );
        break;
      default:
        fab = FloatingActionButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            onCreatePost();
          },
          backgroundColor: theme.colorScheme.primary,
          tooltip: 'Create Post',
          child: const Icon(Icons.add),
        );
    }
    
    // Add animation for smooth transitions
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
      child: fab,
    );
  }
}
