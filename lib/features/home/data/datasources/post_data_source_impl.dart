import 'package:immigru/features/home/data/models/post_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:immigru/core/network/api_client.dart';
import 'package:immigru/core/error/exceptions.dart';

/// Interface for post data source operations
abstract class PostDataSource {
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

  /// Create a new post
  Future<PostModel> createPost({
    required String content,
    required String userId,
    required String category,
    String? imageUrl,
  });

  /// Edit an existing post
  /// Only the post author can edit their own posts
  Future<PostModel> editPost({
    required String postId,
    required String userId,
    required String content,
    required String category,
  });

  /// Delete a post (soft delete by setting DeletedAt)
  /// Only the post author can delete their own posts
  Future<bool> deletePost({
    required String postId,
    required String userId,
  });

  /// Like or unlike a post
  Future<bool> likePost({
    required String postId,
    required String userId,
    required bool like,
  });
}

/// Implementation of PostDataSource using Supabase
class PostDataSourceImpl implements PostDataSource {
  final SupabaseClient supabase;
  final ApiClient apiClient;

  /// Create a new PostDataSourceImpl
  PostDataSourceImpl({
    required this.supabase,
    required this.apiClient,
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
      // Start with a base query
      var query = supabase.from('Post').select('*').filter('DeletedAt', 'is', null);

      // Get current user ID if needed but not provided
      String? userIdForFiltering = userId;
      String? currentUserIdForFiltering = currentUserId; // This is the parameter passed to the method
      
      // Apply filters based on parameters
      if (filter == 'user' && userIdForFiltering != null) {
        query = query.eq('UserId', userIdForFiltering);
      } else if (filter == 'following' && currentUserIdForFiltering != null) {
        // Get the list of users that the current user is following
        final followingResponse = await supabase
            .from('UserFollowing')
            .select('FollowingUserId')
            .eq('UserId', currentUserIdForFiltering);

        if (followingResponse.isNotEmpty) {
          final followingUserIds = followingResponse
              .map((item) => item['FollowingUserId'] as String)
              .toList();

          // Start with the first user ID
          query = query.eq('UserId', followingUserIds[0]);

          // Add OR conditions for the rest of the user IDs
          for (int i = 1; i < followingUserIds.length; i++) {
            query = query.or('UserId.eq.${followingUserIds[i]}');
          }
        } else {
          // If not following anyone, return empty list
          return [];
        }
      } else if (filter == 'my-immigroves' && currentUserIdForFiltering != null) {
        // Get the list of ImmiGroves that the current user is a member of
        final membershipResponse = await supabase
            .from('ImmiGroveMember')
            .select('ImmiGroveId')
            .eq('UserId', currentUserIdForFiltering);

        if (membershipResponse.isNotEmpty) {
          final immigroveIds = membershipResponse
              .map((item) => item['ImmiGroveId'] as String)
              .toList();

          // Start with the first ImmiGrove ID
          query = query.eq('ImmiGroveId', immigroveIds[0]);

          // Add OR conditions for the rest of the ImmiGrove IDs
          for (int i = 1; i < immigroveIds.length; i++) {
            query = query.or('ImmiGroveId.eq.${immigroveIds[i]}');
          }
        } else {
          // If not a member of any ImmiGroves, return empty list
          return [];
        }
      }

      // Apply category filter if provided
      if (category != null && category.isNotEmpty) {
        query = query.eq('Category', category);
      }

      // Apply ImmiGrove filter if provided
      if (immigroveId != null) {
        query = query.eq('ImmiGroveId', immigroveId);
      }

      // Exclude current user's posts if requested
      if (excludeCurrentUser && currentUserIdForFiltering != null) {
        query = query.neq('UserId', currentUserIdForFiltering);
      }

      // Apply pagination and ordering
      final response = await query
          .order('CreatedAt', ascending: false)
          .limit(limit)
          .range(offset, offset + limit - 1);

      // If no posts found, return empty list
      if (response.isEmpty) {
        return [];
      }

      // Extract all user IDs to get user profiles
      final Set<String> userIds =
          response.map((post) => post['UserId'] as String).toSet();

      // Get user profiles for all users
      var userProfilesQuery = supabase.from('UserProfile').select('*');

      // Apply filter for user IDs using OR conditions
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

      // Get the current user ID for determining if the post is liked by the current user
      final currentUser = supabase.auth.currentUser;
      final String? loggedInUserId = currentUser?.id; // Renamed to avoid conflict with parameter

      // Get like counts and check if the current user has liked each post
      final List<PostModel> posts = [];
      for (final post in response) {
        final postId = post['Id'] as String;
        final userId = post['UserId'] as String;
        final userProfile = userProfilesMap[userId];

        // Get like count for this post
        final response = await supabase
            .from('PostLike')
            .select()
            .eq('PostId', postId);

        final likeCount = response.length;

        // Check if the current user has liked this post
        bool isLikedByCurrentUser = false;
        if (loggedInUserId != null) {
          final likeResponse = await supabase
              .from('PostLike')
              .select()
              .eq('PostId', postId)
              .eq('UserId', loggedInUserId);
          isLikedByCurrentUser = likeResponse.isNotEmpty;
        }

        // Create a PostModel with all the data
        final postModel = PostModel(
          id: postId,
          content: post['Content'],
          category: post['Category'],
          userId: userId,
          imageUrl: post['ImageUrl'],
          createdAt: DateTime.parse(post['CreatedAt']),
          likeCount: likeCount,
          isLiked: isLikedByCurrentUser,
          userName: userProfile?['DisplayName'] ?? 'User',
          userAvatar: userProfile?['AvatarUrl'],
        );

        posts.add(postModel);
      }

      return posts;
    } catch (e) {
      print('Error fetching posts: $e');
      throw ServerException(message: 'Failed to fetch posts: $e');
    }
  }

