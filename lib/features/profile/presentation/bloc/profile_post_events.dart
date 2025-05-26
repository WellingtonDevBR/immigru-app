import 'package:immigru/features/profile/presentation/bloc/profile_event.dart';

/// Event to like or unlike a user post in the profile
class LikeUserPost extends ProfileEvent {
  /// ID of the post to like/unlike
  final String postId;
  
  /// Whether to like (true) or unlike (false) the post
  final bool isLiked;

  /// Constructor
  const LikeUserPost({
    required this.postId,
    required this.isLiked,
  });

  @override
  List<Object?> get props => [postId, isLiked];
}

/// Event to delete a user post from the profile
class DeleteUserPost extends ProfileEvent {
  /// ID of the post to delete
  final String postId;

  /// Constructor
  const DeleteUserPost({
    required this.postId,
  });

  @override
  List<Object?> get props => [postId];
}

/// Event to update a user post's content
class UpdateUserPost extends ProfileEvent {
  /// ID of the post to update
  final String postId;
  
  /// New content for the post
  final String content;

  /// Constructor
  const UpdateUserPost({
    required this.postId,
    required this.content,
  });

  @override
  List<Object?> get props => [postId, content];
}

/// Event to update a post's comment status
class UpdateUserPostCommentStatus extends ProfileEvent {
  /// ID of the post to update
  final String postId;
  
  /// Whether the user has commented on this post
  final bool hasUserComment;

  /// Constructor
  const UpdateUserPostCommentStatus({
    required this.postId,
    required this.hasUserComment,
  });

  @override
  List<Object?> get props => [postId, hasUserComment];
}
