import 'package:equatable/equatable.dart';
import 'package:immigru/features/media/domain/entities/photo_album.dart';
import 'package:immigru/features/media/domain/entities/photo_comment.dart';
import 'package:immigru/features/media/domain/entities/photo_like.dart';

/// Domain entity representing a photo
class Photo extends Equatable {
  /// Unique identifier for the photo
  final String id;
  
  /// ID of the album this photo belongs to
  final String albumId;
  
  /// ID of the user who owns this photo
  final String userId;
  
  /// Storage path where the photo is stored
  final String storagePath;
  
  /// URL to access the photo
  final String url;
  
  /// URL to access the thumbnail version of the photo
  final String? thumbnailUrl;
  
  /// Optional title for the photo
  final String? title;
  
  /// Optional description for the photo
  final String? description;
  
  /// Width of the photo in pixels
  final int? width;
  
  /// Height of the photo in pixels
  final int? height;
  
  /// Size of the photo in bytes
  final int? size;
  
  /// Format of the photo (e.g., 'jpg', 'png')
  final String? format;
  
  /// Visibility setting for this photo
  final AlbumVisibility visibility;
  
  /// When the photo was last updated
  final DateTime updatedAt;
  
  /// When the photo was created
  final DateTime createdAt;
  
  /// Comments on this photo
  final List<PhotoComment>? comments;
  
  /// Likes on this photo
  final List<PhotoLike>? likes;
  
  /// Number of likes on this photo
  final int likeCount;
  
  /// Number of comments on this photo
  final int commentCount;

  /// Constructor
  const Photo({
    required this.id,
    required this.albumId,
    required this.userId,
    required this.storagePath,
    required this.url,
    this.thumbnailUrl,
    this.title,
    this.description,
    this.width,
    this.height,
    this.size,
    this.format,
    this.visibility = AlbumVisibility.private,
    required this.updatedAt,
    required this.createdAt,
    this.comments,
    this.likes,
    this.likeCount = 0,
    this.commentCount = 0,
  });

  @override
  List<Object?> get props => [
        id,
        albumId,
        userId,
        storagePath,
        url,
        thumbnailUrl,
        title,
        description,
        width,
        height,
        size,
        format,
        visibility,
        updatedAt,
        createdAt,
      ];
      
  /// Create a copy of this photo with modified properties
  Photo copyWith({
    String? id,
    String? albumId,
    String? userId,
    String? storagePath,
    String? url,
    String? Function()? thumbnailUrl,
    String? Function()? title,
    String? Function()? description,
    int? Function()? width,
    int? Function()? height,
    int? Function()? size,
    String? Function()? format,
    AlbumVisibility? visibility,
    DateTime? updatedAt,
    DateTime? createdAt,
    List<PhotoComment>? Function()? comments,
    List<PhotoLike>? Function()? likes,
    int? likeCount,
    int? commentCount,
  }) {
    return Photo(
      id: id ?? this.id,
      albumId: albumId ?? this.albumId,
      userId: userId ?? this.userId,
      storagePath: storagePath ?? this.storagePath,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl != null ? thumbnailUrl() : this.thumbnailUrl,
      title: title != null ? title() : this.title,
      description: description != null ? description() : this.description,
      width: width != null ? width() : this.width,
      height: height != null ? height() : this.height,
      size: size != null ? size() : this.size,
      format: format != null ? format() : this.format,
      visibility: visibility ?? this.visibility,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      comments: comments != null ? comments() : this.comments,
      likes: likes != null ? likes() : this.likes,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
    );
  }
}
