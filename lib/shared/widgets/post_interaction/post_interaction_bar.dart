import 'package:flutter/material.dart';
import 'package:immigru/features/home/domain/entities/post.dart';
import 'package:immigru/shared/widgets/post_interaction/post_action_button.dart';

/// A standardized interaction bar for posts (like, comment, share)
/// This ensures consistent styling and behavior across the app
class PostInteractionBar extends StatelessWidget {
  final Post post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback? onShare;
  final bool showShareButton;
  
  const PostInteractionBar({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    this.onShare,
    this.showShareButton = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Like button
          Expanded(
            child: PostActionButton(
              icon: Icons.favorite_border,
              activeIcon: Icons.favorite,
              label: 'Like',
              isActive: post.isLiked,
              onPressed: onLike,
              count: post.likeCount > 0 ? post.likeCount : null,
              activeColor: Colors.green.shade600,
            ),
          ),
          
          // Comment button
          Expanded(
            child: PostActionButton(
              icon: Icons.comment_outlined,
              activeIcon: Icons.comment,
              label: 'Comment',
              isActive: post.hasUserComment,
              onPressed: onComment,
              count: post.commentCount > 0 ? post.commentCount : null,
              activeColor: Colors.green.shade600,
            ),
          ),
          
          // Share button - only shown if showShareButton is true
          if (showShareButton && onShare != null)
            Expanded(
              child: PostActionButton(
                icon: Icons.share_outlined,
                label: 'Share',
                isActive: false, // Share doesn't have an active state
                onPressed: onShare!,
              ),
            ),
        ],
      ),
    );
  }
}
