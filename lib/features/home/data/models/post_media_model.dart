import 'package:immigru/features/home/domain/entities/post_media.dart';

/// Data model for post media that implements the domain entity
class PostMediaModel extends PostMedia {
  /// Constructor
  const PostMediaModel({
    required super.id,
    required super.path,
    required super.name,
    required super.type,
    required super.createdAt,
  });

  /// Create a model from a map (for deserialization)
  factory PostMediaModel.fromJson(Map<String, dynamic> json) {
    return PostMediaModel(
      id: json['id'] as String,
      path: json['path'] as String,
      name: json['name'] as String,
      type: json['type'] == 'image' ? MediaType.image : MediaType.video,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convert model to a map (for serialization)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path': path,
      'name': name,
      'type': type == MediaType.image ? 'image' : 'video',
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create a model from a file path
  factory PostMediaModel.fromPath(String path) {
    final name = path.split('/').last;
    final isVideo = path.endsWith('.mp4') || 
                    path.endsWith('.mov') || 
                    path.endsWith('.avi');
    
    return PostMediaModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      path: path,
      name: name,
      type: isVideo ? MediaType.video : MediaType.image,
      createdAt: DateTime.now(),
    );
  }
}
