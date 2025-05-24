import 'package:equatable/equatable.dart';

/// Events for the home screen
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch posts
class FetchPosts extends HomeEvent {
  /// Optional category filter
  final String? category;

  /// ID of the current user (to exclude their posts)
  final String? currentUserId;

  /// Whether to refresh the posts
  final bool refresh;

  const FetchPosts({
    this.category,
    this.currentUserId,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [
        category,
        currentUserId,
        refresh,
      ];
}

/// Event to fetch more posts (pagination)
class FetchMorePosts extends HomeEvent {
  /// Optional category filter
  final String? category;

  /// ID of the current user (to exclude their posts)
  final String? currentUserId;

  const FetchMorePosts({
    this.category,
    this.currentUserId,
  });

  @override
  List<Object?> get props => [
        category,
        currentUserId,
      ];
}

/// Event to create a post
class CreatePost extends HomeEvent {
  final String content;
  final String userId;
  final String category;
  final String? imageUrl;

  const CreatePost({
    required this.content,
    required this.userId,
    required this.category,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [content, userId, category, imageUrl];
}

/// Event to like or unlike a post
class LikePost extends HomeEvent {
  final String postId;
  final String userId;
  final bool like;

  const LikePost({
    required this.postId,
    required this.userId,
    required this.like,
  });

  @override
  List<Object> get props => [postId, userId, like];
}

/// Event to register for an event
class RegisterForEvent extends HomeEvent {
  final String eventId;
  final String userId;

  const RegisterForEvent({
    required this.eventId,
    required this.userId,
  });

  @override
  List<Object> get props => [eventId, userId];
}

/// Event to select a category
class SelectCategory extends HomeEvent {
  final String category;

  const SelectCategory({
    required this.category,
  });

  @override
  List<Object> get props => [category];
}

/// Event to handle errors in the home screen
class HomeError extends HomeEvent {
  /// Error message
  final String message;

  /// Constructor
  const HomeError({
    required this.message,
  });

  @override
  List<Object> get props => [message];
}

/// Event to initialize home screen data
class InitializeHomeData extends HomeEvent {
  /// Current user ID (optional)
  final String? userId;

  /// Selected category (optional)
  final String? category;

  /// Whether to force refresh
  final bool forceRefresh;

  /// Constructor
  const InitializeHomeData({
    this.userId,
    this.category,
    this.forceRefresh = true,
  });

  @override
  List<Object?> get props => [userId, category, forceRefresh];
}

/// Event to edit a post
class EditPost extends HomeEvent {
  final String postId;
  final String userId;
  final String content;
  final String category;

  const EditPost({
    required this.postId,
    required this.userId,
    required this.content,
    required this.category,
  });

  @override
  List<Object> get props => [postId, userId, content, category];
}

/// Event to delete a post (soft delete by setting DeletedAt)
class DeletePost extends HomeEvent {
  /// ID of the post to delete
  final String postId;

  /// Create a new DeletePost event
  const DeletePost({
    required this.postId,
  });

  @override
  List<Object?> get props => [postId];
}

/// Event to update a post's hasUserComment flag
class UpdatePostHasUserComment extends HomeEvent {
  /// ID of the post to update
  final String postId;
  
  /// Whether the current user has commented on this post
  final bool hasUserComment;

  /// Create a new UpdatePostHasUserComment event
  const UpdatePostHasUserComment({
    required this.postId,
    required this.hasUserComment,
  });

  @override
  List<Object?> get props => [postId, hasUserComment];
}
