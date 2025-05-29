import 'package:immigru/features/home/data/models/post_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:immigru/core/network/api_client.dart';
import 'package:immigru/core/error/exceptions.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/features/home/domain/entities/post_media.dart';
import 'package:immigru/features/home/data/models/post_media_model.dart';
import 'package:immigru/features/home/domain/datasources/post_data_source.dart';
import 'package:immigru/features/home/domain/entities/post.dart';

/// Implementation of PostDataSource using Supabase
class PostDataSourceImpl implements PostDataSource {
  final SupabaseClient supabase;
  final ApiClient apiClient;
  final UnifiedLogger _logger = UnifiedLogger();

  /// Create a new PostDataSourceImpl
  PostDataSourceImpl({
    required this.supabase,
    required this.apiClient,
  });

  @override
  Future<void> invalidatePostCache(String postId) async {
    try {
      _logger.d('Invalidating cache for post: $postId',
          tag: 'PostDataSourceImpl');

      // Force a direct database refresh to clear any cached data
      await supabase
          .from('Post')
          .select('*')
          .eq('Id', postId)
          .limit(1)
          .single();

      // Also refresh the like and comment counts
      await supabase
          .from('PostLike')
          .select('count')
          .eq('PostId', postId)
          .count();

      await supabase
          .from('PostComment')
          .select('count')
          .eq('PostId', postId)
          .count();

      _logger.d('Cache invalidated for post: $postId',
          tag: 'PostDataSourceImpl');
    } catch (e) {
      _logger.e('Error invalidating post cache: $e', tag: 'PostDataSourceImpl');
      // Don't throw an exception here, as this is a non-critical operation
    }
  }

