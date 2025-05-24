import 'package:immigru/features/home/data/models/post_comment_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Interface for comment data source operations
abstract class CommentDataSource {
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
  /// [rootCommentId] - Optional ID of the root comment in the thread (for nested replies)
  /// [depth] - Depth level of the comment (1 = direct post comment, 2 = reply to comment, 3 = reply to reply)
  Future<PostCommentModel> createComment({
    required String postId,
    required String userId,
    required String content,
    String? parentCommentId,
    String? rootCommentId,
    int depth = 1,
  });

  /// Edit an existing comment
  ///
  /// [commentId] - ID of the comment to edit
  /// [postId] - ID of the post the comment belongs to
  /// [userId] - ID of the user editing the comment (must be the author)
  /// [content] - New content for the comment
  Future<PostCommentModel> editComment({
    required String commentId,
    required String postId,
    required String userId,
    required String content,
  });

  /// Delete a comment
  ///
  /// [commentId] - ID of the comment to delete
  /// [postId] - ID of the post the comment belongs to
  /// [userId] - ID of the user deleting the comment (must be the author)
  Future<bool> deleteComment({
    required String commentId,
    required String postId,
    required String userId,
  });

  /// Like a comment
  ///
  /// [commentId] - ID of the comment to like
  /// [userId] - ID of the user liking the comment
  Future<void> likeComment({
    required String commentId,
    required String userId,
  });

  /// Unlike a comment
  ///
  /// [commentId] - ID of the comment to unlike
  /// [userId] - ID of the user unliking the comment
  Future<void> unlikeComment({
    required String commentId,
    required String userId,
  });

  /// Get the number of likes for a comment
  ///
  /// [commentId] - ID of the comment to get like count for
  Future<int> getCommentLikeCount({
    required String commentId,
  });

  /// Check if a user has liked a comment
  ///
  /// [commentId] - ID of the comment to check
  /// [userId] - ID of the user to check
  Future<bool> hasUserLikedComment({
    required String commentId,
    required String userId,
  });
}

/// Implementation of CommentDataSource using Supabase
class CommentDataSourceImpl implements CommentDataSource {
  final SupabaseClient supabase;

  /// Create a new CommentDataSourceImpl
  CommentDataSourceImpl({required this.supabase});

