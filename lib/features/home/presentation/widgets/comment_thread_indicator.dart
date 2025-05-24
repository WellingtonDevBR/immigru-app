import 'package:flutter/material.dart';

/// A widget that visually indicates a comment thread hierarchy
/// Used to show the relationship between parent comments and replies
/// Implements a Facebook-style continuous line system
class CommentThreadIndicator extends StatelessWidget {
  /// The level of indentation (0 = root comment, 1 = first reply, etc.)
  final int level;

  /// The left padding of the comment
  final double leftPadding;

  /// Whether the thread is expanded or collapsed
  final bool isExpanded;

  /// Height of the indicator
  final double height;
  
  /// Whether this is the first comment in a thread
  final bool isFirstInThread;
  
  /// Whether this is the last comment in a thread
  final bool isLastInThread;
  
  /// Whether to show parent thread lines (for nested replies)
  final bool showParentLines;

  /// Creates a comment thread indicator
  const CommentThreadIndicator({
    Key? key,
    required this.level,
    required this.leftPadding,
    this.isExpanded = true,
    this.height = 40.0,
    this.isFirstInThread = false,
    this.isLastInThread = false,
    this.showParentLines = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // No indicator for root comments or collapsed threads
    if (level == 0 || !isExpanded) return const SizedBox.shrink();
    
    // Facebook uses a specific light gray color for thread lines
    final lineColor = const Color(0xFFBEC2C9);
    
    // Position the line exactly like Facebook does - at a fixed distance from the left
    // This creates the consistent vertical alignment seen in the Facebook example
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Positioned(
            left: 36.0 + ((level - 1) * 12.0), // Fixed position from left edge
            top: 0,
            bottom: 0,
            width: 1.5, // Facebook uses a thin line
            child: Container(
              color: lineColor,
            ),
          ),
        ],
      ),
    );
  }
}
