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

  const Post({
    required this.id,
    required this.userId,
    this.userName,
    this.userAvatar,
    required this.content,
    this.imageUrl,
    required this.category,
    required this.createdAt,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.location,
    this.author,
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
      ];

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
    );
  }
}
