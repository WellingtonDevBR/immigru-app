import 'dart:io';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/features/home/domain/entities/post.dart';
import 'package:immigru/features/home/domain/entities/post_media.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Data source for post-related operations
class PostDataSource {
  final SupabaseClient _supabaseClient;
  final UnifiedLogger _logger = UnifiedLogger();

  /// Constructor
  PostDataSource({
    SupabaseClient? supabaseClient,
  }) : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  /// Invalidate any cached data for a specific post
  /// This ensures we always get fresh data after interactions
  Future<void> _invalidatePostCache(String postId) async {
    try {
      _logger.d('Invalidating cache for post: $postId', tag: 'PostDataSource');

      // Force a direct database refresh to clear any cached data
      // This is a more reliable approach than trying to access cache directly
      try {
        // Clear any in-memory caches in the app
        // We can't directly access the cache, so we'll use a workaround
        // by forcing a refresh of the data

        // Log that we're forcing a refresh
        _logger.d('Forcing refresh of post data for post: $postId',
            tag: 'PostDataSource');

        // Perform a direct database query to force refresh of the post data
        // This will update any cached data in the Supabase client
        await _supabaseClient
            .from('Post')
            .select('*')
            .eq('Id', postId)
            .limit(1)
            .single();

        // Also refresh the like and comment counts
        await _supabaseClient
            .from('PostLike')
            .select('count')
            .eq('PostId', postId)
            .count();

        await _supabaseClient
            .from('PostComment')
            .select('count')
            .eq('PostId', postId)
            .count();
      } catch (e) {
        // Ignore errors from cache refresh - it might not be available
        _logger.d('Cache refresh not available: $e', tag: 'PostDataSource');
      }

      // Force a direct database query to update the post in the database
      // This ensures other clients will see the updated data
      try {
        await _supabaseClient
            .rpc('refresh_post_counts', params: {'post_id': postId});
      } catch (e) {
        _logger.w('RPC refresh failed after like: $e', tag: 'PostDataSource');
        // Continue execution even if the RPC call fails
        // The app will still function correctly, but counts might be slightly out of sync
        // until the next full refresh
      }

      _logger.d('Cache invalidated for post: $postId', tag: 'PostDataSource');
    } catch (e) {
      _logger.e('Error invalidating cache: $e', tag: 'PostDataSource');
      // Continue execution even if cache invalidation fails
    }
  }
  

  /// Check for post updates (new posts, likes, comments) since a given timestamp
  /// Returns a map with update information
  Future<Map<String, dynamic>> checkForPostUpdates({
    required DateTime since,
    required String userId,
  }) async {
    try {
      _logger.d('Checking for post updates since ${since.toIso8601String()}',
          tag: 'PostDataSource');

      // Use the new RPC function to check for updates in a single call
      final response = await _supabaseClient.rpc(
        'check_post_updates',
        params: {
          'last_check_time': since.toIso8601String(),
          'user_id': userId,
        },
      );

      // Parse the response
      final updates = response as Map<String, dynamic>;
      
      _logger.d(
          'Found updates: ${updates['newPostsCount']} new posts, ' '${updates['updatedPostsCount']} updated posts, ' +
          '${updates['newLikesCount']} new likes, ' +
          '${updates['newCommentsCount']} new comments',
          tag: 'PostDataSource');

      return updates;
    } catch (e) {
      _logger.e('Error checking for post updates: $e', tag: 'PostDataSource');
      // Return a default map with all counts as 0
      return {
        'newPostsCount': 0,
        'updatedPostsCount': 0,
        'newLikesCount': 0,
        'newCommentsCount': 0,
        'hasUpdates': false,
      };
    }
  }
  
