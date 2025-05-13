import 'package:flutter/material.dart';

/// A header widget for the migration journey step
class MigrationJourneyHeader extends StatelessWidget {
  const MigrationJourneyHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            'Add countries you\'ve lived in, stayed temporarily, or even visited — every place that\'s part of your story.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
