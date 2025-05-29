import 'dart:convert';
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
    // Extract the media URL, handling different field names
    String mediaUrl = '';
    if (json['MediaUrl'] != null) {
      mediaUrl = json['MediaUrl'] as String;
    } else if (json['Path'] != null) {
      mediaUrl = json['Path'] as String;
    } else if (json['URL'] != null) {
      mediaUrl = json['URL'] as String;
    } else if (json['path'] != null) {
      mediaUrl = json['path'] as String;
    }
    
    // Handle case where the URL might be a JSON string
    if (mediaUrl.startsWith('[{') && mediaUrl.endsWith('}]')) {
      try {
        final List<dynamic> mediaList = jsonDecode(mediaUrl) as List<dynamic>;
        if (mediaList.isNotEmpty && mediaList[0] is Map<String, dynamic>) {
          final Map<String, dynamic> mediaItem = mediaList[0] as Map<String, dynamic>;
          if (mediaItem.containsKey('path')) {
            mediaUrl = mediaItem['path'] as String;
          }
        }
      } catch (e) {
        // If JSON parsing fails, keep the original URL
      }
    }
    
    // Ensure the URL is properly formatted for Supabase storage
    if (mediaUrl.isNotEmpty && !mediaUrl.startsWith('http')) {
      // If it's a Supabase storage path without the full URL
      if (mediaUrl.contains('supabase.co/storage/v1/object/public')) {
        mediaUrl = 'https://$mediaUrl';
      } else if (!mediaUrl.contains('://')) {
        // If it's just a path, assume it's in the post-media bucket
        mediaUrl = 'https://kkdhnvapcbwwqapsnnfg.supabase.co/storage/v1/object/public/post-media/$mediaUrl';
      }
    }
    
    // Extract media type, defaulting to image
    final String mediaType = json['MediaType'] as String? ?? 
                            json['Type'] as String? ?? 
                            json['type'] as String? ?? 'image';
    
    // Extract filename from path
    final String name = mediaUrl.split('/').last;
    
    return PostMediaModel(
      id: json['Id'] as String? ?? json['id'] as String? ?? '',
      path: mediaUrl,
      name: name,
      type: mediaType.toLowerCase() == 'image' ? MediaType.image : MediaType.video,
      createdAt: json['CreatedAt'] != null
          ? DateTime.parse(json['CreatedAt'] as String)
          : (json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now()),
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

  /// Create a model from a file path with strict validation for proper image types
  /// 
  /// Throws an exception if the file type is not a valid image or video type
  factory PostMediaModel.fromPath(String path) {
    final name = path.split('/').last;
    final extension = name.split('.').last.toLowerCase();
    
    // Validate file extension for proper image types
    final validImageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic'];
    final validVideoExtensions = ['mp4', 'mov', 'avi'];
    
    // Determine media type based on extension
    final isVideo = validVideoExtensions.contains(extension);
    final isValidImage = validImageExtensions.contains(extension);
    
    // If it's neither a valid image nor video, throw an exception
    if (!isVideo && !isValidImage) {
      throw Exception('Invalid file type: .$extension. Please use a supported image (${validImageExtensions.join(', ')}) or video (${validVideoExtensions.join(', ')}) format.');
    }
    
    // Create a proper media model with the validated file
    return PostMediaModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      path: path,
      name: name,
      type: isVideo ? MediaType.video : MediaType.image,
      createdAt: DateTime.now(),
    );
  }
  
  /// Checks if a file path has a valid media extension
  static bool hasValidExtension(String path) {
    final name = path.split('/').last;
    final extension = name.split('.').last.toLowerCase();
    
    // Define valid extensions
    final validExtensions = [
      'jpg', 'jpeg', 'png', 'gif', 'webp', 'heic',  // Images
      'mp4', 'mov', 'avi'                            // Videos
    ];
    
    return validExtensions.contains(extension);
  }
  
  /// Gets the MIME type for a file path
  static String getMimeType(String path) {
    final name = path.split('/').last;
    final extension = name.split('.').last.toLowerCase();
    
    // Map extensions to MIME types
    final mimeTypes = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'webp': 'image/webp',
      'heic': 'image/heic',
      'mp4': 'video/mp4',
      'mov': 'video/quicktime',
      'avi': 'video/x-msvideo',
    };
    
    return mimeTypes[extension] ?? 'application/octet-stream';
  }
}
