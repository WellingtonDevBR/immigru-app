part of 'comments_bloc.dart';

/// Base class for all comments states
abstract class CommentsState extends Equatable {
  const CommentsState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state before any events are dispatched
class CommentsInitial extends CommentsState {}

/// State when comments are being loaded
class CommentsLoading extends CommentsState {
  /// Current comments (if available)
  final List<PostComment>? comments;

  /// Create a new CommentsLoading state
  const CommentsLoading({this.comments});

  @override
  List<Object?> get props => [comments];
}

/// State when comments are successfully loaded
class CommentsLoaded extends CommentsState {
  /// List of comments
  final List<PostComment> comments;

  /// Create a new CommentsLoaded state
  const CommentsLoaded({required this.comments});

  @override
  List<Object?> get props => [comments];
}

/// State when there's an error loading comments
class CommentsError extends CommentsState {
  /// Error message
  final String message;

  /// Create a new CommentsError state
  const CommentsError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State when comments are being updated (edit, delete, etc.)
class CommentsUpdating extends CommentsState {
  /// Current comments
  final List<PostComment> comments;

  /// Create a new CommentsUpdating state
  const CommentsUpdating({required this.comments});

  @override
  List<Object?> get props => [comments];
}
