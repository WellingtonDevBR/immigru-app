import 'package:equatable/equatable.dart';
import 'package:immigru/features/home/domain/entities/author.dart';

/// Entity representing a post in the home feed
class Post extends Equatable {
  final String id;
  final String userId;
  final String? userName;
  final String? userAvatar;
  final String content;
  final String? imageUrl;
  final String category;
  final DateTime createdAt;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final String? location;
  final Author? author;
  final DateTime? updatedAt;
  
  /// Whether the current user has commented on this post
  final bool hasUserComment;

  const Post({
    required this.id,
    required this.userId,
    this.userName,
    this.userAvatar,
    required this.content,
    this.imageUrl,
    this.updatedAt,
    required this.category,
    required this.createdAt,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.location,
    this.author,
    this.hasUserComment = false,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        userAvatar,
        content,
        imageUrl,
        category,
        createdAt,
        likeCount,
        commentCount,
        isLiked,
        location,
        author,
        hasUserComment,
      ];

  /// Convert Post to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'content': content,
      'imageUrl': imageUrl,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'likeCount': likeCount,
      'commentCount': commentCount,
      'isLiked': isLiked,
      'location': location,
      'author': author?.toJson(),
      'hasUserComment': hasUserComment,
    };
  }

  /// Create a Post from a JSON map
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String?,
      userAvatar: json['userAvatar'] as String?,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      category: json['category'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      likeCount: json['likeCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      location: json['location'] as String?,
      author: json['author'] != null ? Author.fromJson(json['author']) : null,
      hasUserComment: json['hasUserComment'] as bool? ?? false,
    );
  }

  /// String representation for debugging
  @override
  String toString() {
    return 'Post{id: $id, content: $content, userId: $userId, createdAt: $createdAt}';
  }

  /// Creates a copy of this post with the given fields replaced with the new values
  Post copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? content,
    String? imageUrl,
    String? category,
    DateTime? createdAt,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
    String? location,
    Author? author,
    bool? hasUserComment,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      location: location ?? this.location,
      author: author ?? this.author,
      hasUserComment: hasUserComment ?? this.hasUserComment,
    );
  }
}
