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
      userName: json['DisplayName']?.toString() ?? json['user_name']?.toString(),
      userAvatar: json['AvatarUrl']?.toString() ?? json['user_avatar']?.toString(),
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

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'PostId': postId,
      'UserId': userId,
      'ParentCommentId': parentCommentId,
      'RootCommentId': rootCommentId,
      'Depth': depth,
      'Content': content,
      'CreatedAt': createdAt.toIso8601String(),
      'DisplayName': userName,
      'AvatarUrl': userAvatar,
      'replies': replies.map((reply) => 
          reply is PostCommentModel ? reply.toJson() : null).toList(),
    };
  }

  /// Create a copy of this PostCommentModel with the given fields replaced
  PostCommentModel copyWith({
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
  }) {
    return PostCommentModel(
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
    );
  }
}
