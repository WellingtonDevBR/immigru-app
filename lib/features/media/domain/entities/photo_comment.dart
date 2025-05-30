import 'package:equatable/equatable.dart';

/// Domain entity representing a comment on a photo
class PhotoComment extends Equatable {
  /// Unique identifier for the comment
  final String id;
  
  /// ID of the photo this comment belongs to
  final String photoId;
  
  /// ID of the user who made this comment
  final String userId;
  
  /// Display name of the user who made this comment
  final String userName;
  
  /// URL to the user's avatar
  final String? userAvatar;
  
  /// The comment text
  final String text;
  
  /// When the comment was created
  final DateTime createdAt;
  
  /// When the comment was last updated
  final DateTime updatedAt;

  /// Constructor
  const PhotoComment({
    required this.id,
    required this.photoId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    photoId,
    userId,
    userName,
    userAvatar,
    text,
    createdAt,
    updatedAt,
  ];
  
  /// Create a copy of this comment with modified properties
  PhotoComment copyWith({
    String? id,
    String? photoId,
    String? userId,
    String? userName,
    String? Function()? userAvatar,
    String? text,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PhotoComment(
      id: id ?? this.id,
      photoId: photoId ?? this.photoId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar != null ? userAvatar() : this.userAvatar,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
