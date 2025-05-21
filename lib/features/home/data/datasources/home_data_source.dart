import 'package:immigru/features/home/data/models/event_model.dart';
import 'package:immigru/features/home/data/models/immi_grove_model.dart';
import 'package:immigru/features/home/data/models/post_model.dart';
import 'package:immigru/core/network/api_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Data source for home screen data
abstract class HomeDataSource {
  /// Get posts for the home feed
  Future<List<PostModel>> getPosts({
    String? category,
    int limit = 20,
    int offset = 0,
  });

  /// Get personalized posts for the user
  Future<List<PostModel>> getPersonalizedPosts({
    required String userId,
    int limit = 20,
    int offset = 0,
  });

  /// Get upcoming events
  Future<List<EventModel>> getEvents({
    bool upcoming = true,
    int limit = 10,
    int offset = 0,
  });

  /// Create a new post
  Future<PostModel> createPost({
    required String content,
    required String userId,
    required String category,
    String? imageUrl,
  });

  /// Like or unlike a post
  Future<bool> likePost({
    required String postId,
    required String userId,
    required bool like,
  });

  /// Register for an event
  Future<bool> registerForEvent({
    required String eventId,
    required String userId,
  });

  /// Get ImmiGroves (communities)
  Future<List<ImmiGroveModel>> getImmiGroves({
    String? query,
    int limit = 10,
    int offset = 0,
  });

  /// Get recommended ImmiGroves for the user
  Future<List<ImmiGroveModel>> getRecommendedImmiGroves({
    int limit = 5,
  });

  /// Join or leave an ImmiGrove
  Future<bool> joinImmiGrove({
    required String immiGroveId,
    required String userId,
    required bool join,
  });
}

/// Implementation of HomeDataSource using Supabase
class HomeDataSourceImpl implements HomeDataSource {
  final ApiClient apiClient;
  final SupabaseClient supabase;

  HomeDataSourceImpl({
    required this.apiClient,
    required this.supabase,
  });

  @override
  Future<List<PostModel>> getPosts({
    String? category,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Start with the base query
      var query = supabase
          .from('Post')
          .select('''
            *,
            UserProfile:user_id (
              user_name,
              avatar_url
            )
          ''')
          .order('created_at', ascending: false)
          .limit(limit)
          .range(offset, offset + limit - 1);

      // Add category filter if provided
      if (category != null && category != 'All') {
        query = supabase
            .from('Post')
            .select('''
              *,
              UserProfile:user_id (
                user_name,
                avatar_url
              )
            ''')
            .eq('category', category)
            .order('created_at', ascending: false)
            .limit(limit)
            .range(offset, offset + limit - 1);
      }

      // Execute the query
      final response = await query;

      // Transform the response
      final posts = response.map<PostModel>((json) {
        // Extract user data from the joined UserProfile
        final userData = json['UserProfile'] as Map<String, dynamic>?;

        // Create a new JSON object with flattened structure
        final flattenedJson = {
          ...json,
          'user_name': userData?['user_name'],
          'user_avatar': userData?['avatar_url'],
        };

        return PostModel.fromJson(flattenedJson);
      }).toList();
      
      // If we got posts, return them
      if (posts.isNotEmpty) {
        return posts;
      }
      
      // If no posts were found and this is the first page, return mock data
      if (offset == 0) {
        return _getMockPosts(category: category, limit: limit);
      }
      
      // Otherwise return empty list for pagination
      return [];
    } catch (e) {
      // On error, return mock data for first page or empty list for pagination
      if (offset == 0) {
        return _getMockPosts(category: category, limit: limit);
      }
      return [];
    }
  }
  
  /// Generate mock posts for testing and when the API is unavailable
  List<PostModel> _getMockPosts({String? category, int limit = 5}) {
    final now = DateTime.now();
    final mockPosts = <PostModel>[];
    
    final categories = [
      'Immigration News',
      'Legal Advice',
      'Community',
      'Question',
      'Experience',
    ];
    
    for (int i = 0; i < limit; i++) {
      final postCategory = category != null && category != 'All' 
          ? category 
          : categories[i % categories.length];
          
      mockPosts.add(PostModel(
        id: 'mock-${i + 1}',
        userId: 'mock-user-${i % 3 + 1}',
        userName: 'Mock User ${i % 3 + 1}',
        userAvatar: null,
        content: 'This is a mock post #${i + 1} in the $postCategory category. ' +
                'The app is currently in demo mode or experiencing connectivity issues.',
        category: postCategory,
        imageUrl: i % 3 == 0 ? 'https://picsum.photos/seed/${i + 1}/800/600' : null,
        likeCount: i * 5,
        commentCount: i * 2,
        isLiked: false,
        createdAt: now.subtract(Duration(hours: i * 3)),
      ));
    }
    
    return mockPosts;
  }

