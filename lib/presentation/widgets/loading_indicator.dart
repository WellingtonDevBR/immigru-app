import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A loading indicator widget
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final Color? color;
  final double size;

  const LoadingIndicator({
    super.key,
    this.message,
    this.color,
    this.size = 36.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor = color ?? theme.colorScheme.primary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
              strokeWidth: 3.0,
            ),
          ),
          if (message != null) ...[            
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                fontSize: 16,
                color: theme.textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// A shimmer loading list that can be used across the application
/// for consistent loading states
class ShimmerLoadingList extends StatelessWidget {
  /// Number of items to show in the loading state
  final int itemCount;
  
  /// Height of each item
  final double itemHeight;
  
  /// Padding around each item
  final EdgeInsetsGeometry itemPadding;
  
  /// Border radius for the items
  final double borderRadius;
  
  /// Whether the current theme is dark mode
  final bool? isDarkMode;

  const ShimmerLoadingList({
    super.key,
    this.itemCount = 10,
    this.itemHeight = 70,
    this.itemPadding = const EdgeInsets.symmetric(vertical: 8.0),
    this.borderRadius = 12.0,
    this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = isDarkMode ?? theme.brightness == Brightness.dark;
    
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: ListView.builder(
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Padding(
            padding: itemPadding,
            child: Container(
              height: itemHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A reusable error state widget for consistent error displays
class ErrorStateWidget extends StatelessWidget {
  /// Error message to display
  final String? errorMessage;
  
  /// Default error title
  final String title;
  
  /// Callback when retry button is pressed
  final VoidCallback? onRetry;

  const ErrorStateWidget({
    super.key,
    this.errorMessage,
    this.title = 'Oops! Something went wrong',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(errorMessage ?? 'An error occurred'),
          if (onRetry != null) ...[            
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Try Again'),
            ),
          ],
        ],
      ),
    );
  }
}

/// A reusable empty state widget for consistent empty displays
class EmptyStateWidget extends StatelessWidget {
  /// Empty state message
  final String message;
  
  /// Icon to display
  final IconData icon;
  
  /// Action button text
  final String? actionText;
  
  /// Callback when action button is pressed
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    this.message = 'No items found',
    this.icon = Icons.search_off,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          if (actionText != null && onAction != null) ...[            
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAction,
              child: Text(actionText!),
            ),
          ],
        ],
      ),
    );
  }
}