  /// Check for new posts since a given timestamp
  /// Returns the count of new posts
  Future<int> checkForNewPosts({
    required DateTime since,
    String filter = 'all',
    String? category,
    String? userId,
    String? immigroveId,
    bool excludeCurrentUser = false,
    String? currentUserId,
  }) async {
    try {
      _logger.d('Checking for new posts since ${since.toIso8601String()}',
          tag: 'PostDataSource');

      // Build query to count posts newer than the given timestamp
      var query = _supabaseClient
          .from('Post')
          .select('count')
          .filter('CreatedAt', 'gt', since.toIso8601String())
          .filter('DeletedAt', 'is', null);

      // Apply filters based on parameters (same logic as getPosts)
      if (filter == 'user' && userId != null) {
        query = query.eq('UserId', userId);
      } else if (filter == 'following' && currentUserId != null) {
        // For the 'following' filter, we need to get the users that the current user is following
        // Using the UserConnection table with the correct column names
        final followingResponse = await _supabaseClient
            .from('UserConnection')
            .select('ReceiverId')
            .eq('SenderId', currentUserId)
            .eq('Status', 'accepted');

        final followingIds = (followingResponse as List)
            .map((item) => item['ReceiverId'] as String)
            .toList();

        if (followingIds.isEmpty) {
          return 0; // No following users, so no posts
        }

        query = query.filter('UserId', 'in', followingIds);
      } else if (filter == 'immigrove' && immigroveId != null) {
        query = query.eq('ImmigroveId', immigroveId);
      }

      // Apply category filter if provided
      if (category != null && category.isNotEmpty) {
        query = query.eq('Category', category);
      }

      // Apply user filter if requested
      if (excludeCurrentUser && currentUserId != null) {
        query = query.neq('UserId', currentUserId);
      }

      // Execute the count query
      final response = await query.count();
      final newPostsCount = response.count;

      _logger.d(
          'Found $newPostsCount new posts since ${since.toIso8601String()}',
          tag: 'PostDataSource');

      return newPostsCount;
    } catch (e) {
      _logger.e('Error checking for new posts: $e', tag: 'PostDataSource');
      return 0; // Return 0 on error to avoid false positives
    }
  }

  /// Update like and comment counts for a list of posts
  /// Returns the updated posts
  Future<List<Post>> updatePostCounts({
    required List<Post> posts,
    required String currentUserId,
  }) async {
    try {
      _logger.d('Updating counts for ${posts.length} posts',
          tag: 'PostDataSource');

      final updatedPosts = <Post>[];

      // Process posts in batches to avoid overwhelming the database
      // This is more efficient than updating each post individually
      final batches = <List<Post>>[];
      for (var i = 0; i < posts.length; i += 5) {
        final end = (i + 5 < posts.length) ? i + 5 : posts.length;
        batches.add(posts.sublist(i, end));
      }

      for (final batch in batches) {
        final batchFutures = <Future<Post>>[];

        for (final post in batch) {
          batchFutures.add(_updateSinglePostCounts(post, currentUserId));
        }

        // Wait for all futures in this batch to complete
        final batchResults = await Future.wait(batchFutures);
        updatedPosts.addAll(batchResults);
      }

      _logger.d('Successfully updated counts for ${updatedPosts.length} posts',
          tag: 'PostDataSource');

      return updatedPosts;
    } catch (e) {
      _logger.e('Error updating post counts: $e', tag: 'PostDataSource');
      return posts; // Return original posts on error
    }
  }

  /// Helper method to update counts for a single post
  /// This implementation uses a single RPC call to get all interaction data
  Future<Post> _updateSinglePostCounts(Post post, String currentUserId) async {
    try {
      _logger.d('Updating counts for post ${post.id}', tag: 'PostDataSource');

      // Use the new RPC function to get all interaction data in a single call
      // This is more efficient and ensures we always get fresh data
      final interactionData = await _supabaseClient.rpc(
        'get_post_interaction_data',
        params: {
          'post_id': post.id,
          'user_id': currentUserId,
        },
      );

      // Extract the data from the response
      int likeCount;
      int commentCount;
      bool isLiked;
      bool hasUserComment;

      if (interactionData != null) {
        // If the RPC call succeeded, extract the data from the JSON response
        likeCount = interactionData['likeCount'] as int;
        commentCount = interactionData['commentCount'] as int;
        isLiked = interactionData['isLiked'] as bool;
        hasUserComment = interactionData['hasUserComment'] as bool;

        _logger.d(
            'Post ${post.id} has $likeCount likes and $commentCount comments. ' 'User liked: $isLiked, user commented: $hasUserComment',
            tag: 'PostDataSource');
      } else {
        // If the RPC call failed, fall back to the original implementation
        _logger.w('RPC call failed, falling back to regular queries',
            tag: 'PostDataSource');

        // Get like count
        final likeCountResponse = await _supabaseClient
            .from('PostLike')
            .select('count')
            .eq('PostId', post.id)
            .count();
        likeCount = likeCountResponse.count;

        // Get comment count
        final commentCountResponse = await _supabaseClient
            .from('PostComment')
            .select('count')
            .eq('PostId', post.id)
            .count();
        commentCount = commentCountResponse.count;

        // Check if user has liked the post
        final isLikedResponse = await _supabaseClient
            .from('PostLike')
            .select()
            .eq('PostId', post.id)
            .eq('UserId', currentUserId)
            .maybeSingle();
        isLiked = isLikedResponse != null;

        // Check if user has commented on the post
        final hasCommentedResponse = await _supabaseClient
            .from('PostComment')
            .select()
            .eq('PostId', post.id)
            .eq('UserId', currentUserId)
            .maybeSingle();
        hasUserComment = hasCommentedResponse != null;
      }

      // Create updated post with new counts
      return Post(
        id: post.id,
        content: post.content,
        category: post.category,
        userId: post.userId,
        imageUrl: post.imageUrl,
        createdAt: post.createdAt,
        likeCount: likeCount, // Use our calculated like count
        commentCount: commentCount, // Use our calculated comment count
        isLiked: isLiked, // Use our calculated isLiked value
        hasUserComment:
            hasUserComment, // Use our calculated hasUserComment value
        userName: post.userName,
        userAvatar: post.userAvatar,
      );
    } catch (e) {
      _logger.e('Error updating counts for post ${post.id}: $e',
          tag: 'PostDataSource');
      return post; // Return original post on error
    }
  }

