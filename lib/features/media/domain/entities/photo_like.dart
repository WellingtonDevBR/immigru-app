import 'package:equatable/equatable.dart';

/// Domain entity representing a like on a photo
class PhotoLike extends Equatable {
  /// Unique identifier for the like
  final String id;
  
  /// ID of the photo this like belongs to
  final String photoId;
  
  /// ID of the user who made this like
  final String userId;
  
  /// Display name of the user who made this like
  final String userName;
  
  /// URL to the user's avatar
  final String? userAvatar;
  
  /// When the like was created
  final DateTime createdAt;

  /// Constructor
  const PhotoLike({
    required this.id,
    required this.photoId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    photoId,
    userId,
    userName,
    userAvatar,
    createdAt,
  ];
}
