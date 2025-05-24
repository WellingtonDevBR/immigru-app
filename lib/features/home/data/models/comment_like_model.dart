import 'package:immigru/features/home/domain/entities/comment_like.dart';

/// Model class for CommentLike entity
class CommentLikeModel extends CommentLike {
  const CommentLikeModel({
    required super.id,
    required super.commentId,
    required super.userId,
    required super.createdAt,
  });

  /// Create a CommentLikeModel from JSON
  factory CommentLikeModel.fromJson(Map<String, dynamic> json) {
    return CommentLikeModel(
      id: json['Id']?.toString() ?? '',
      commentId: json['CommentId']?.toString() ?? '',
      userId: json['UserId']?.toString() ?? '',
      createdAt: json['CreatedAt'] != null
          ? DateTime.parse(json['CreatedAt'].toString())
          : DateTime.now(),
    );
  }

  /// Convert CommentLikeModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'CommentId': commentId,
      'UserId': userId,
      'CreatedAt': createdAt.toIso8601String(),
    };
  }
}
