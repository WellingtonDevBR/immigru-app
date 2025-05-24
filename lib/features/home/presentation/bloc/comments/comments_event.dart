part of 'comments_bloc.dart';

/// Base class for all comments events
abstract class CommentsEvent extends Equatable {
  const CommentsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load comments for a post
class LoadComments extends CommentsEvent {
  /// ID of the post to load comments for
  final String postId;

  /// Maximum number of comments to load
  final int limit;

  /// Pagination offset
  final int offset;

  /// Create a new LoadComments event
  const LoadComments({
    required this.postId,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [postId, limit, offset];
}

/// Event to create a new comment
class CreateComment extends CommentsEvent {
  /// ID of the post to comment on
  final String postId;

  /// ID of the user creating the comment
  final String userId;

  /// Content of the comment
  final String content;

  /// ID of the parent comment (if this is a reply)
  final String? parentCommentId;

  /// ID of the root comment in the thread (for nested replies)
  final String? rootCommentId;

  /// Depth level of the comment (1 = direct post comment, 2 = reply to comment, 3 = reply to reply)
  final int depth;

  /// Create a new CreateComment event
  const CreateComment({
    required this.postId,
    required this.userId,
    required this.content,
    this.parentCommentId,
    this.rootCommentId,
    this.depth = 1,
  });

  @override
  List<Object?> get props =>
      [postId, userId, content, parentCommentId, rootCommentId, depth];
}

/// Event to edit an existing comment
class EditComment extends CommentsEvent {
  /// ID of the comment to edit
  final String commentId;

  /// ID of the post the comment belongs to
  final String postId;

  /// ID of the user editing the comment (must be the author)
  final String userId;

  /// New content for the comment
  final String content;

  /// Create a new EditComment event
  const EditComment({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.content,
  });

  @override
  List<Object?> get props => [commentId, postId, userId, content];
}

/// Event to delete a comment
class DeleteComment extends CommentsEvent {
  /// ID of the comment to delete
  final String commentId;

  /// ID of the post the comment belongs to
  final String postId;

  /// ID of the user deleting the comment (must be the author)
  final String userId;

  /// Create a new DeleteComment event
  const DeleteComment({
    required this.commentId,
    required this.postId,
    required this.userId,
  });

  @override
  List<Object?> get props => [commentId, postId, userId];
}

/// Event to like a comment
class LikeComment extends CommentsEvent {
  /// ID of the comment to like
  final String commentId;
  
  /// ID of the user liking the comment
  final String userId;
  
  /// Create a new LikeComment event
  const LikeComment({
    required this.commentId,
    required this.userId,
  });
  
  @override
  List<Object?> get props => [commentId, userId];
}

/// Event to unlike a comment
class UnlikeComment extends CommentsEvent {
  /// ID of the comment to unlike
  final String commentId;
  
  /// ID of the user unliking the comment
  final String userId;
  
  /// Create a new UnlikeComment event
  const UnlikeComment({
    required this.commentId,
    required this.userId,
  });
  
  @override
  List<Object?> get props => [commentId, userId];
}
