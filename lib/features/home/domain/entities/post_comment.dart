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

  /// ID of the root comment in the thread (for nested replies)
  final String? rootCommentId;

  /// Depth level of the comment (1 = direct post comment, 2 = reply to comment, 3 = reply to reply)
  final int depth;

  /// Content of the comment
  final String content;

  /// When the comment was created
  final DateTime createdAt;

  /// Name of the user who created the comment
  final String? userName;

  /// Number of likes this comment has received
  final int likeCount;

  /// Whether the current user has liked this comment
  final bool isLikedByCurrentUser;

  /// Avatar URL of the user who created the comment
  final String? userAvatar;

  /// Replies to this comment
  final List<PostComment> replies;

  /// Whether this comment belongs to the current user
  final bool isCurrentUserComment;

  /// Create a new PostComment
  const PostComment({
    required this.id,
    required this.postId,
    required this.userId,
    this.parentCommentId,
    this.rootCommentId,
    this.depth = 1, // Default to direct post comment
    required this.content,
    required this.createdAt,
    this.userName,
    this.userAvatar,
    this.replies = const [],
    this.isCurrentUserComment = false,
    this.likeCount = 0,
    this.isLikedByCurrentUser = false,
  });

  @override
  List<Object?> get props => [
        id,
        postId,
        userId,
        parentCommentId,
        rootCommentId,
        depth,
        content,
        createdAt,
        userName,
        userAvatar,
        replies,
        isCurrentUserComment,
        likeCount,
        isLikedByCurrentUser,
      ];

  /// Create a copy of this PostComment with the given fields replaced with new values
  PostComment copyWith({
    String? id,
    String? postId,
    String? userId,
    String? parentCommentId,
    String? rootCommentId,
    int? depth,
    String? content,
    DateTime? createdAt,
    String? userName,
    String? userAvatar,
    List<PostComment>? replies,
    bool? isCurrentUserComment,
    int? likeCount,
    bool? isLikedByCurrentUser,
  }) {
    return PostComment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      rootCommentId: rootCommentId ?? this.rootCommentId,
      depth: depth ?? this.depth,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      replies: replies ?? this.replies,
      isCurrentUserComment: isCurrentUserComment ?? this.isCurrentUserComment,
      likeCount: likeCount ?? this.likeCount,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
    );
  }
}
