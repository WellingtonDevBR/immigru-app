import 'package:immigru/features/home/domain/entities/post.dart';
import 'package:immigru/features/home/data/models/author_model.dart';
import 'package:immigru/features/home/data/models/post_media_model.dart';

/// Model class for Post entity
class PostModel extends Post {
  const PostModel({
    required super.id,
    required super.userId,
    super.userName,
    super.userAvatar,
    required super.content,
    super.imageUrl,
    super.media,
    required super.category,
    required super.createdAt,
    super.likeCount = 0,
    super.commentCount = 0,
    super.isLiked = false,
    super.location,
    super.author,
  });

  /// Create a PostModel from JSON
  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Create author if user data is available
    AuthorModel? authorModel;
    if (json['user_id'] != null) {
      authorModel = AuthorModel(
        id: json['user_id']?.toString() ?? '',
        displayName: json['user_name']?.toString(),
        avatarUrl: json['user_avatar']?.toString(),
      );
    }

    // Process media attachments if available
    List<PostMediaModel>? mediaItems;
    if (json['Media'] != null && json['Media'] is List && (json['Media'] as List).isNotEmpty) {
      mediaItems = (json['Media'] as List).map((mediaItem) {
        return PostMediaModel.fromJson(mediaItem as Map<String, dynamic>);
      }).toList();
    }

    return PostModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      userName: json['user_name']?.toString(),
      userAvatar: json['user_avatar']?.toString(),
      content: json['content']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      media: mediaItems,
      category: json['category']?.toString() ?? 'General',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      likeCount: json['like_count'] != null
          ? int.tryParse(json['like_count'].toString()) ?? 0
          : 0,
      commentCount: json['comment_count'] != null
          ? int.tryParse(json['comment_count'].toString()) ?? 0
          : 0,
      isLiked: json['is_liked'] != null ? json['is_liked'] as bool : false,
      location: json['location']?.toString(),
      author: authorModel,
    );
  }

  /// Convert PostModel to JSON
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'content': content,
      'image_url': imageUrl,
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'like_count': likeCount,
      'comment_count': commentCount,
      'is_liked': isLiked,
      'location': location,
    };

    // Author data is already included in the model
    // We don't need to add it separately to the JSON output
    // as it would duplicate information already present

    return data;
  }

  /// Create a list of PostModels from a list of JSON objects
  static List<PostModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => PostModel.fromJson(json)).toList();
  }
}
