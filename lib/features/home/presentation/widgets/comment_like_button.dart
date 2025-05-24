import 'package:flutter/material.dart';

/// A button that allows users to like/unlike a comment
class CommentLikeButton extends StatefulWidget {
  /// Whether the comment is currently liked by the user
  final bool isLiked;
  
  /// The number of likes the comment has
  final int likeCount;
  
  /// Callback when the like button is tapped
  final VoidCallback onTap;
  
  /// Size of the like button icon
  final double size;
  
  /// Create a new CommentLikeButton
  const CommentLikeButton({
    super.key,
    required this.isLiked,
    required this.likeCount,
    required this.onTap,
    this.size = 16.0,
  });

  @override
  State<CommentLikeButton> createState() => _CommentLikeButtonState();
}

class _CommentLikeButtonState extends State<CommentLikeButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  void didUpdateWidget(CommentLikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Animate when the like status changes
    if (widget.isLiked != oldWidget.isLiked && widget.isLiked) {
      _controller.forward(from: 0.0);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Colors for the like button
    final unlikedColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];
    
    return InkWell(
      onTap: () {
        // Start animation when the user taps the like button
        if (!widget.isLiked) {
          _controller.forward(from: 0.0);
        }
        widget.onTap();
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Icon(
                    widget.isLiked ? Icons.favorite : Icons.favorite_border,
                    size: widget.size,
                    color: widget.isLiked ? Colors.red : unlikedColor,
                  ),
                );
              },
            ),
            const SizedBox(width: 4),
            Text(
              widget.likeCount > 0 ? widget.likeCount.toString() : 'Like',
              style: TextStyle(
                fontSize: widget.size * 0.8,
                fontWeight: FontWeight.w500,
                color: widget.isLiked ? Colors.red : unlikedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