  @override
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
          tag: 'PostDataSourceImpl');

      // Build query to count posts newer than the given timestamp
      var query = supabase
          .from('Post')
          .select('count')
          .filter('CreatedAt', 'gt', since.toIso8601String())
          .filter('DeletedAt', 'is', null);

      // Apply filters based on parameters (same logic as getPosts)
      if (filter == 'user' && userId != null) {
        query = query.eq('UserId', userId);
      } else if (filter == 'following' && currentUserId != null) {
        // For the 'following' filter, we need to get the users that the current user is following
        final followingResponse = await supabase
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

        // Use 'in' operator correctly for Supabase query
        query = query.filter('UserId', 'in', followingIds);
      } else if (filter == 'immigrove' && immigroveId != null) {
        query = query.eq('ImmigroveId', immigroveId);
      }

      // Apply category filter if provided
      if (category != null && category.isNotEmpty) {
        query = query.eq('Type', category);
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
          tag: 'PostDataSourceImpl');

      return newPostsCount;
    } catch (e) {
      _logger.e('Error checking for new posts: $e', tag: 'PostDataSourceImpl');
      return 0; // Return 0 on error to avoid false positives
    }
  }

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
      var query =
          supabase.from('Post').select('*').filter('DeletedAt', 'is', null);

      // Get current user ID if needed but not provided
      String? userIdForFiltering = userId;
      String? currentUserIdForFiltering =
          currentUserId; // This is the parameter passed to the method

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
      } else if (filter == 'my-immigroves' &&
          currentUserIdForFiltering != null) {
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
        query = query.eq('Type', category);
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
      final String? loggedInUserId =
          currentUser?.id; // Renamed to avoid conflict with parameter

      // Get like counts and check if the current user has liked each post
      final List<PostModel> posts = [];
      for (final post in response) {
        final postId = post['Id'] as String;
        final userId = post['UserId'] as String;
        final userProfile = userProfilesMap[userId];

        // Get like count for this post
        final response =
            await supabase.from('PostLike').select().eq('PostId', postId);

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

        // Get media attachments for this post
        final mediaResponse = await supabase
            .from('PostMedia')
            .select('*')
            .eq('PostId', postId)
            .order('Position');

        final List<Map<String, dynamic>> media = mediaResponse.isNotEmpty
            ? List<Map<String, dynamic>>.from(mediaResponse)
            : [];

        // Convert media attachments to PostMediaModel objects
        final List<PostMediaModel> mediaAttachments = media.map((mediaItem) {
          return PostMediaModel.fromJson(mediaItem);
        }).toList();

        // Create a PostModel with all the data
        final postModel = PostModel(
          id: postId,
          content: post['Content'] as String? ?? '',
          category: post['Type'] as String? ?? '',
          userId: userId,
          imageUrl: post['MediaUrl'] as String? ?? '',
          // Always include media attachments if they exist
          media: mediaAttachments,
          createdAt: DateTime.parse(post['CreatedAt'] as String),
          likeCount: likeCount,
          isLiked: isLikedByCurrentUser,
          userName: userProfile?['DisplayName'] as String? ?? 'User',
          userAvatar: userProfile?['AvatarUrl'] as String? ?? '',
        );
        
        // Log media information for debugging
        _logger.d('Post $postId has ${mediaAttachments.length} media attachments', tag: 'PostDataSourceImpl');

        posts.add(postModel);
      }

      return posts;
    } catch (e) {
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
          .select('Type')
          .eq('UserId', userId);

      // Extract categories from the response
      final List<String> userInterests =
          userInterestsResponse.map((item) => item['Type'] as String).toList();

      // If the user has no interests, return regular posts
      if (userInterests.isEmpty) {
        return getPosts(limit: limit, offset: offset);
      }

      // Get posts matching the user's interests
      var query =
          supabase.from('Post').select('*').filter('DeletedAt', 'is', null);

      // Start with the first interest
      query = query.eq('Type', userInterests[0]);

      // Add OR conditions for the rest of the interests
      for (int i = 1; i < userInterests.length; i++) {
        query = query.or('Type.eq.${userInterests[i]}');
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
        final response =
            await supabase.from('PostLike').select().eq('PostId', postId);

        final likeCount = response.length;

        // Check if the current user has liked this post
        final likeResponse = await supabase
            .from('PostLike')
            .select()
            .eq('PostId', postId)
            .eq('UserId', userId);
        final isLikedByCurrentUser = likeResponse.isNotEmpty;

        // Get media attachments for this post
        final mediaResponse = await supabase
            .from('PostMedia')
            .select('*')
            .eq('PostId', postId)
            .order('Position');

        final List<Map<String, dynamic>> media = mediaResponse.isNotEmpty
            ? List<Map<String, dynamic>>.from(mediaResponse)
            : [];

        // Convert media attachments to PostMediaModel objects
        final List<PostMediaModel> mediaAttachments = media.map((mediaItem) {
          return PostMediaModel.fromJson(mediaItem);
        }).toList();

        // Create a PostModel with all the data
        final postModel = PostModel(
          id: postId,
          content: post['Content'] as String? ?? '',
          category: post['Type'] as String? ?? '',
          userId: postUserId,
          imageUrl: post['MediaUrl'] as String? ?? '',
          media: mediaAttachments.isNotEmpty ? mediaAttachments : null,
          createdAt: DateTime.parse(post['CreatedAt'] as String),
          likeCount: likeCount,
          isLiked: isLikedByCurrentUser,
          userName: userProfile?['DisplayName'] as String? ?? 'User',
          userAvatar: userProfile?['AvatarUrl'] as String? ?? '',
        );

        posts.add(postModel);
      }

      return posts;
    } catch (e) {
      throw ServerException(message: 'Failed to fetch personalized posts: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> createPost({
    required String content,
    required String userId,
    required String type,
    List<PostMedia>? media,
    String? imageUrl,
  }) async {
    try {
      _logger.d('Creating post with content: $content, userId: $userId, type: $type', tag: 'PostDataSourceImpl');
      if (media != null) {
        _logger.d('Post has ${media.length} media items', tag: 'PostDataSourceImpl');
        for (var i = 0; i < media.length; i++) {
          final item = media[i];
          _logger.d('Media[$i]: path=${item.path}, type=${item.type}', tag: 'PostDataSourceImpl');
        }
      }
      
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
        'Type': type, // Using the correct column name 'Type' instead of 'Category'
        'MediaUrl': imageUrl, // Using the correct column name 'MediaUrl' instead of 'ImageUrl'
        // CreatedAt will be automatically set by the database
      };

      final response =
          await supabase.from('Post').insert(postData).select().single();
      
      final postId = response['Id'] as String;
      _logger.d('Post created with ID: $postId', tag: 'PostDataSourceImpl');

      // If we have media items, insert them into the PostMedia table
      List<Map<String, dynamic>> mediaItems = [];
      if (media != null && media.isNotEmpty) {
        _logger.d('Processing ${media.length} media items for post $postId', tag: 'PostDataSourceImpl');
        
        // Create a batch of media items to insert
        final List<Map<String, dynamic>> mediaDataBatch = [];
        
        for (int i = 0; i < media.length; i++) {
          final mediaItem = media[i];
          final mediaType = mediaItem.type.toString().split('.').last.toLowerCase();
          
          _logger.d('Preparing media item $i: ${mediaItem.path}, type: $mediaType', tag: 'PostDataSourceImpl');
          
          final mediaData = {
            'PostId': postId,
            'MediaUrl': mediaItem.path,
            'MediaType': mediaType,
            'Position': i,
            // CreatedAt will be automatically set by the database
          };
          
          _logger.d('Adding media data to batch: $mediaData', tag: 'PostDataSourceImpl');
          mediaDataBatch.add(mediaData);
        }
        
        _logger.d('Final mediaDataBatch size: ${mediaDataBatch.length}', tag: 'PostDataSourceImpl');
        
        // Insert all media items in a single batch operation
        if (mediaDataBatch.isNotEmpty) {
          _logger.d('Inserting ${mediaDataBatch.length} media items in batch', tag: 'PostDataSourceImpl');
          
          try {
            final mediaResponse = await supabase
                .from('PostMedia')
                .insert(mediaDataBatch)
                .select();
            
            _logger.d('Successfully inserted ${mediaResponse.length} media items', tag: 'PostDataSourceImpl');
            
            // Log each inserted media item
            for (int i = 0; i < mediaResponse.length; i++) {
              _logger.d('Inserted media[$i]: ${mediaResponse[i]}', tag: 'PostDataSourceImpl');
            }
            
            // Add all inserted media items to the result
            for (final item in mediaResponse) {
              mediaItems.add(item);
            }
          } catch (e) {
            _logger.e('Error inserting media batch: $e', tag: 'PostDataSourceImpl');
            // Continue with the post creation even if media insertion fails
            // This way we at least create the post, even without media
          }
        }
      }

      // Create a response map with post and media data
      final result = {
        'success': true,
        'data': {
          ...response,
          'Media': mediaItems,
          'Author': {
            'Id': userId,
            'Name': userProfileResponse['DisplayName'] as String? ?? 'User',
            'ProfileImageUrl':
                userProfileResponse['AvatarUrl'] as String? ?? '',
          }
        }
      };

      return result;
    } catch (e) {
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
        'Type': category,
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
      final likeResponse =
          await supabase.from('PostLike').select().eq('PostId', postId);

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
        category: response['Type'],
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
      return false;
    }
  }

  @override
  Future<List<Post>> updatePostCounts({
    required List<Post> posts,
    required String currentUserId,
  }) async {
    try {
      _logger.d('Updating counts for ${posts.length} posts',
          tag: 'PostDataSourceImpl');

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
          tag: 'PostDataSourceImpl');

      return updatedPosts;
    } catch (e) {
      _logger.e('Error updating post counts: $e', tag: 'PostDataSourceImpl');
      return posts; // Return original posts on error
    }
  }

  /// Helper method to update counts for a single post
  Future<Post> _updateSinglePostCounts(Post post, String currentUserId) async {
    try {
      // Get like count
      final likeCountResponse = await supabase
          .from('PostLike')
          .select('count')
          .eq('PostId', post.id)
          .count();

      // Get comment count
      final commentCountResponse = await supabase
          .from('PostComment')
          .select('count')
          .eq('PostId', post.id)
          .count();

      // Check if user has liked the post
      final isLikedResponse = await supabase
          .from('PostLike')
          .select()
          .eq('PostId', post.id)
          .eq('UserId', currentUserId)
          .maybeSingle();

      // Check if user has commented on the post
      final hasCommentedResponse = await supabase
          .from('PostComment')
          .select()
          .eq('PostId', post.id)
          .eq('UserId', currentUserId)
          .maybeSingle();

      // Create updated post with new counts
      return Post(
        id: post.id,
        content: post.content,
        category: post.category,
        userId: post.userId,
        imageUrl: post.imageUrl,
        createdAt: post.createdAt,
        likeCount: likeCountResponse.count,
        commentCount: commentCountResponse.count,
        isLiked: isLikedResponse != null,
        hasUserComment: hasCommentedResponse != null,
        author: post.author,
        media: post.media,
      );
    } catch (e) {
      _logger.e('Error updating counts for post ${post.id}: $e',
          tag: 'PostDataSourceImpl');
      return post; // Return original post on error
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
