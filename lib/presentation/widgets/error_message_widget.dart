import 'package:flutter/material.dart';

/// A reusable widget for displaying error messages with optional action buttons
/// 
/// This widget can be used to display error messages in a consistent way across the app.
/// It supports displaying a single error message with optional primary and secondary actions.
class ErrorMessageWidget extends StatelessWidget {
  /// The error message to display
  final String message;
  
  /// The icon to display (defaults to error_outline)
  final IconData icon;
  
  /// The color of the icon and border (defaults to red)
  final Color color;
  
  /// The text for the primary action button
  final String? primaryActionText;
  
  /// The callback for the primary action button
  final VoidCallback? onPrimaryAction;
  
  /// The text for the secondary action button
  final String? secondaryActionText;
  
  /// The callback for the secondary action button
  final VoidCallback? onSecondaryAction;
  
  /// Whether to show a close button (defaults to true)
  final bool showCloseButton;
  
  /// Callback when the widget is dismissed (if showCloseButton is true)
  final VoidCallback? onDismiss;

  const ErrorMessageWidget({
    super.key,
    required this.message,
    this.icon = Icons.error_outline,
    this.color = Colors.red,
    this.primaryActionText,
    this.onPrimaryAction,
    this.secondaryActionText,
    this.onSecondaryAction,
    this.showCloseButton = true,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
              if (showCloseButton)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onDismiss,
                ),
            ],
          ),
          if (primaryActionText != null || secondaryActionText != null)
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 36),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (secondaryActionText != null)
                    TextButton(
                      onPressed: onSecondaryAction,
                      child: Text(secondaryActionText!),
                    ),
                  if (primaryActionText != null) ...[
                    if (secondaryActionText != null)
                      const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: onPrimaryAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(primaryActionText!),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// A dialog version of the error message widget
class ErrorDialog extends StatelessWidget {
  /// The error message to display
  final String message;
  
  /// The title of the dialog
  final String title;
  
  /// The text for the primary action button
  final String primaryActionText;
  
  /// The callback for the primary action button
  final VoidCallback? onPrimaryAction;
  
  /// The text for the secondary action button
  final String? secondaryActionText;
  
  /// The callback for the secondary action button
  final VoidCallback? onSecondaryAction;

  const ErrorDialog({
    super.key,
    required this.message,
    this.title = 'Error',
    this.primaryActionText = 'OK',
    this.onPrimaryAction,
    this.secondaryActionText,
    this.onSecondaryAction,
  });

  /// Show the error dialog
  static Future<void> show({
    required BuildContext context,
    required String message,
    String title = 'Error',
    String primaryActionText = 'OK',
    VoidCallback? onPrimaryAction,
    String? secondaryActionText,
    VoidCallback? onSecondaryAction,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => ErrorDialog(
        message: message,
        title: title,
        primaryActionText: primaryActionText,
        onPrimaryAction: onPrimaryAction ?? () => Navigator.of(context).pop(),
        secondaryActionText: secondaryActionText,
        onSecondaryAction: onSecondaryAction,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        if (secondaryActionText != null)
          TextButton(
            onPressed: onSecondaryAction ?? () => Navigator.of(context).pop(),
            child: Text(secondaryActionText!),
          ),
        ElevatedButton(
          onPressed: onPrimaryAction ?? () => Navigator.of(context).pop(),
          child: Text(primaryActionText),
        ),
      ],
    );
  }
}
