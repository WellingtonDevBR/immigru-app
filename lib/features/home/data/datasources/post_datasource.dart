import 'dart:io';
import 'package:immigru/core/network/edge_function_client.dart';
import 'package:immigru/features/home/domain/entities/post_media.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Data source for post-related operations
class PostDataSource {
  final EdgeFunctionClient _edgeFunctionClient;
  final SupabaseClient _supabaseClient;

  /// Constructor
  PostDataSource({
    required EdgeFunctionClient edgeFunctionClient,
    required SupabaseClient supabaseClient,
  })  : _edgeFunctionClient = edgeFunctionClient,
        _supabaseClient = supabaseClient;

  /// Create a new post using the Supabase edge function
  Future<Map<String, dynamic>> createPost({
    required String userId,
    required String content,
    required String type,
    List<PostMedia>? media,
  }) async {
    // Prepare media items for the API
    List<Map<String, dynamic>>? mediaItems;
    
    if (media != null && media.isNotEmpty) {
      mediaItems = media.map((item) => {
        'id': item.id,
        'path': item.path,
        'name': item.name,
        'type': item.type.toString().split('.').last,
        'createdAt': item.createdAt.toIso8601String(),
      }).toList();
    }

    // Prepare the request payload
    final payload = {
      'userId': userId,
      'content': content,
      'type': type,
      'metadata': {
        'mediaItems': mediaItems,
      },
    };

    // Call the edge function
    final response = await _edgeFunctionClient.invoke('create-post', body: payload);

    // Check if response data is null
    if (response.data == null) {
      throw Exception('Edge function returned null response');
    }
    
    // Convert the response to a Map
    return response.data as Map<String, dynamic>;
  }

  /// Upload media for a post and get the public URL
  Future<String> uploadPostMedia(String filePath, String fileName) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = 'posts/$timestamp-$fileName';

      // Create a File object from the file path
      final file = File(filePath);

      // Upload the file to Supabase storage
      await _supabaseClient.storage
          .from('media')
          .upload(storagePath, file);

      // Get the public URL for the uploaded file
      final publicUrl = _supabaseClient.storage
          .from('media')
          .getPublicUrl(storagePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload media: $e');
    }
  }
}
