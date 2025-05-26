import 'package:flutter/material.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/features/home/domain/entities/post.dart';
import 'package:get_it/get_it.dart';

/// A service that handles post interactions (like, comment, share, edit, delete)
/// This service is designed to be used by both the profile and home feed
/// to ensure consistent behavior and UI feedback across the app
class PostInteractionService {
  final UnifiedLogger _logger = GetIt.instance<UnifiedLogger>();
  
  // Singleton pattern
  static final PostInteractionService _instance = PostInteractionService._internal();
  
  factory PostInteractionService() => _instance;
  
  PostInteractionService._internal();
  
  /// Like a post
  /// Returns a Future that completes when the like operation is done
  Future<void> likePost({
    required Post post,
    required Function onSuccess,
    required Function(String) onError,
    required String tag,
  }) async {
    try {
      _logger.d('Liking post: ${post.id}', tag: tag);
      
      // Here you would implement the actual like functionality
      // This could involve calling a repository method
      
      // For now, we'll just call the success callback
      onSuccess();
    } catch (e) {
      _logger.e('Error liking post: $e', tag: tag);
      onError(e.toString());
    }
  }
  
  /// Comment on a post
  /// This typically navigates to a comment screen
  void commentPost({
    required BuildContext context,
    required Post post,
    required Function onNavigate,
    required String tag,
  }) {
    try {
      _logger.d('Commenting on post: ${post.id}', tag: tag);
      
      // Call the navigation callback
      onNavigate();
    } catch (e) {
      _logger.e('Error navigating to comment screen: $e', tag: tag);
      // Show a snackbar with the error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
  
  /// Share a post
  Future<void> sharePost({
    required BuildContext context,
    required Post post,
    required String tag,
  }) async {
    try {
      _logger.d('Sharing post: ${post.id}', tag: tag);
      
      // Here you would implement the actual share functionality
      // This could involve using a platform-specific sharing plugin
      
      // For now, we'll just show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sharing post...')),
      );
    } catch (e) {
      _logger.e('Error sharing post: $e', tag: tag);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
  
  /// Delete a post
  Future<void> deletePost({
    required BuildContext context,
    required Post post,
    required Function onSuccess,
    required Function(String) onError,
    required String tag,
  }) async {
    try {
      _logger.d('Deleting post: ${post.id}', tag: tag);
      
      // Here you would implement the actual delete functionality
      // This could involve calling a repository method
      
      // For now, we'll just call the success callback
      onSuccess();
    } catch (e) {
      _logger.e('Error deleting post: $e', tag: tag);
      onError(e.toString());
    }
  }
  
  /// Edit a post
  Future<void> editPost({
    required BuildContext context,
    required Post post,
    required String newContent,
    required Function onSuccess,
    required Function(String) onError,
    required String tag,
  }) async {
    try {
      _logger.d('Editing post: ${post.id} with new content: $newContent', tag: tag);
      
      // Here you would implement the actual edit functionality
      // This could involve calling a repository method
      
      // For now, we'll just call the success callback
      onSuccess();
    } catch (e) {
      _logger.e('Error editing post: $e', tag: tag);
      onError(e.toString());
    }
  }
}