  /// Like or unlike a post
  /// Returns true if the operation was successful
  Future<bool> likePost({
    required String postId,
    required String userId,
    required bool like,
  }) async {
    try {
      _logger.d('${like ? "Liking" : "Unliking"} post: $postId by user: $userId', tag: 'PostDataSource');
      
      if (like) {
        // Check if the user has already liked the post
        final existingLike = await _supabaseClient
            .from('PostLike')
            .select()
            .eq('PostId', postId)
            .eq('UserId', userId)
            .maybeSingle();
        
        // If the user has already liked the post, return true
        if (existingLike != null) {
          _logger.d('User has already liked this post', tag: 'PostDataSource');
          return true;
        }
        
        // Like the post
        await _supabaseClient.from('PostLike').insert({
          'PostId': postId,
          'UserId': userId,
          'CreatedAt': DateTime.now().toIso8601String(),
        });
        
        // Invalidate any cached data for this post
        // This ensures all clients see the latest data
        await _invalidatePostCache(postId);
        
        // Force a refresh of the post counts via RPC
        try {
          await _supabaseClient.rpc('refresh_post_counts', params: {'post_id': postId});
          _logger.d('Post counts refreshed via RPC after like', tag: 'PostDataSource');
        } catch (rpcError) {
          _logger.w('RPC refresh failed after like: $rpcError', tag: 'PostDataSource');
        }
        
        _logger.d('Post liked successfully', tag: 'PostDataSource');
        return true;
      } else {
        // Unlike the post
        await _supabaseClient
            .from('PostLike')
            .delete()
            .eq('PostId', postId)
            .eq('UserId', userId);
        
        // Invalidate any cached data for this post
        // This ensures all clients see the latest data
        await _invalidatePostCache(postId);
        
        // Force a refresh of the post counts via RPC
        try {
          await _supabaseClient.rpc('refresh_post_counts', params: {'post_id': postId});
          _logger.d('Post counts refreshed via RPC after unlike', tag: 'PostDataSource');
        } catch (rpcError) {
          _logger.w('RPC refresh failed after unlike: $rpcError', tag: 'PostDataSource');
        }
        
        _logger.d('Post unliked successfully', tag: 'PostDataSource');
        return true;
      }
    } catch (e, stackTrace) {
      _logger.e('Error ${like ? "liking" : "unliking"} post: $e',
          tag: 'PostDataSource', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Delete a post (soft delete by setting DeletedAt)
  Future<bool> deletePost({
    required String postId,
    required String userId,
  }) async {
    try {
      _logger.d('Deleting post: $postId', tag: 'PostDataSource');

      // Check if the post exists and belongs to the user
      final postResponse = await _supabaseClient
          .from('Post')
          .select()
          .eq('Id', postId)
          .eq('UserId', userId)
          .filter('DeletedAt', 'is', null)
          .maybeSingle();

      if (postResponse == null) {
        throw Exception(
            'Post not found or you do not have permission to delete it');
      }

      // Soft delete the post by setting DeletedAt
      await _supabaseClient
          .from('Post')
          .update({
            'DeletedAt': DateTime.now().toIso8601String(),
          })
          .eq('Id', postId)
          .eq('UserId', userId);

      return true;
    } catch (e) {
      _logger.e('Error deleting post: $e', tag: 'PostDataSource');
      throw Exception('Failed to delete post: $e');
    }
  }

  /// Toggle the like status of a post
  Future<bool> togglePostLike({
    required String postId,
    required String userId,
    required bool like,
  }) async {
    try {
      _logger.d('${like ? 'Liking' : 'Unliking'} post: $postId',
          tag: 'PostDataSource');

      // Check if the post exists
      final postResponse = await _supabaseClient
          .from('Post')
          .select()
          .eq('Id', postId)
          .filter('DeletedAt', 'is', null)
          .maybeSingle();

      if (postResponse == null) {
        throw Exception('Post not found');
      }

      // Check if the user has already liked the post
      final likeResponse = await _supabaseClient
          .from('PostLike')
          .select()
          .eq('PostId', postId)
          .eq('UserId', userId)
          .maybeSingle();

      final hasLiked = likeResponse != null;

      // If the user wants to like the post and hasn't already liked it
      if (like && !hasLiked) {
        await _supabaseClient.from('PostLike').insert({
          'PostId': postId,
          'UserId': userId,
          'CreatedAt': DateTime.now().toIso8601String(),
        });
        
        // Invalidate any cached data for this post
        await _invalidatePostCache(postId);

        return true;
      }

      // If the user wants to unlike the post and has already liked it
      if (!like && hasLiked) {
        await _supabaseClient
            .from('PostLike')
            .delete()
            .eq('PostId', postId)
            .eq('UserId', userId);
            
        // Invalidate any cached data for this post
        await _invalidatePostCache(postId);

        return true;
      }

      // If the user wants to like a post they've already liked or unlike a post they haven't liked
      return false;
    } catch (e) {
      _logger.e('Error ${like ? 'liking' : 'unliking'} post: $e',
          tag: 'PostDataSource');
      throw Exception('Failed to ${like ? 'like' : 'unlike'} post: $e');
    }
  }

  /// Create a new post using the Supabase edge function
  Future<Map<String, dynamic>> createPost({
    required String userId,
    required String content,
    required String type,
    List<PostMedia>? media,
  }) async {
    try {
      _logger.d('Creating post with payload: userId=$userId, type=$type',
          tag: 'PostDataSource');

      // Prepare media items for the API
      List<Map<String, dynamic>>? mediaItems;

      if (media != null && media.isNotEmpty) {
        mediaItems = media
            .map((item) => {
                  'id': item.id,
                  'path': item.path,
                  'name': item.name,
                  'type': item.type.toString().split('.').last,
                  'createdAt': item.createdAt.toIso8601String(),
                })
            .toList();
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

      // Log the request details for debugging
      _logger.d('Invoking edge function: create-post', tag: 'PostDataSource');
      _logger.d('Request body: $payload', tag: 'PostDataSource');

      // Get the current session for authentication
      final session = _supabaseClient.auth.currentSession;
      if (session == null) {
        _logger.e('No auth session available', tag: 'PostDataSource');
        throw Exception('Authentication required to create post');
      }

      // Call the edge function directly using Supabase client
      final response = await _supabaseClient.functions.invoke(
        'create-post',
        body: payload,
        method: HttpMethod.post,
      );

      // Log the response for debugging
      _logger.d('Response status: ${response.status}', tag: 'PostDataSource');
      _logger.d('Response data: ${response.data}', tag: 'PostDataSource');

      // Check if response data is null
      if (response.data == null) {
        throw Exception('Edge function returned null response');
      }

      // Convert the response to a Map
      return response.data as Map<String, dynamic>;
    } catch (e, stackTrace) {
      _logger.e('Error creating post: $e\n$stackTrace', tag: 'PostDataSource');
      throw Exception('Failed to create post: $e');
    }
  }

  /// Upload media for a post and get the public URL
  Future<String> uploadPostMedia(String filePath, String fileName) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = 'posts/$timestamp-$fileName';

      // Create a File object from the file path
      final file = File(filePath);

      // Upload the file to Supabase storage
      await _supabaseClient.storage.from('media').upload(storagePath, file);

      // Get the public URL for the uploaded file
      final publicUrl =
          _supabaseClient.storage.from('media').getPublicUrl(storagePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload media: $e');
    }
  }

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
  /// [bypassCache] - Whether to bypass cache for this request
  Future<List<Post>> getPosts({
    String filter = 'all',
    String? category,
    String? userId,
    String? immigroveId,
    bool excludeCurrentUser = false,
    String? currentUserId,
    int limit = 20,
    int offset = 0,
    bool bypassCache = false, // New parameter to force bypass cache
  }) async {
    try {
      _logger.d('Getting posts with filter: $filter', tag: 'PostDataSource');

      // Start with a base query
      var query = _supabaseClient
          .from('Post')
          .select('*')
          .filter('DeletedAt', 'is', null);

      // Apply filters based on parameters
      if (filter == 'user' && userId != null) {
        query = query.eq('UserId', userId);
      } else if (filter == 'following' && currentUserId != null) {
        // For the 'following' filter, we'll use a different approach to avoid type issues
        _logger.d('Processing following filter for user: $currentUserId',
            tag: 'PostDataSource');

        // Get the list of users that the current user is following
        final followingResponse = await _supabaseClient
            .from('UserFollowing')
            .select('FollowingUserId')
            .eq('UserId', currentUserId);

        if (followingResponse.isNotEmpty) {
          // For simplicity, we'll just use the first 10 following users
          // In a real app, you would handle this more efficiently
          _logger.d('Found ${followingResponse.length} following users',
              tag: 'PostDataSource');

          // Get posts for each following user and combine them
          List<Post> allPosts = [];

          // Limit to first 10 to avoid too many queries
          final followingUserIds = followingResponse
              .take(10)
              .map((item) {
                final id = item['FollowingUserId']?.toString();
                return id != null && id.isNotEmpty ? id : null;
              })
              .where((id) => id != null)
              .cast<String>()
              .toList();

          // For each user, get their posts individually and combine them
          for (final followUserId in followingUserIds) {
            // Create a new query for each user to avoid type issues
            final userQuery = _supabaseClient
                .from('Post')
                .select('*')
                .filter('DeletedAt', 'is', null)
                .eq('UserId', followUserId)
                .order('CreatedAt', ascending: false)
                .limit(limit ~/ followingUserIds.length);

            final userPostsResponse = await userQuery;

            // Process each post
            for (final post in userPostsResponse) {
              final postId = post['Id'] as String;
              final userId = post['UserId'] as String;

              // Get like count for this post
              final likeCountResponse = await _supabaseClient
                  .from('PostLike')
                  .select()
                  .eq('PostId', postId);

              final likeCount = likeCountResponse.length;

              // Check if the current user has liked this post
              final currentUser = _supabaseClient.auth.currentUser;
              bool isLikedByCurrentUser = false;
              if (currentUser != null) {
                final likeResponse = await _supabaseClient
                    .from('PostLike')
                    .select()
                    .eq('PostId', postId)
                    .eq('UserId', currentUser.id);
                isLikedByCurrentUser = likeResponse.isNotEmpty;
              }

              // Get user profile information
              final userProfileResponse = await _supabaseClient
                  .from('UserProfile')
                  .select()
                  .eq('UserId', userId)
                  .single();

              // Create a Post model with all the data
              final postModel = Post(
                id: postId,
                content: post['Content'],
                category: post['Category'],
                userId: userId,
                imageUrl: post['ImageUrl'],
                createdAt: DateTime.parse(post['CreatedAt']),
                likeCount: likeCount,
                isLiked: isLikedByCurrentUser,
                userName: userProfileResponse['DisplayName'],
                userAvatar: userProfileResponse['AvatarUrl'],
              );

              allPosts.add(postModel);
            }
          }

          // Sort by creation date (newest first)
          allPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          // Apply pagination
          final start = offset < allPosts.length ? offset : allPosts.length;
          final end = (offset + limit) < allPosts.length
              ? (offset + limit)
              : allPosts.length;

          return allPosts.isNotEmpty ? allPosts.sublist(start, end) : [];
        } else {
          // If the user is not following anyone, return an empty list
          return [];
        }
      } else if (filter == 'my-immigroves' && currentUserId != null) {
        // For the 'my-immigroves' filter, we'll use a different approach to avoid type issues
        _logger.d('Processing my-immigroves filter for user: $currentUserId',
            tag: 'PostDataSource');

        // Get the list of ImmiGroves that the current user is a member of
        final membershipResponse = await _supabaseClient
            .from('ImmiGroveMember')
            .select('ImmiGroveId')
            .eq('UserId', currentUserId);

        if (membershipResponse.isNotEmpty) {
          // For simplicity, we'll just use the first 5 ImmiGroves
          // In a real app, you would handle this more efficiently
          _logger.d('Found ${membershipResponse.length} ImmiGrove memberships',
              tag: 'PostDataSource');

          // Get posts for each ImmiGrove and combine them
          List<Post> allPosts = [];

          // Limit to first 5 to avoid too many queries
          final immiGroveIds = membershipResponse
              .take(5)
              .map((item) {
                final id = item['ImmiGroveId']?.toString();
                return id != null && id.isNotEmpty ? id : null;
              })
              .where((id) => id != null)
              .cast<String>()
              .toList();

          // For each ImmiGrove, get posts individually and combine them
          for (final immiGroveId in immiGroveIds) {
            // Create a new query for each ImmiGrove to avoid type issues
            final groveQuery = _supabaseClient
                .from('Post')
                .select('*')
                .filter('DeletedAt', 'is', null)
                .eq('ImmiGroveId', immiGroveId)
                .order('CreatedAt', ascending: false)
                .limit(limit ~/ immiGroveIds.length);

            final grovePostsResponse = await groveQuery;

            // Process each post
            for (final post in grovePostsResponse) {
              Post? postModel;
              try {
                // Safely extract post ID and user ID with null checks
                final postId = post['Id']?.toString() ?? '';
                if (postId.isEmpty) {
                  _logger.w('Skipping ImmiGrove post with empty ID',
                      tag: 'PostDataSource');
                  continue; // Skip posts with no ID
                }

                final userId = post['UserId']?.toString() ?? '';
                if (userId.isEmpty) {
                  _logger.w('Skipping ImmiGrove post with empty userId',
                      tag: 'PostDataSource');
                  continue; // Skip posts with no user ID
                }

                // Get like count for this post
                final likeCountResponse = await _supabaseClient
                    .from('PostLike')
                    .select()
                    .eq('PostId', postId);

                final likeCount = likeCountResponse.length;

                // Check if the current user has liked this post
                final currentUser = _supabaseClient.auth.currentUser;
                bool isLikedByCurrentUser = false;
                if (currentUser != null) {
                  final likeResponse = await _supabaseClient
                      .from('PostLike')
                      .select()
                      .eq('PostId', postId)
                      .eq('UserId', currentUser.id);
                  isLikedByCurrentUser = likeResponse.isNotEmpty;
                }

                // Get user profile information
                Map<String, dynamic>? userProfileResponse;
                try {
                  userProfileResponse = await _supabaseClient
                      .from('UserProfile')
                      .select()
                      .eq('UserId', userId)
                      .maybeSingle();
                } catch (e) {
                  _logger.w(
                      'Error fetching user profile for ImmiGrove post userId $userId: $e',
                      tag: 'PostDataSource');
                  // Continue with null userProfileResponse, we'll handle it below
                }

                // Safely extract post data with null checks
                final content = post['Content']?.toString() ?? '';
                final category = post['Category']?.toString() ?? '';
                final imageUrl = post['ImageUrl']?.toString();

                // Parse createdAt with error handling
                DateTime createdAt;
                try {
                  final createdAtStr = post['CreatedAt']?.toString();
                  createdAt = createdAtStr != null
                      ? DateTime.parse(createdAtStr)
                      : DateTime.now();
                } catch (e) {
                  _logger.w(
                      'Error parsing CreatedAt for ImmiGrove post $postId: $e',
                      tag: 'PostDataSource');
                  createdAt = DateTime.now();
                }

                // Safely extract user profile data
                final userName =
                    userProfileResponse?['DisplayName']?.toString() ??
                        'Unknown User';
                final userAvatar =
                    userProfileResponse?['AvatarUrl']?.toString();

                // Create a Post model with all the data
                postModel = Post(
                  id: postId,
                  content: content,
                  category: category,
                  userId: userId,
                  imageUrl: imageUrl,
                  createdAt: createdAt,
                  likeCount: likeCount,
                  isLiked: isLikedByCurrentUser,
                  userName: userName,
                  userAvatar: userAvatar,
                );
              } catch (e) {
                // Log the error but continue processing other posts
                _logger.e('Error processing ImmiGrove post: $e',
                    tag: 'PostDataSource');
                // Continue to the next post
                continue;
              }

              // Add the post to our collection
              allPosts.add(postModel);
            }
          }

          // Sort by creation date (newest first)
          allPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          // Apply pagination
          final start = offset < allPosts.length ? offset : allPosts.length;
          final end = (offset + limit) < allPosts.length
              ? (offset + limit)
              : allPosts.length;

          return allPosts.isNotEmpty ? allPosts.sublist(start, end) : [];
        } else {
          // If the user is not a member of any ImmiGrove, return an empty list
          return [];
        }
      }

      // Apply category filter if provided
      if (category != null) {
        query = query.eq('Category', category);
      }

      // Apply ImmiGrove filter if provided
      if (immigroveId != null) {
        query = query.eq('ImmiGroveId', immigroveId);
      }

      // Exclude current user's posts if requested
      if (excludeCurrentUser && currentUserId != null) {
        query = query.neq('UserId', currentUserId);
      }

      // Apply pagination and execute the query
      // Note: order() and range() methods return PostgrestTransformBuilder, not PostgrestFilterBuilder
      // So we need to execute the query directly after applying these transformations
      final response = await query
          .order('CreatedAt', ascending: false)
          .range(offset, offset + limit - 1);

      // Get the current user ID for determining if the post is liked by the current user
      final currentUser = _supabaseClient.auth.currentUser;
      final loggedInUserId = currentUser?.id;

      // Get like counts and check if the current user has liked each post
      final List<Post> posts = [];
      for (final post in response) {
        try {
          // Safely extract post ID and user ID with null checks
          final postId = post['Id']?.toString() ?? '';
          if (postId.isEmpty) {
            _logger.w('Skipping post with empty ID', tag: 'PostDataSource');
            continue; // Skip posts with no ID
          }

          final userId = post['UserId']?.toString() ?? '';

          if (userId.isEmpty) {
            _logger.w('Skipping post with empty userId', tag: 'PostDataSource');
            continue; // Skip posts with no user ID
          }

          // Get like count for this post
          final likeCountResponse = await _supabaseClient
              .from('PostLike')
              .select('count')
              .eq('PostId', postId)
              .count();

          final likeCount = likeCountResponse.count;

          // Get comment count for this post
          final commentCountResponse = await _supabaseClient
              .from('PostComment')
              .select('count')
              .eq('PostId', postId)
              .count();

          final commentCount = commentCountResponse.count;

          _logger.d(
              'Post $postId has $likeCount likes and $commentCount comments',
              tag: 'PostDataSource');

          // Check if the current user has liked this post
          bool isLikedByCurrentUser = false;
          bool hasUserComment = false;

          if (loggedInUserId != null) {
            // Check if user has liked the post
            final likeResponse = await _supabaseClient
                .from('PostLike')
                .select()
                .eq('PostId', postId)
                .eq('UserId', loggedInUserId);
            isLikedByCurrentUser = likeResponse.isNotEmpty;

            // Check if user has commented on the post
            final commentResponse = await _supabaseClient
                .from('PostComment')
                .select()
                .eq('PostId', postId)
                .eq('UserId', loggedInUserId);
            hasUserComment = commentResponse.isNotEmpty;

            _logger.d(
                'User $loggedInUserId has ${hasUserComment ? '' : 'not '}commented on post $postId',
                tag: 'PostDataSource');
          }

          // Get user profile information
          Map<String, dynamic>? userProfileResponse;
          try {
            userProfileResponse = await _supabaseClient
                .from('UserProfile')
                .select()
                .eq('UserId', userId)
                .maybeSingle();
          } catch (e) {
            _logger.w('Error fetching user profile for userId $userId: $e',
                tag: 'PostDataSource');
            // Continue with null userProfileResponse, we'll handle it below
          }

          // Safely extract post data with null checks
          final content = post['Content']?.toString() ?? '';
          final category = post['Category']?.toString() ?? '';
          final imageUrl = post['ImageUrl']?.toString();

          // Parse createdAt with error handling
          DateTime createdAt;
          try {
            final createdAtStr = post['CreatedAt']?.toString();
            createdAt = createdAtStr != null
                ? DateTime.parse(createdAtStr)
                : DateTime.now();
          } catch (e) {
            _logger.w('Error parsing CreatedAt for post $postId: $e',
                tag: 'PostDataSource');
            createdAt = DateTime.now();
          }

          // Safely extract user profile data
          final userName =
              userProfileResponse?['DisplayName']?.toString() ?? 'Unknown User';
          final userAvatar = userProfileResponse?['AvatarUrl']?.toString();

          // Create a Post model with all the data including comment count and user comment status
          final postModel = Post(
            id: postId,
            content: content,
            category: category,
            userId: userId,
            imageUrl: imageUrl,
            createdAt: createdAt,
            likeCount: likeCount,
            commentCount: commentCount,
            isLiked: isLikedByCurrentUser,
            hasUserComment: hasUserComment, // Set based on our database check
            userName: userName,
            userAvatar: userAvatar,
          );

          posts.add(postModel);
        } catch (e) {
          // Log the error but continue processing other posts
          _logger.e('Error processing post: $e', tag: 'PostDataSource');
          // Continue to the next post
        }
      }

      return posts;
    } catch (e) {
      _logger.e('Error getting posts: $e', tag: 'PostDataSource');
      throw Exception('Failed to get posts: $e');
    }
  }

  /// Get personalized posts for the user
  Future<List<Post>> getPersonalizedPosts({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      _logger.d('Getting personalized posts for user: $userId',
          tag: 'PostDataSource');

      // This is a simplified implementation - in a real app, you would use
      // a recommendation algorithm or ML model to personalize the feed

      // For now, we'll get posts from users the current user is following
      // and posts from ImmiGroves the user is a member of

      // Get the list of users that the current user is following
      final followingResponse = await _supabaseClient
          .from('UserFollowing')
          .select('FollowingUserId')
          .eq('UserId', userId);

      List<String> followingUserIds = [];
      if (followingResponse.isNotEmpty) {
        followingUserIds = followingResponse
            .map((item) => item['FollowingUserId'] as String)
            .toList();
      }

      // Get the list of ImmiGroves that the current user is a member of
      final membershipResponse = await _supabaseClient
          .from('ImmiGroveMember')
          .select('ImmiGroveId')
          .eq('UserId', userId);

      List<String> immiGroveIds = [];
      if (membershipResponse.isNotEmpty) {
        immiGroveIds = membershipResponse
            .map((item) => item['ImmiGroveId'] as String)
            .toList();
      }

      // If the user is not following anyone and not a member of any ImmiGrove,
      // return popular posts instead
      if (followingUserIds.isEmpty && immiGroveIds.isEmpty) {
        // Just return regular posts since we don't have personalized data
        _logger.d(
            'User has no followings or ImmiGrove memberships, returning regular posts',
            tag: 'PostDataSource');
        return getPosts(limit: limit, offset: offset);
      }

      // For simplicity, we'll handle each case separately to avoid complex queries
      if (followingUserIds.isNotEmpty) {
        // Get posts from users the current user is following
        _logger.d(
            'Getting posts from ${followingUserIds.length} followed users',
            tag: 'PostDataSource');

        // Get posts for each followed user and combine them
        List<Post> allPosts = [];

        // Limit to first 10 to avoid too many queries
        final limitedUserIds = followingUserIds.take(10).toList();

        for (final followUserId in limitedUserIds) {
          final userPosts = await getPosts(
            filter: 'user',
            userId: followUserId,
            limit: limit ~/ limitedUserIds.length,
            offset: 0,
          );
          allPosts.addAll(userPosts);
        }

        // Sort by creation date (newest first)
        allPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        // Apply pagination
        final start = offset < allPosts.length ? offset : allPosts.length;
        final end = (offset + limit) < allPosts.length
            ? (offset + limit)
            : allPosts.length;

        return allPosts.isNotEmpty ? allPosts.sublist(start, end) : [];
      } else if (immiGroveIds.isNotEmpty) {
        // Get posts for each ImmiGrove and combine them
        List<Post> allPosts = [];

        // Limit to first 5 to avoid too many queries
        final limitedGroveIds = immiGroveIds.take(5).toList();

        for (final groveId in limitedGroveIds) {
          final grovePosts = await getPosts(
            immigroveId: groveId,
            limit: limit ~/ limitedGroveIds.length,
            offset: 0,
          );
          allPosts.addAll(grovePosts);
        }

        // Sort by creation date (newest first)
        allPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        // Apply pagination
        final start = offset < allPosts.length ? offset : allPosts.length;
        final end = (offset + limit) < allPosts.length
            ? (offset + limit)
            : allPosts.length;

        return allPosts.isNotEmpty ? allPosts.sublist(start, end) : [];
      }

      // If we reach here, we should return a default set of posts
      // This is a fallback in case none of the above conditions are met
      _logger.d('No specific conditions met, returning default posts',
          tag: 'PostDataSource');
      return getPosts(
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      _logger.e('Error getting personalized posts: $e', tag: 'PostDataSource');
      throw Exception('Failed to get personalized posts: $e');
    }
  }

  /// Edit an existing post
  Future<Post> editPost({
    required String postId,
    required String userId,
    required String content,
    required String category,
  }) async {
    try {
      _logger.d('Editing post: $postId', tag: 'PostDataSource');

      // Check if the post exists and belongs to the user
      final postResponse = await _supabaseClient
          .from('Post')
          .select()
          .eq('Id', postId)
          .eq('UserId', userId)
          .filter('DeletedAt', 'is', null)
          .maybeSingle();

      if (postResponse == null) {
        throw Exception(
            'Post not found or you do not have permission to edit it');
      }

      // Update the post
      final response = await _supabaseClient
          .from('Post')
          .update({
            'Content': content,
            'Category': category,
            'UpdatedAt': DateTime.now().toIso8601String(),
          })
          .eq('Id', postId)
          .eq('UserId', userId)
          .select()
          .single();

      // Get user profile information
      final userProfileResponse = await _supabaseClient
          .from('UserProfile')
          .select()
          .eq('UserId', userId)
          .single();

      // Get like count for this post
      final likeCountResponse =
          await _supabaseClient.from('PostLike').select().eq('PostId', postId);

      final likeCount = likeCountResponse.length;

      // Check if the current user has liked this post
      final currentUser = _supabaseClient.auth.currentUser;
      bool isLiked = false;

      if (currentUser != null) {
        final likeResponse = await _supabaseClient
            .from('PostLike')
            .select()
            .eq('PostId', postId)
            .eq('UserId', currentUser.id);

        isLiked = likeResponse.isNotEmpty;
      }

      // Create a Post model from the response
      final postModel = Post(
        id: response['Id'],
        content: response['Content'],
        category: response['Category'],
        userId: userId,
        imageUrl: response['ImageUrl'],
        createdAt: DateTime.parse(response['CreatedAt']),
        likeCount: likeCount,
        isLiked: isLiked,
        userName: userProfileResponse['DisplayName'],
        userAvatar: userProfileResponse['AvatarUrl'],
      );
      return postModel;
    } catch (e) {
      _logger.e('Error editing post: $e', tag: 'PostDataSource');
      throw Exception('Failed to edit post: $e');
    }
  }
}
