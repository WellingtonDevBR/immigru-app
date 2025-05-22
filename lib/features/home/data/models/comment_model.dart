import 'package:immigru/features/home/domain/entities/post_comment.dart';

/// Model class for PostComment entity
class PostCommentModel extends PostComment {
  const PostCommentModel({
    required super.id,
    required super.postId,
    required super.userId,
    super.parentCommentId,
    required super.content,
    required super.createdAt,
    super.userName,
    super.userAvatar,
    super.replies = const [],
  });

  /// Create a PostCommentModel from JSON
  factory PostCommentModel.fromJson(Map<String, dynamic> json) {
    return PostCommentModel(
      id: json['id']?.toString() ?? '',
      postId: json['post_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      parentCommentId: json['parent_comment_id']?.toString(),
      content: json['content']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      userName: json['user_name']?.toString(),
      userAvatar: json['user_avatar']?.toString(),
      replies: json['replies'] != null
          ? List<PostCommentModel>.from(
              (json['replies'] as List).map(
                (reply) => PostCommentModel.fromJson(reply),
              ),
            )
          : const [],
    );
  }

  /// Convert PostCommentModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'parent_comment_id': parentCommentId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'user_name': userName,
      'user_avatar': userAvatar,
      'replies': replies.map((reply) => (reply as PostCommentModel).toJson()).toList(),
    };
  }

  /// Create a list of PostCommentModels from a list of JSON objects
  static List<PostCommentModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => PostCommentModel.fromJson(json)).toList();
  }
}
