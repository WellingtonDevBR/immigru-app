import 'package:equatable/equatable.dart';

/// Entity class for a comment on a post
class PostComment extends Equatable {
  /// Unique identifier for the comment
  final String id;
  
  /// ID of the post this comment belongs to
  final String postId;
  
  /// ID of the user who created the comment
  final String userId;
  
  /// ID of the parent comment (if this is a reply)
  final String? parentCommentId;
  
  /// Content of the comment
  final String content;
  
  /// When the comment was created
  final DateTime createdAt;
  
  /// Name of the user who created the comment
  final String? userName;
  
  /// Avatar URL of the user who created the comment
  final String? userAvatar;
  
  /// Replies to this comment
  final List<PostComment> replies;

  /// Create a new PostComment
  const PostComment({
    required this.id,
    required this.postId,
    required this.userId,
    this.parentCommentId,
    required this.content,
    required this.createdAt,
    this.userName,
    this.userAvatar,
    this.replies = const [],
  });

  @override
  List<Object?> get props => [
        id,
        postId,
        userId,
        parentCommentId,
        content,
        createdAt,
        userName,
        userAvatar,
        replies,
      ];
}