  @override
  Future<List<PostModel>> getPersonalizedPosts({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Get the user's interests
      final userInterestsResponse = await supabase
          .from('UserInterest')
          .select('Category')
          .eq('UserId', userId);

      // Extract categories from the response
      final List<String> userInterests = userInterestsResponse
          .map((item) => item['Category'] as String)
          .toList();

      // If the user has no interests, return regular posts
      if (userInterests.isEmpty) {
        return getPosts(limit: limit, offset: offset);
      }

      // Get posts matching the user's interests
      var query = supabase.from('Post').select('*').filter('DeletedAt', 'is', null);

      // Start with the first interest
      query = query.eq('Category', userInterests[0]);

      // Add OR conditions for the rest of the interests
      for (int i = 1; i < userInterests.length; i++) {
        query = query.or('Category.eq.${userInterests[i]}');
      }

      // Apply pagination and ordering
      final response = await query
          .order('CreatedAt', ascending: false)
          .limit(limit)
          .range(offset, offset + limit - 1);

      // If no posts found, return regular posts
      if (response.isEmpty) {
        return getPosts(limit: limit, offset: offset);
      }

      // Extract all user IDs to get user profiles
      final Set<String> userIds =
          response.map((post) => post['UserId'] as String).toSet();

      // Get user profiles for all users
      var userProfilesQuery = supabase.from('UserProfile').select('*');

      // Apply filter for user IDs using OR conditions
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

      // Get like counts and check if the current user has liked each post
      final List<PostModel> posts = [];
      for (final post in response) {
        final postId = post['Id'] as String;
        final postUserId = post['UserId'] as String;
        final userProfile = userProfilesMap[postUserId];

        // Get like count for this post
        final response = await supabase
            .from('PostLike')
            .select()
            .eq('PostId', postId);

        final likeCount = response.length;

        // Check if the current user has liked this post
        final likeResponse = await supabase
            .from('PostLike')
            .select()
            .eq('PostId', postId)
            .eq('UserId', userId);
        final isLikedByCurrentUser = likeResponse.isNotEmpty;

        // Create a PostModel with all the data
        final postModel = PostModel(
          id: postId,
          content: post['Content'],
          category: post['Category'],
          userId: postUserId,
          imageUrl: post['ImageUrl'],
          createdAt: DateTime.parse(post['CreatedAt']),
          likeCount: likeCount,
          isLiked: isLikedByCurrentUser,
          userName: userProfile?['DisplayName'] ?? 'User',
          userAvatar: userProfile?['AvatarUrl'],
        );

        posts.add(postModel);
      }

      return posts;
    } catch (e) {
      print('Error fetching personalized posts: $e');
      throw ServerException(message: 'Failed to fetch personalized posts: $e');
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

      // Insert the post
      final postData = {
        'Content': content,
        'UserId': userId,
        'Category': category,
        'ImageUrl': imageUrl,
        // CreatedAt will be automatically set by the database
      };

      final response = await supabase
          .from('Post')
          .insert(postData)
          .select()
          .single();

      // Create a PostModel from the response
      final postModel = PostModel(
        id: response['Id'],
        content: response['Content'],
        category: response['Category'],
        userId: userId,
        imageUrl: response['ImageUrl'],
        createdAt: DateTime.parse(response['CreatedAt']),
        likeCount: 0,
        isLiked: false,
        userName: userProfileResponse['DisplayName'],
        userAvatar: userProfileResponse['AvatarUrl'],
      );

      return postModel;
    } catch (e) {
      print('Error creating post: $e');
      throw Exception('Failed to create post: $e');
    }
  }

