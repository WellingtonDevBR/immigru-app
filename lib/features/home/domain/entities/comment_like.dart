import 'package:equatable/equatable.dart';

/// Entity class for a like on a comment
class CommentLike extends Equatable {
  /// Unique identifier for the like
  final String id;
  
  /// ID of the comment this like belongs to
  final String commentId;
  
  /// ID of the user who created the like
  final String userId;
  
  /// When the like was created
  final DateTime createdAt;

  /// Create a new CommentLike
  const CommentLike({
    required this.id,
    required this.commentId,
    required this.userId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    commentId,
    userId,
    createdAt,
  ];
}
