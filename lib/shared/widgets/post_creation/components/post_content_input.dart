import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:immigru/features/auth/domain/entities/user.dart';

/// A reusable component for post content input with user info
class PostContentInput extends StatelessWidget {
  /// The current user
  final User user;
  
  /// Text controller for the input field
  final TextEditingController controller;
  
  /// Focus node for the input field
  final FocusNode focusNode;
  
  /// Callback when text changes
  final Function(String) onChanged;
  
  /// Whether to auto-focus the input field
  final bool autoFocus;

  const PostContentInput({
    super.key,
    required this.user,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.autoFocus = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Auto-focus if needed
    if (autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (focusNode.canRequestFocus) {
          FocusScope.of(context).requestFocus(focusNode);
        }
      });
    }
    
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode 
            ? (Colors.grey[900] ?? Colors.grey).withValues(alpha: 0.3) 
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info row
          Row(
            children: [
              // User avatar with subtle border
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: user.photoUrl != null &&
                          user.photoUrl!.startsWith('http')
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                  child: user.photoUrl == null
                      ? Text(
                          user.displayName?[0].toUpperCase() ?? 'U',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              
              // User name and subtle hint
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName ?? 'User',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Posting to your profile',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),

          // Text input field with enhanced styling
          Container(
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? (Colors.grey[850] ?? Colors.grey).withValues(alpha: 0.5) 
                  : (Colors.grey[100] ?? Colors.grey).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Directionality(
                // Force LTR text direction for the entire field
                textDirection: TextDirection.ltr,
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  maxLines: null,
                  minLines: 4,
                  maxLength: 500,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  textCapitalization: TextCapitalization.sentences,
                  textDirection: TextDirection.ltr,
                  onChanged: onChanged,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.black87,
                    height: 1.4,
                  ),
                  decoration: InputDecoration.collapsed(
                    hintText: "What's on your mind?",
                    hintStyle: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  // Remove the built-in counter
                  buildCounter: (context,
                          {required currentLength,
                          required isFocused,
                          maxLength}) =>
                      null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