  @override
  Future<PostModel> editPost({
    required String postId,
    required String userId,
    required String content,
    required String category,
  }) async {
    try {
      // First verify that the user is the author of the post
      await supabase
          .from('Post')
          .select()
          .eq('Id', postId)
          .eq('UserId', userId) // Ensure the user is the author
          .single();

      // Update the post
      final postData = {
        'Content': content,
        'Category': category,
        'UpdatedAt': DateTime.now().toIso8601String(),
      };

      final response = await supabase
          .from('Post')
          .update(postData)
          .eq('Id', postId)
          .eq('UserId', userId) // Ensure the user is the author
          .select()
          .single();

      // Get the user profile data for the post author
      final userProfileResponse = await supabase
          .from('UserProfile')
          .select()
          .eq('UserId', userId)
          .single();

      // Get like count for this post
      final likeResponse = await supabase
          .from('PostLike')
          .select()
          .eq('PostId', postId);

      final likeCount = likeResponse.length;

      // Check if the current user has liked this post
      final userLikeResponse = await supabase
          .from('PostLike')
          .select()
          .eq('PostId', postId)
          .eq('UserId', userId);
      final isLiked = userLikeResponse.isNotEmpty;

      // Create a PostModel from the response
      final postModel = PostModel(
        id: response['Id'],
        content: response['Content'],
        category: response['Category'],
        userId: userId,
        imageUrl: response['ImageUrl'],
        createdAt: DateTime.parse(response['CreatedAt']),
        // updatedAt is not defined in PostModel constructor
        likeCount: likeCount,
        isLiked: isLiked,
        userName: userProfileResponse['DisplayName'],
        userAvatar: userProfileResponse['AvatarUrl'],
      );

      return postModel;
    } catch (e) {
      print('Error editing post: $e');
      throw Exception('Failed to edit post: $e');
    }
  }

  @override
  Future<bool> deletePost({
    required String postId,
    required String userId,
  }) async {
    try {
      // First verify that the user is the author of the post
      await supabase
          .from('Post')
          .select()
          .eq('Id', postId)
          .eq('UserId', userId) // Ensure the user is the author
          .single();

      // Soft delete the post by setting DeletedAt
      await supabase
          .from('Post')
          .update({'DeletedAt': DateTime.now().toIso8601String()})
          .eq('Id', postId)
          .eq('UserId', userId); // Ensure the user is the author

      return true;
    } catch (e) {
      print('Error deleting post: $e');
      return false;
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
        // Check if the user has already liked the post
        final existingLike = await supabase
            .from('PostLike')
            .select()
            .eq('PostId', postId)
            .eq('UserId', userId);

        if (existingLike.isEmpty) {
          // Add a like
          await supabase.from('PostLike').insert({
            'PostId': postId,
            'UserId': userId,
          });

          // Increment the like count in the post
          await supabase.rpc('increment_post_like_count', params: {
            'post_id': postId,
            'increment_by': 1,
          });
        }
      } else {
        // Remove the like
        await supabase
            .from('PostLike')
            .delete()
            .eq('PostId', postId)
            .eq('UserId', userId);

        // Decrement the like count in the post
        await supabase.rpc('increment_post_like_count', params: {
          'post_id': postId,
          'increment_by': -1,
        });
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
