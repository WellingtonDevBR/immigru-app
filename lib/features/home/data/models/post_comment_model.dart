import 'package:immigru/features/home/domain/entities/post_comment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Model class for PostComment entity
class PostCommentModel extends PostComment {
  const PostCommentModel({
    required super.id,
    required super.postId,
    required super.userId,
    super.parentCommentId,
    super.rootCommentId,
    super.depth = 1,
    required super.content,
    required super.createdAt,
    super.userName,
    super.userAvatar,
    super.replies = const [],
    super.isCurrentUserComment = false,
  });

  /// Create a PostCommentModel from JSON
  factory PostCommentModel.fromJson(Map<String, dynamic> json) {
    // Get the current user ID from Supabase if available
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    // Use the depth from the database if available, otherwise calculate it
    int calculatedDepth = json['Depth'] ?? 1;
    
    // If depth is not in the database but we have a parent, it's at least level 2
    if (json['Depth'] == null && json['ParentCommentId'] != null) {
      calculatedDepth = 2; // Default for replies to top-level comments
    }

    // Use rootCommentId from the database if available, otherwise derive it
    String? derivedRootCommentId = json['RootCommentId']?.toString();
    
    // If rootCommentId is not in the database but we have a parent, the parent might be the root
    if (derivedRootCommentId == null && json['ParentCommentId'] != null) {
      derivedRootCommentId = json['ParentCommentId']?.toString();
    }

    return PostCommentModel(
      id: json['Id']?.toString() ?? '',
      postId: json['PostId']?.toString() ?? '',
      userId: json['UserId']?.toString() ?? '',
      parentCommentId: json['ParentCommentId']?.toString(),
      rootCommentId: derivedRootCommentId,
      depth: calculatedDepth,
      content: json['Content']?.toString() ?? '',
      createdAt: json['CreatedAt'] != null
          ? DateTime.parse(json['CreatedAt'].toString())
          : DateTime.now(),
      userName: json['user_name']?.toString(),
      userAvatar: json['user_avatar']?.toString(),
      isCurrentUserComment:
          currentUserId != null && json['UserId']?.toString() == currentUserId,
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
    // Only include fields that exist in the database schema
    final Map<String, dynamic> json = {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'parent_comment_id': parentCommentId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'user_name': userName,
      'user_avatar': userAvatar,
    };
    
    // Include client-side only fields for UI purposes
    // These won't be sent to the database but are used in the app
    json['is_current_user_comment'] = isCurrentUserComment;
    json['replies'] = replies.map((reply) => (reply as PostCommentModel).toJson()).toList();
    
    // Include these fields for in-memory tracking but they won't be sent to the database
    // since they don't exist in the schema yet
    json['_root_comment_id'] = rootCommentId; // Prefixed with _ to indicate client-side only
    json['_depth'] = depth; // Prefixed with _ to indicate client-side only
    
    return json;
  }

  /// Create a list of PostCommentModels from a list of JSON objects
  static List<PostCommentModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => PostCommentModel.fromJson(json)).toList();
  }
}