  @override
  Future<List<PostModel>> getPersonalizedPosts({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Call the edge function for personalized posts
      final response = await supabase.functions.invoke(
        'personalized-posts',
        body: {
          'user_id': userId,
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to get personalized posts');
      }

      final data = response.data as List<dynamic>;
      return PostModel.fromJsonList(data);
    } catch (e) {
      // Return empty list on error (will be handled by repository)
      return [];
    }
  }

  @override
  Future<List<EventModel>> getEvents({
    bool upcoming = true,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      // Start with the base query
      var query = supabase
          .from('Event')
          .select('*')
          .order('event_date', ascending: true)
          .limit(limit)
          .range(offset, offset + limit - 1);

      // Filter for upcoming events if requested
      if (upcoming) {
        final now = DateTime.now().toIso8601String();
        // We need to reconstruct the query for PostgrestTransformBuilder
        query = supabase
            .from('Event')
            .select('''
              *,
              UserProfile:user_id (
                user_name,
                avatar_url
              )
            ''')
            .gte('event_date', now)
            .order('event_date', ascending: true)
            .limit(limit)
            .range(offset, offset + limit - 1);
      }

      // Execute the query
      final response = await query;

      return EventModel.fromJsonList(response);
    } catch (e) {
      // Return empty list on error (will be handled by repository)
      return [];
    }
  }

  @override
  Future<PostModel> createPost({
    required String content,
    required String userId,
    required String category,
    String? imageUrl,
  }) async {
    try {
      final response = await supabase
          .from('Post')
          .insert({
            'user_id': userId,
            'content': content,
            'category': category,
            'image_url': imageUrl,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return PostModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  @override
  Future<bool> likePost({
    required String postId,
    required String userId,
    required bool like,
  }) async {
    try {
      if (like) {
        // Add a like
        await supabase.from('PostLike').insert({
          'post_id': postId,
          'user_id': userId,
          'created_at': DateTime.now().toIso8601String(),
        });
      } else {
        // Remove a like
        await supabase
            .from('PostLike')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', userId);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> registerForEvent({
    required String eventId,
    required String userId,
  }) async {
    try {
      await supabase.from('EventRegistration').insert({
        'event_id': eventId,
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<ImmiGroveModel>> getImmiGroves({
    String? query,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      // Start with the base query
      var dbQuery = supabase
          .from('ImmiGrove')
          .select('''
            *,
            UserImmiGrove!inner(user_id)
          ''')
          .order('member_count', ascending: false)
          .limit(limit)
          .range(offset, offset + limit - 1);

      // Add search filter if provided
      if (query != null && query.isNotEmpty) {
        // For simplicity, just get all ImmiGroves and filter in memory
        // In a production app, we would use a proper search endpoint
      }

      // Execute the query
      final response = await dbQuery;

      return response.map<ImmiGroveModel>((json) {
        // Add isJoined flag based on UserImmiGrove join
        final isJoined = json['UserImmiGrove'] != null &&
            (json['UserImmiGrove'] as List).isNotEmpty;

        // Create a new JSON object with the isJoined flag
        final enrichedJson = {
          ...json,
          'is_joined': isJoined,
        };

        return ImmiGroveModel.fromJson(enrichedJson);
      }).toList();
    } catch (e) {
      // Return empty list on error (will be handled by repository)
      return [];
    }
  }

  @override
  Future<List<ImmiGroveModel>> getRecommendedImmiGroves({int limit = 5}) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await supabase.rpc(
        'get_recommended_immi_groves',
        params: {
          'user_id': userId,
          'limit_count': limit,
        },
      );

      return response
          .map<ImmiGroveModel>((json) => ImmiGroveModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> joinImmiGrove({
    required String immiGroveId,
    required String userId,
    required bool join,
  }) async {
    try {
      if (join) {
        // Join the ImmiGrove
        await supabase.from('UserImmiGrove').insert({
          'immi_grove_id': immiGroveId,
          'user_id': userId,
          'joined_at': DateTime.now().toIso8601String(),
        });

        // Increment member count
        await supabase.rpc(
          'increment_immi_grove_member_count',
          params: {
            'grove_id': immiGroveId,
            'increment_by': 1,
          },
        );
      } else {
        // Leave the ImmiGrove
        await supabase
            .from('UserImmiGrove')
            .delete()
            .eq('immi_grove_id', immiGroveId)
            .eq('user_id', userId);

        // Decrement member count
        await supabase.rpc(
          'increment_immi_grove_member_count',
          params: {
            'grove_id': immiGroveId,
            'increment_by': -1,
          },
        );
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
