import 'package:flutter/material.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/features/home/domain/entities/post.dart';
import 'package:immigru/features/home/presentation/bloc/home_bloc.dart';
import 'package:immigru/features/home/presentation/screens/post_comments_screen.dart';
import 'package:immigru/shared/services/post_interaction_service.dart';
import 'package:get_it/get_it.dart';

/// A class that provides standardized handlers for post actions
/// This ensures consistent behavior across different parts of the app
class PostActionHandlers {
  final BuildContext context;
  final String tag;
  final Function(Post) onPostUpdated;
  final Function(Post)? onPostDeleted;
  final String userId;
  final HomeBloc? homeBloc;
  
  final UnifiedLogger _logger = GetIt.instance<UnifiedLogger>();
  final PostInteractionService _postInteractionService = PostInteractionService();
  
  PostActionHandlers({
    required this.context,
    required this.tag,
    required this.onPostUpdated,
    required this.userId,
    this.homeBloc,
    this.onPostDeleted,
  });
  
  /// Handle like action on a post
  void handleLike(Post post) {
    _postInteractionService.likePost(
      post: post,
      onSuccess: () {
        // Create a new post with updated like status
        final updatedPost = Post(
          id: post.id,
          userId: post.userId,
          content: post.content,
          imageUrl: post.imageUrl,
          createdAt: post.createdAt,
          category: post.category,
          updatedAt: post.updatedAt,
          likeCount: post.isLiked ? post.likeCount - 1 : post.likeCount + 1,
          commentCount: post.commentCount,
          isLiked: !post.isLiked,
          hasUserComment: post.hasUserComment,
          userName: post.userName,
          userAvatar: post.userAvatar,
          location: post.location,
          author: post.author,
        );
        
        // Call the callback with the updated post
        onPostUpdated(updatedPost);
        
        _logger.d('Post ${post.id} like status updated to: ${!post.isLiked}', tag: tag);
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error liking post: $error')),
        );
      },
      tag: tag,
    );
  }
  
  /// Handle comment action on a post
  void handleComment(Post post) {
    _postInteractionService.commentPost(
      context: context,
      post: post,
      onNavigate: () {
        // Navigate to the comments screen like in the home feed
        if (homeBloc != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PostCommentsScreen(
                post: post,
                userId: userId,
                homeBloc: homeBloc!,
              ),
            ),
          ).then((updatedPost) {
            // Handle the returned updated post if any
            if (updatedPost != null && updatedPost is Post) {
              onPostUpdated(updatedPost);
              _logger.d('Post updated after returning from comments screen', tag: tag);
            }
          });
        } else {
          // Fallback to dialog if HomeBloc is not available
          _logger.w('HomeBloc not available for comments screen, showing dialog instead', tag: tag);
          final textController = TextEditingController();
          
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Add Comment'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Commenting on post by ${post.userName ?? "Unknown"}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: textController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Write your comment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final comment = textController.text.trim();
                    if (comment.isNotEmpty) {
                      Navigator.pop(context);
                      
                      // Show a success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Comment added successfully')),
                      );
                      
                      // Update the post with the new comment count and status
                      final updatedPost = Post(
                        id: post.id,
                        userId: post.userId,
                        content: post.content,
                        imageUrl: post.imageUrl,
                        createdAt: post.createdAt,
                        updatedAt: post.updatedAt,
                        likeCount: post.likeCount,
                        category: post.category,
                        commentCount: post.commentCount + 1, // Increment comment count
                        isLiked: post.isLiked,
                        hasUserComment: true, // Assume the user commented
                        userName: post.userName,
                        userAvatar: post.userAvatar,
                        location: post.location,
                        author: post.author,
                      );
                      
                      onPostUpdated(updatedPost);
                      _logger.d('Added comment to post ${post.id}', tag: tag);
                    }
                  },
                  child: const Text('Post'),
                ),
              ],
            ),
          );
        }
      },
      tag: tag,
    );
  }
  
  /// Handle share action on a post
  void handleShare(Post post) {
    _postInteractionService.sharePost(
      context: context,
      post: post,
      tag: tag,
    );
  }
  
  /// Handle delete action on a post
  void handleDelete(Post post) {
    // Show a confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              
              _postInteractionService.deletePost(
                context: context,
                post: post,
                onSuccess: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Post deleted successfully')),
                  );
                  
                  if (onPostDeleted != null) {
                    onPostDeleted!(post);
                  }
                },
                onError: (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting post: $error')),
                  );
                },
                tag: tag,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  /// Handle edit action on a post
  void handleEdit(Post post) {
    // Show an edit dialog
    final textController = TextEditingController(text: post.content);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Post'),
        content: TextField(
          controller: textController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Edit your post...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newContent = textController.text.trim();
              if (newContent.isNotEmpty) {
                Navigator.pop(context);
                
                _postInteractionService.editPost(
                  context: context,
                  post: post,
                  newContent: newContent,
                  onSuccess: () {
                    // Create an updated post with the new content
                    final updatedPost = Post(
                      id: post.id,
                      userId: post.userId,
                      content: newContent,
                      imageUrl: post.imageUrl,
                      createdAt: post.createdAt,
                      category: post.category,
                      updatedAt: DateTime.now(), // Update the timestamp
                      likeCount: post.likeCount,
                      commentCount: post.commentCount,
                      isLiked: post.isLiked,
                      hasUserComment: post.hasUserComment,
                      userName: post.userName,
                      userAvatar: post.userAvatar,
                      location: post.location,
                      author: post.author,
                    );
                    
                    onPostUpdated(updatedPost);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Post updated successfully')),
                    );
                  },
                  onError: (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating post: $error')),
                    );
                  },
                  tag: tag,
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
