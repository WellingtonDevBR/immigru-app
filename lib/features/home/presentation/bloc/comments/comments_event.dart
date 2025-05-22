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

  /// Create a new CreateComment event
  const CreateComment({
    required this.postId,
    required this.userId,
    required this.content,
    this.parentCommentId,
  });

  @override
  List<Object?> get props => [postId, userId, content, parentCommentId];
}
