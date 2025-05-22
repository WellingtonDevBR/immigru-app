import 'package:immigru/features/home/data/models/event_model.dart';
import 'package:immigru/features/home/data/models/immi_grove_model.dart';
import 'package:immigru/features/home/data/models/post_model.dart';
import 'package:immigru/features/home/data/models/post_comment_model.dart';
import 'package:immigru/core/network/api_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Data source for home screen data
abstract class HomeDataSource {
  /// Get posts for the home feed
  ///
  /// [filter] - Filter type: 'all', 'user', 'following', 'my-immigroves'
  /// [category] - Optional category filter
  /// [userId] - Optional user ID to filter posts by
  /// [immigroveId] - Optional ImmiGrove ID to filter posts by
  /// [excludeCurrentUser] - Whether to exclude the current user's posts
  /// [currentUserId] - ID of the current user (needed for some filters)
  /// [limit] - Maximum number of posts to return
  /// [offset] - Pagination offset
  Future<List<PostModel>> getPosts({
    String filter = 'all',
    String? category,
    String? userId,
    String? immigroveId,
    bool excludeCurrentUser = false,
    String? currentUserId,
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
  
  /// Get comments for a post
  /// 
  /// [postId] - ID of the post to get comments for
  /// [limit] - Maximum number of comments to return
  /// [offset] - Pagination offset
  Future<List<PostCommentModel>> getComments({
    required String postId,
    int limit = 20,
    int offset = 0,
  });
  
  /// Create a new comment on a post
  /// 
  /// [postId] - ID of the post to comment on
  /// [userId] - ID of the user creating the comment
  /// [content] - Content of the comment
  /// [parentCommentId] - Optional ID of the parent comment (for replies)
  Future<PostCommentModel> createComment({
    required String postId,
    required String userId,
    required String content,
    String? parentCommentId,
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
    String filter = 'all',
    String? category,
    String? userId,
    String? immigroveId,
    bool excludeCurrentUser = false,
    String? currentUserId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // First, get posts with filters applied
      var query = supabase.from('Post').select('*');

      // Apply filters based on parameters
      if (filter == 'user' && userId != null) {
        // Get posts by a specific user
        query = query.eq('UserId', userId);
      }

      // Apply ImmiGrove filter if provided
      if (immigroveId != null) {
        query = query.eq('ImmiGroveId', immigroveId);
      }

      // Exclude current user's posts if requested
      if (excludeCurrentUser && currentUserId != null) {
        query = query.neq('UserId', currentUserId);
      }

      // Apply category filter if provided
      if (category != null && category != 'All') {
        query = query.eq('Type', category);
      }

      // Add ordering, limit and pagination
      final queryWithOrder = query.order('CreatedAt', ascending: false);
      final queryWithLimit = queryWithOrder.limit(limit);
      final finalQuery = queryWithLimit.range(offset, offset + limit - 1);

      // Execute the query with all filters and pagination applied
      final List<dynamic> postsResponse = await finalQuery;

      // Transform the response into PostModel objects
      final List<PostModel> resultPosts = [];

      // If we have posts, get the user profiles for each post
      if (postsResponse.isNotEmpty) {
        // Extract all unique user IDs from the posts
        final Set<String> userIds =
            postsResponse.map((post) => post['UserId'] as String).toSet();

        // Get user profiles for these users
        // Since in_ method isn't available, we'll use OR conditions
        var userProfilesQuery = supabase.from('UserProfile').select('*');

        // Apply filter for user IDs
        if (userIds.isNotEmpty) {
          final userIdsList = userIds.toList();
          // Start with the first ID
          userProfilesQuery = userProfilesQuery.eq('UserId', userIdsList[0]);

          // Add 'or' conditions for the rest of the IDs
          for (int i = 1; i < userIdsList.length; i++) {
            userProfilesQuery =
                userProfilesQuery.or('UserId.eq.${userIdsList[i]}');
          }
        }

        final userProfilesResponse = await userProfilesQuery;

        // Create a map of userId to userProfile for quick lookup
        final Map<String, Map<String, dynamic>> userProfilesMap = {};
        for (final profile in userProfilesResponse) {
          userProfilesMap[profile['UserId']] = profile;
        }

        // Now combine post data with user profile data
        for (final post in postsResponse) {
          final userId = post['UserId'] as String;
          final userProfile = userProfilesMap[userId];

          // Create a flattened JSON object with user data
          final Map<String, dynamic> postData = {
            'id': post['Id'],
            'user_id': post['UserId'],
            'content': post['Content'],
            'category': post['Type'],
            'image_url': post['MediaUrl'],
            'created_at': post['CreatedAt'],
            // Use user profile data if available, otherwise use defaults
            'user_name': userProfile?['DisplayName'] ?? 'User',
            'user_avatar': userProfile?['AvatarUrl'],
          };

          resultPosts.add(PostModel.fromJson(postData));
        }
      }

      return resultPosts;
    } catch (e) {
      throw Exception('Failed to fetch posts: $e');
    }
  }

  // Mock posts have been removed as we're now using the Supabase edge function for all post fetching

  @override
  Future<List<PostModel>> getPersonalizedPosts({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // For personalized posts, we need to get posts from users the current user follows
      // First, query the UserConnection table to get the users that the current user follows
      final followingQuery = await supabase
          .from('UserConnection')
          .select('ReceiverId')
          .eq('SenderId', userId)
          .eq('Status', 'accepted');

      // Extract the list of user IDs the current user is following
      final List<String> followingIds =
          followingQuery.map((item) => item['ReceiverId'] as String).toList();

      // If the user isn't following anyone, return an empty list
      if (followingIds.isEmpty) {
        return [];
      }

      // Now get posts from these users using separate queries
      // First, get the posts from the followed users
      var postsQuery = supabase.from('Post').select('*');

      // Apply filter for users the current user is following
      if (followingIds.length == 1) {
        // If there's only one user, use eq
        postsQuery = postsQuery.eq('UserId', followingIds[0]);
      } else {
        // For multiple users, use OR conditions
        postsQuery = postsQuery.eq('UserId', followingIds[0]);
        for (int i = 1; i < followingIds.length; i++) {
          postsQuery = postsQuery.or('UserId.eq.${followingIds[i]}');
        }
      }

      // Add ordering, limit and pagination
      final queryWithOrder = postsQuery.order('CreatedAt', ascending: false);
      final queryWithLimit = queryWithOrder.limit(limit);
      final finalQuery = queryWithLimit.range(offset, offset + limit - 1);

      // Execute the query
      final List<dynamic> postsResponse = await finalQuery;

      // If no posts found, return empty list
      if (postsResponse.isEmpty) {
        return [];
      }

      // Now get the user profiles for these posts
      // Extract all unique user IDs from the posts
      final Set<String> postUserIds = postsResponse
          .map((post) => post['UserId'] as String)
          .toSet();

      // Get user profiles for these users
      // Since in_ method isn't available, we'll use OR conditions
      var userProfilesQuery = supabase.from('UserProfile').select('*');

      // Apply filter for user IDs
      if (postUserIds.isNotEmpty) {
        final userIdsList = postUserIds.toList();
        // Start with the first ID
        userProfilesQuery = userProfilesQuery.eq('UserId', userIdsList[0]);

        // Add 'or' conditions for the rest of the IDs
        for (int i = 1; i < userIdsList.length; i++) {
          userProfilesQuery = userProfilesQuery.or('UserId.eq.${userIdsList[i]}');
        }
      }

      final userProfilesResponse = await userProfilesQuery;

      // Create a map of userId to userProfile for quick lookup
      final Map<String, Map<String, dynamic>> userProfilesMap = {};
      for (final profile in userProfilesResponse) {
        userProfilesMap[profile['UserId']] = profile;
      }

      // Now combine post data with user profile data
      final List<PostModel> resultPosts = [];
      for (final post in postsResponse) {
        final postUserId = post['UserId'] as String;
        final userProfile = userProfilesMap[postUserId];

        // Create a flattened JSON object with user data
        final Map<String, dynamic> postData = {
          'id': post['Id'],
          'user_id': post['UserId'],
          'content': post['Content'],
          'category': post['Type'],
          'image_url': post['MediaUrl'],
          'created_at': post['CreatedAt'],
          // Use user profile data if available, otherwise use defaults
          'user_name': userProfile?['DisplayName'] ?? 'User',
          'user_avatar': userProfile?['AvatarUrl'],
        };

        resultPosts.add(PostModel.fromJson(postData));
      }

      return resultPosts;
    } catch (e) {
      // Log the error and rethrow for proper error handling upstream
      print('Error fetching personalized posts: $e');
      throw Exception('Failed to fetch personalized posts: $e');
    }
  }

  @override
  Future<List<EventModel>> getEvents({
    bool upcoming = true,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      // Start with the base query using correct PascalCase field names
      var query = supabase.from('Event').select('*');

      // Filter for upcoming events if requested
      if (upcoming) {
        final now = DateTime.now().toIso8601String();
        query = query.gte('EventDate', now);
      }

      // Add ordering, limit and pagination
      final queryWithOrder = query.order('EventDate', ascending: true);
      final queryWithLimit = queryWithOrder.limit(limit);
      final finalQuery = queryWithLimit.range(offset, offset + limit - 1);

      // Execute the query
      final List<dynamic> eventsResponse = await finalQuery;

      // Transform the response into EventModel objects
      final List<EventModel> resultEvents = [];

      // If we have events, get the user profiles for each event organizer
      if (eventsResponse.isNotEmpty) {
        // Extract all unique organizer IDs from the events
        final Set<String> organizerIds = eventsResponse
            .map((event) => event['OrganizerId'] as String)
            .toSet();

        // Get user profiles for these organizers
        // Since in_ method isn't available, we'll use OR conditions
        var userProfilesQuery = supabase.from('UserProfile').select('*');

        // Apply filter for organizer IDs
        if (organizerIds.isNotEmpty) {
          final organizerIdsList = organizerIds.toList();
          // Start with the first ID
          userProfilesQuery =
              userProfilesQuery.eq('UserId', organizerIdsList[0]);

          // Add 'or' conditions for the rest of the IDs
          for (int i = 1; i < organizerIdsList.length; i++) {
            userProfilesQuery =
                userProfilesQuery.or('UserId.eq.${organizerIdsList[i]}');
          }
        }

        final userProfilesResponse = await userProfilesQuery;

        // Create a map of userId to userProfile for quick lookup
        final Map<String, Map<String, dynamic>> userProfilesMap = {};
        for (final profile in userProfilesResponse) {
          userProfilesMap[profile['UserId']] = profile;
        }

        // Now combine event data with user profile data
        for (final event in eventsResponse) {
          final organizerId = event['OrganizerId'] as String;
          final userProfile = userProfilesMap[organizerId];

          // Create a flattened JSON object with user data
          final Map<String, dynamic> eventData = {
            'id': event['Id'],
            'title': event['Title'],
            'description': event['Description'],
            'event_date': event['EventDate'],
            'location': event['Location'],
            'image_url': event['ImageUrl'],
            'organizer_id': event['OrganizerId'],
            // Use user profile data if available, otherwise use defaults
            'organizer_name': userProfile?['DisplayName'] ?? 'Organizer',
            'organizer_avatar': userProfile?['AvatarUrl'],
          };

          resultEvents.add(EventModel.fromJson(eventData));
        }
      }

      return resultEvents;
    } catch (e) {
      print('Error fetching events: $e');
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
      // Get the user profile data for the post author
      final userProfileResponse = await supabase
          .from('UserProfile')
          .select()
          .eq('UserId', userId)
          .single();

      // Insert the post with correct PascalCase field names
      final response = await supabase
          .from('Post')
          .insert({
            'UserId': userId,
            'Content': content,
            'Type': category, // Using Type instead of category based on DB schema
            'MediaUrl': imageUrl, // Using MediaUrl instead of image_url
            // CreatedAt will be automatically set by the database
          })
          .select()
          .single();

      // Combine post data with user profile data for the response
      final Map<String, dynamic> postData = {
        'id': response['Id'],
        'user_id': response['UserId'],
        'content': response['Content'],
        'category': response['Type'],
        'image_url': response['MediaUrl'],
        'created_at': response['CreatedAt'],
        'user_name': userProfileResponse['DisplayName'],
        'user_avatar': userProfileResponse['AvatarUrl'],
      };

      return PostModel.fromJson(postData);
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
        // Add a like using correct PascalCase field names
        await supabase.from('PostLike').insert({
          'PostId': postId,
          'UserId': userId,
          // CreatedAt will be automatically set by the database
        });
      } else {
        // Remove a like using correct PascalCase field names
        await supabase
            .from('PostLike')
            .delete()
            .match({'PostId': postId, 'UserId': userId});
      }
      return true;
    } catch (e) {
      print('Error liking/unliking post: $e');
      // Return false on error
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
          'ImmiGroveId': immiGroveId,
          'UserId': userId,
          'JoinedAt': DateTime.now().toIso8601String(),
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
            .match({'ImmiGroveId': immiGroveId, 'UserId': userId});
        
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
  
  @override
  Future<List<PostCommentModel>> getComments({
    required String postId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Get top-level comments (no parent comment)
      final commentsQuery = await supabase
          .from('PostComment')
          .select()
          .eq('PostId', postId)
          .filter('ParentCommentId', 'is', null)
          .order('CreatedAt', ascending: false)
          .limit(limit)
          .range(offset, offset + limit - 1);
      
      // If no comments found, return empty list
      if (commentsQuery.isEmpty) {
        return [];
      }
      
      // Extract all comment IDs to get their replies
      final List<String> commentIds = commentsQuery
          .map((comment) => comment['Id'] as String)
          .toList();
      
      // Extract all user IDs to get user profiles
      final Set<String> userIds = commentsQuery
          .map((comment) => comment['UserId'] as String)
          .toSet();
      
      // Get replies for these comments
      var repliesQuery = supabase.from('PostComment').select('*');
      
      // Apply filter for parent comment IDs using OR conditions
      if (commentIds.length == 1) {
        // If there's only one comment, use eq
        repliesQuery = repliesQuery.eq('ParentCommentId', commentIds[0]);
      } else if (commentIds.length > 1) {
        // For multiple comments, use OR conditions
        repliesQuery = repliesQuery.eq('ParentCommentId', commentIds[0]);
        for (int i = 1; i < commentIds.length; i++) {
          repliesQuery = repliesQuery.or('ParentCommentId.eq.${commentIds[i]}');
        }
      }
      
      final repliesResponse = await repliesQuery.order('CreatedAt', ascending: true);
      
      // Add reply user IDs to the set of user IDs
      for (final reply in repliesResponse) {
        userIds.add(reply['UserId'] as String);
      }
      
      // Get user profiles for all users
      var userProfilesQuery = supabase.from('UserProfile').select('*');
      
      // Apply filter for user IDs using OR conditions
      if (userIds.isNotEmpty) {
        final userIdsList = userIds.toList();
        // Start with the first ID
        userProfilesQuery = userProfilesQuery.eq('UserId', userIdsList[0]);
        
        // Add 'or' conditions for the rest of the IDs
        for (int i = 1; i < userIdsList.length; i++) {
          userProfilesQuery = userProfilesQuery.or('UserId.eq.${userIdsList[i]}');
        }
      }
      
      final userProfilesResponse = await userProfilesQuery;
      
      // Create a map of userId to userProfile for quick lookup
      final Map<String, Map<String, dynamic>> userProfilesMap = {};
      for (final profile in userProfilesResponse) {
        userProfilesMap[profile['UserId']] = profile;
      }
      
      // Create a map of parentCommentId to replies for quick lookup
      final Map<String, List<PostCommentModel>> repliesMap = {};
      
      // Process replies first
      for (final reply in repliesResponse) {
        final replyUserId = reply['UserId'] as String;
        final userProfile = userProfilesMap[replyUserId];
        final parentId = reply['ParentCommentId'] as String;
        
        // Create a PostCommentModel for the reply
        final replyModel = PostCommentModel(
          id: reply['Id'],
          postId: reply['PostId'],
          userId: replyUserId,
          parentCommentId: parentId,
          content: reply['Content'],
          createdAt: DateTime.parse(reply['CreatedAt']),
          userName: userProfile?['DisplayName'] ?? 'User',
          userAvatar: userProfile?['AvatarUrl'],
        );
        
        // Add the reply to the map
        if (repliesMap.containsKey(parentId)) {
          repliesMap[parentId]!.add(replyModel);
        } else {
          repliesMap[parentId] = [replyModel];
        }
      }
      
      // Now process the top-level comments and add their replies
      final List<PostCommentModel> resultComments = [];
      
      for (final comment in commentsQuery) {
        final commentId = comment['Id'] as String;
        final commentUserId = comment['UserId'] as String;
        final userProfile = userProfilesMap[commentUserId];
        
        // Create a PostCommentModel for the comment with its replies
        final commentModel = PostCommentModel(
          id: commentId,
          postId: comment['PostId'],
          userId: commentUserId,
          content: comment['Content'],
          createdAt: DateTime.parse(comment['CreatedAt']),
          userName: userProfile?['DisplayName'] ?? 'User',
          userAvatar: userProfile?['AvatarUrl'],
          replies: repliesMap[commentId] ?? [],
        );
        
        resultComments.add(commentModel);
      }
      
      return resultComments;
    } catch (e) {
      print('Error fetching comments: $e');
      return [];
    }
  }
  
  @override
  Future<PostCommentModel> createComment({
    required String postId,
    required String userId,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      // Get the user profile data for the comment author
      final userProfileResponse = await supabase
          .from('UserProfile')
          .select()
          .eq('UserId', userId)
          .single();
      
      // Insert the comment with correct PascalCase field names
      final response = await supabase
          .from('PostComment')
          .insert({
            'PostId': postId,
            'UserId': userId,
            'ParentCommentId': parentCommentId,
            'Content': content,
            // CreatedAt and UpdatedAt will be automatically set by the database
          })
          .select()
          .single();
      
      // Create a PostCommentModel from the response
      return PostCommentModel(
        id: response['Id'],
        postId: response['PostId'],
        userId: response['UserId'],
        parentCommentId: response['ParentCommentId'],
        content: response['Content'],
        createdAt: DateTime.parse(response['CreatedAt']),
        userName: userProfileResponse['DisplayName'],
        userAvatar: userProfileResponse['AvatarUrl'],
      );
    } catch (e) {
      print('Error creating comment: $e');
      throw Exception('Failed to create comment: $e');
    }
  }
}