  @override
  Future<List<PostCommentModel>> getComments({
    required String postId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Get ALL comments for this post to build the complete hierarchy
      final allCommentsResponse = await supabase
          .from('PostComment')
          .select()
          .eq('PostId', postId)
          .order('CreatedAt', ascending: true);

      if (allCommentsResponse.isEmpty) {
        return [];
      }

      // Extract all user IDs to get user profiles
      final Set<String> userIds = allCommentsResponse
          .map((comment) => comment['UserId']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();

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
        final userId = profile['UserId']?.toString() ?? '';
        if (userId.isNotEmpty) {
          userProfilesMap[userId] = profile;
        }
      }

      // Get current user ID for checking if comments are liked by current user
      final currentUserId = supabase.auth.currentUser?.id;

      // Get like information for all comments
      final commentIds =
          allCommentsResponse.map((c) => c['Id'].toString()).toList();

      // Get all likes for these comments
      final likesResponse = await supabase
          .from('PostCommentLike')
          .select('*')
          .inFilter('CommentId', commentIds);

      // Create a map of comment IDs to like counts
      final Map<String, int> likeCountsMap = {};
      final Map<String, bool> userLikesMap = {};

      // Process likes to build like counts and user likes maps
      for (final like in likesResponse) {
        final commentId = like['CommentId']?.toString() ?? '';
        final likeUserId = like['UserId']?.toString() ?? '';

        if (commentId.isEmpty) continue;

        // Increment like count for this comment
        likeCountsMap[commentId] = (likeCountsMap[commentId] ?? 0) + 1;

        // Check if current user liked this comment
        if (currentUserId != null && likeUserId == currentUserId) {
          userLikesMap[commentId] = true;
        }
      }

      // Create maps to organize comments
      final Map<String, PostCommentModel> commentsById = {};
      final Map<String, List<String>> childrenByParentId = {};

      // First pass: Create all comment models and build the parent-child relationships
      for (final comment in allCommentsResponse) {
        try {
          final commentId = comment['Id']?.toString() ?? '';
          if (commentId.isEmpty) continue;

          final userId = comment['UserId']?.toString() ?? '';
          if (userId.isEmpty) continue;

          final userProfile = userProfilesMap[userId];
          final parentId = comment['ParentCommentId']?.toString();
          final rootId = comment['RootCommentId']?.toString();

          // Get the depth from the database - this is crucial for proper nesting
          int depth = 1; // Default for top-level comments
          if (comment['Depth'] != null) {
            depth = int.tryParse(comment['Depth'].toString()) ?? 1;
          } else if (parentId != null && parentId.isNotEmpty) {
            // If depth is missing but we have a parent, calculate it
            if (rootId != null && rootId.isNotEmpty && rootId != parentId) {
              // This is a level 3 comment (reply to a reply)
              depth = 3;
            } else {
              // This is a level 2 comment (direct reply to a top-level comment)
              depth = 2;
            }
          }

          // Create the comment model
          final commentModel = PostCommentModel(
            id: commentId,
            postId: comment['PostId']?.toString() ?? '',
            userId: userId,
            parentCommentId: parentId,
            rootCommentId: comment['RootCommentId']?.toString(),
            depth: depth,
            content: comment['Content']?.toString() ?? '',
            createdAt: DateTime.parse(comment['CreatedAt']?.toString() ??
                DateTime.now().toIso8601String()),
            userName: userProfile?['DisplayName']?.toString() ?? 'User',
            userAvatar: userProfile?['AvatarUrl']?.toString(),
            likeCount: likeCountsMap[commentId] ?? 0,
            isLikedByCurrentUser: userLikesMap[commentId] ?? false,
            // We'll populate replies later
            replies: [],
            isCurrentUserComment: supabase.auth.currentUser?.id == userId,
          );

          // Store in our maps
          commentsById[commentId] = commentModel;

          // Add to the children map for building the tree later
          if (parentId != null && parentId.isNotEmpty) {
            if (childrenByParentId.containsKey(parentId)) {
              childrenByParentId[parentId]!.add(commentId);
            } else {
              childrenByParentId[parentId] = [commentId];
            }
          }
        } catch (e) {}
      }

      // Second pass: Build the comment tree
      // This recursive function populates the replies for each comment
      void populateReplies(String commentId) {
        if (childrenByParentId.containsKey(commentId)) {
          final childIds = childrenByParentId[commentId]!;
          final replies = <PostCommentModel>[];
          final comment = commentsById[commentId]!;

          // Check if this is a level 3 comment - we need special handling
          final isLevel3Comment = comment.depth == 3;

          // For level 3 comments, we'll collect all their replies (and replies to those replies)
          // to attach them directly to the level 3 comment instead of nesting them
          final List<String> allLevel4Replies = [];

          if (isLevel3Comment) {
            // First, collect all direct replies to this level 3 comment
            allLevel4Replies.addAll(childIds);

            // Then, recursively collect all replies to those replies
            void collectNestedReplies(String parentId) {
              if (childrenByParentId.containsKey(parentId)) {
                final nestedChildIds = childrenByParentId[parentId]!;
                allLevel4Replies.addAll(nestedChildIds);

                // Continue recursively for deeper levels
                for (final nestedChildId in nestedChildIds) {
                  collectNestedReplies(nestedChildId);
                }
              }
            }

            // Collect all nested replies for each direct reply
            for (final childId in childIds) {
              collectNestedReplies(childId);
            }

            // Now add all these replies directly to the level 3 comment
            for (final replyId in allLevel4Replies) {
              if (commentsById.containsKey(replyId)) {
                // Add directly to this level 3 comment's replies
                // Make sure to clear any replies this comment might have
                final replyComment = commentsById[replyId]!.copyWith(
                  replies: [], // Clear any nested replies
                  depth: 4, // Mark as a level 4 reply
                );
                replies.add(replyComment);
              }
            }
          } else {
            // For level 1 or 2 comments, process normally
            for (final childId in childIds) {
              if (commentsById.containsKey(childId)) {
                // Recursively populate replies for this child
                populateReplies(childId);

                // Add the child to the replies list
                replies.add(commentsById[childId]!);
              }
            }
          }

          // Update the comment with its replies
          commentsById[commentId] = comment.copyWith(replies: replies);
        }
      }

      // Find top-level comments (those without a parent)
      final List<PostCommentModel> topLevelComments = [];

      // First, populate all comments with their replies
      for (final comment in commentsById.values) {
        if (comment.parentCommentId == null ||
            comment.parentCommentId!.isEmpty) {
          // This is a top-level comment
          populateReplies(comment.id);
          topLevelComments.add(commentsById[comment.id]!);
        }
      }

      // Sort top-level comments by creation time (newest first)
      topLevelComments.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return topLevelComments;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<PostCommentModel> createComment({
    required String postId,
    required String userId,
    required String content,
    String? parentCommentId,
    String? rootCommentId,
    int depth = 1,
  }) async {
    try {
      // Get the user profile data for the comment author
      final userProfileResponse = await supabase
          .from('UserProfile')
          .select()
          .eq('UserId', userId)
          .single();

      // Calculate the depth and root comment ID based on the parent
      int calculatedDepth = depth;
      String? calculatedRootId = rootCommentId;

      // If we have a parent comment but no root comment, the parent is the root
      if (parentCommentId != null && calculatedRootId == null) {
        // Check if the parent comment has a root comment ID
        final parentComment = await supabase
            .from('PostComment')
            .select('RootCommentId, Depth')
            .eq('Id', parentCommentId)
            .maybeSingle();

        if (parentComment != null) {
          final parentRootId = parentComment['RootCommentId']?.toString();
          final parentDepth = parentComment['Depth'] != null
              ? int.tryParse(parentComment['Depth'].toString()) ?? 1
              : 1;

          if (parentRootId != null && parentRootId.isNotEmpty) {
            // If parent has a root, use that (it's a reply to a reply)
            calculatedRootId = parentRootId;
            calculatedDepth = parentDepth + 1;
          } else {
            // Otherwise, the parent is the root
            calculatedRootId = parentCommentId;
            calculatedDepth = 2; // Level 2 comment (direct reply)
          }
        }
      }

      // Create the comment data map with fields that exist in the database
      final Map<String, dynamic> commentData = {
        'PostId': postId,
        'UserId': userId,
        'ParentCommentId': parentCommentId,
        'Content': content,
        'Depth': calculatedDepth,
      };

      // If we have a calculated root ID, add it to the data
      if (calculatedRootId != null) {
        commentData['RootCommentId'] = calculatedRootId;
      }

      // Insert the comment
      final response = await supabase
          .from('PostComment')
          .insert(commentData)
          .select()
          .single();

      // Create a PostCommentModel from the response
      return PostCommentModel(
        id: response['Id']?.toString() ?? '',
        postId: response['PostId']?.toString() ?? '',
        userId: response['UserId']?.toString() ?? '',
        parentCommentId: response['ParentCommentId']?.toString(),
        rootCommentId: response['RootCommentId']?.toString(),
        depth: response['Depth'] != null
            ? int.tryParse(response['Depth'].toString()) ?? 1
            : 1,
        content: response['Content']?.toString() ?? '',
        createdAt: DateTime.parse(response['CreatedAt']?.toString() ??
            DateTime.now().toIso8601String()),
        userName:
            userProfileResponse['DisplayName']?.toString() ?? 'Unknown User',
        userAvatar: userProfileResponse['AvatarUrl']?.toString(),
        likeCount: 0,
        isLikedByCurrentUser: false,
        replies: [],
        isCurrentUserComment: true,
      );
    } catch (e) {
      throw Exception('Failed to create comment: $e');
    }
  }

  @override
  Future<PostCommentModel> editComment({
    required String commentId,
    required String postId,
    required String userId,
    required String content,
  }) async {
    try {
      // Verify the user is the author of the comment
      // Just check if the comment exists and belongs to the user
      await supabase
          .from('PostComment')
          .select()
          .eq('Id', commentId)
          .eq('PostId', postId)
          .eq('UserId', userId)
          .single();

      // If we get here, the comment exists and the user is the author
      // Update the comment
      final response = await supabase
          .from('PostComment')
          .update({'Content': content})
          .eq('Id', commentId)
          .select()
          .single();

      // Get the user profile data for the comment author
      final userProfileResponse = await supabase
          .from('UserProfile')
          .select()
          .eq('UserId', userId)
          .single();

      // Create a PostCommentModel from the response
      return PostCommentModel(
        id: response['Id']?.toString() ?? '',
        postId: response['PostId']?.toString() ?? '',
        userId: response['UserId']?.toString() ?? '',
        parentCommentId: response['ParentCommentId']?.toString(),
        rootCommentId: response['RootCommentId']?.toString(),
        depth: response['Depth'] != null
            ? int.tryParse(response['Depth'].toString()) ?? 1
            : 1,
        content: response['Content']?.toString() ?? '',
        createdAt: DateTime.parse(response['CreatedAt']?.toString() ??
            DateTime.now().toIso8601String()),
        userName:
            userProfileResponse['DisplayName']?.toString() ?? 'Unknown User',
        userAvatar: userProfileResponse['AvatarUrl']?.toString(),
        likeCount: await getCommentLikeCount(commentId: commentId),
        isLikedByCurrentUser: await hasUserLikedComment(
          commentId: commentId,
          userId: userId,
        ),
        replies: [],
        isCurrentUserComment: true,
      );
    } catch (e) {
      throw Exception('Failed to edit comment: $e');
    }
  }

  @override
  Future<bool> deleteComment({
    required String commentId,
    required String postId,
    required String userId,
  }) async {
    try {
      // Verify the user is the author of the comment
      await supabase
          .from('PostComment')
          .select()
          .eq('Id', commentId)
          .eq('PostId', postId)
          .eq('UserId', userId)
          .single();

      // If we get here, the comment exists and the user is the author
      // Delete the comment
      await supabase.from('PostComment').delete().eq('Id', commentId);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> likeComment({
    required String commentId,
    required String userId,
  }) async {
    try {
      // Check if the user has already liked this comment
      final existingLike = await supabase
          .from('PostCommentLike')
          .select('*')
          .eq('CommentId', commentId)
          .eq('UserId', userId)
          .maybeSingle();

      // If the user hasn't liked the comment yet, create a new like
      if (existingLike == null) {
        await supabase.from('PostCommentLike').insert({
          'CommentId': commentId,
          'UserId': userId,
          'CreatedAt': DateTime.now().toIso8601String(),
        });
      } else {}
      // If the user has already liked the comment, we do nothing
    } catch (e) {
      rethrow; // Propagate the error to be handled by the caller
    }
  }

  @override
  Future<void> unlikeComment({
    required String commentId,
    required String userId,
  }) async {
    try {
      // Check if the like exists first
      final existingLike = await supabase
          .from('PostCommentLike')
          .select('*')
          .eq('CommentId', commentId)
          .eq('UserId', userId)
          .maybeSingle();

      if (existingLike != null) {
        // Delete the like record for this comment and user
        await supabase
            .from('PostCommentLike')
            .delete()
            .eq('CommentId', commentId)
            .eq('UserId', userId);
      } else {}
    } catch (e) {
      rethrow; // Propagate the error to be handled by the caller
    }
  }

  @override
  Future<int> getCommentLikeCount({
    required String commentId,
  }) async {
    try {
      // Count the number of likes for this comment
      final response = await supabase
          .from('PostCommentLike')
          .select('*')
          .eq('CommentId', commentId);

      final likeCount = response.length;

      return likeCount;
    } catch (e) {
      return 0; // Return 0 on error
    }
  }

  @override
  Future<bool> hasUserLikedComment({
    required String commentId,
    required String userId,
  }) async {
    try {
      // Check if a like record exists for this comment and user
      final response = await supabase
          .from('PostCommentLike')
          .select('*')
          .eq('CommentId', commentId)
          .eq('UserId', userId);

      final hasLiked = response.isNotEmpty;

      return hasLiked;
    } catch (e) {
      return false; // Return false on error
    }
  }
}
