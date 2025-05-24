import 'package:flutter/foundation.dart';
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
          
          if (kDebugMode) {
            print('Processing comment ID: $commentId - Depth: $depth - ParentID: $parentId - RootID: $rootId');
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
            createdAt: DateTime.parse(comment['CreatedAt']?.toString() ?? DateTime.now().toIso8601String()),
            userName: userProfile?['DisplayName']?.toString() ?? 'User',
            userAvatar: userProfile?['AvatarUrl']?.toString(),
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
        } catch (e) {
          if (kDebugMode) {
            print('Error processing comment: $e');
          }
        }
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
            
            if (kDebugMode) {
              print('Level 3 comment $commentId has ${allLevel4Replies.length} total replies (including nested)');
            }
            
            // Now add all these replies directly to the level 3 comment
            for (final replyId in allLevel4Replies) {
              if (commentsById.containsKey(replyId)) {
                // Add directly to this level 3 comment's replies
                // Make sure to clear any replies this comment might have
                final replyComment = commentsById[replyId]!;
                replies.add(PostCommentModel(
                  id: replyComment.id,
                  postId: replyComment.postId,
                  userId: replyComment.userId,
                  parentCommentId: replyComment.parentCommentId,
                  rootCommentId: replyComment.rootCommentId,
                  depth: replyComment.depth,
                  content: replyComment.content,
                  createdAt: replyComment.createdAt,
                  userName: replyComment.userName,
                  userAvatar: replyComment.userAvatar,
                  replies: [], // No nested replies for level 4+ comments
                  isCurrentUserComment: replyComment.isCurrentUserComment,
                ));
                
                if (kDebugMode) {
                  print('Adding level 4 reply ${replyComment.id} directly to level 3 comment $commentId');
                }
              }
            }
          } else {
            // Normal processing for level 1 and 2 comments
            for (final childId in childIds) {
              if (commentsById.containsKey(childId)) {
                // Recursively populate the child's replies first
                // This ensures deeper nested replies are processed before their parents
                populateReplies(childId);
                
                // Get the updated version of the child with its replies populated
                final updatedChild = commentsById[childId]!;
                
                // Add to the parent's replies
                replies.add(updatedChild);
                
                if (kDebugMode) {
                  print('Adding reply ${updatedChild.id} with depth ${updatedChild.depth} to parent $commentId');
                  print('This reply has ${updatedChild.replies.length} nested replies');
                }
              }
            }
          }
          
          // Sort replies by creation time (oldest first)
          replies.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          
          // Set the replies on the parent comment
          if (commentsById.containsKey(commentId)) {
            commentsById[commentId] = PostCommentModel(
              id: comment.id,
              postId: comment.postId,
              userId: comment.userId,
              parentCommentId: comment.parentCommentId,
              rootCommentId: comment.rootCommentId,
              depth: comment.depth,
              content: comment.content,
              createdAt: comment.createdAt,
              userName: comment.userName,
              userAvatar: comment.userAvatar,
              replies: replies,
              isCurrentUserComment: comment.isCurrentUserComment,
            );
            
            if (kDebugMode && replies.isNotEmpty) {
              print('Comment $commentId now has ${replies.length} replies');
              for (final reply in replies) {
                print('  - Reply ${reply.id} with ${reply.replies.length} nested replies');
              }
            }
          }
        }
      }
      
      // Find top-level comments (those without a parent)
      final List<PostCommentModel> topLevelComments = [];
      
      // First, populate all comments with their replies
      // This ensures that even deeply nested comments are properly organized
      for (final commentId in commentsById.keys) {
        final comment = commentsById[commentId]!;
        if (comment.parentCommentId == null || comment.parentCommentId!.isEmpty) {
          // This is a top-level comment (depth 1)
          if (kDebugMode) {
            print('Processing top-level comment: $commentId with depth ${comment.depth}');
          }
          // Populate its replies recursively
          populateReplies(commentId);
          // Then add it to our result list
          topLevelComments.add(commentsById[commentId]!);
        }
      }
      
      // Double-check that all comments are properly organized
      if (kDebugMode) {
        print('Final comment tree:');
        for (final comment in topLevelComments) {
          print('Top comment: ${comment.id}, depth: ${comment.depth}, content: ${comment.content}');
          print('Has ${comment.replies.length} replies');
          
          for (final reply in comment.replies) {
            print('  Reply: ${reply.id}, depth: ${reply.depth}, content: ${reply.content}');
            print('  Has ${reply.replies.length} replies');
            
            for (final nestedReply in reply.replies) {
              print('    Nested reply: ${nestedReply.id}, depth: ${nestedReply.depth}, content: ${nestedReply.content}');
            }
          }
        }
      }
      
      // Sort top-level comments by creation time (newest first)
      topLevelComments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      // Apply pagination to top-level comments
      final int endIndex = (offset + limit) < topLevelComments.length ? (offset + limit) : topLevelComments.length;
      final int startIndex = offset < topLevelComments.length ? offset : 0;
      
      if (startIndex < endIndex) {
        return topLevelComments.sublist(startIndex, endIndex);
      } else {
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching comments: $e');
      }
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

      // Calculate the correct depth based on parent-child relationship
      // If it's a reply to a comment, we need to determine its depth
      int calculatedDepth = depth;
      String? calculatedRootId = rootCommentId;
      
      if (parentCommentId != null) {
        // This is a reply to another comment
        try {
          // Get the parent comment to determine depth and root
          final parentComment = await supabase
              .from('PostComment')
              .select()
              .eq('Id', parentCommentId)
              .single();
          
          // Get parent's depth
          int parentDepth = 1; // Default for top-level comments
          if (parentComment['Depth'] != null) {
            parentDepth = int.tryParse(parentComment['Depth'].toString()) ?? 1;
          }
          
          if (kDebugMode) {
            print('Parent comment depth: $parentDepth');
          }
          
          // If parent is already at depth 3, maintain depth 3 (max nesting level)
          // but add a mention to the user being replied to
          if (parentDepth >= 3) {
            calculatedDepth = 3;
            // For comments beyond level 3, we use the same root as the parent
            calculatedRootId = parentComment['RootCommentId']?.toString();
            
            // Get the username of the person being replied to for the mention
            String? replyToUsername;
            try {
              final userIdBeingRepliedTo = parentComment['UserId']?.toString();
              if (userIdBeingRepliedTo != null) {
                final userProfile = await supabase
                    .from('UserProfile')
                    .select('DisplayName')
                    .eq('UserId', userIdBeingRepliedTo)
                    .maybeSingle();
                
                replyToUsername = userProfile?['DisplayName']?.toString();
              }
            } catch (e) {
              if (kDebugMode) {
                print('Error getting username for mention: $e');
              }
            }
            
            // Add mention to the content if we have a username
            if (replyToUsername != null && replyToUsername.isNotEmpty) {
              // Modify the content to include the mention
              content = '@$replyToUsername $content';
            }
            
            if (kDebugMode) {
              print('Max nesting depth reached. Keeping at level 3.');
              print('Using root comment ID: $calculatedRootId');
              print('Modified content with mention: $content');
            }
          }
          // If parent has a parent (it's a reply to a reply)
          else if (parentComment['ParentCommentId'] != null) {
            // This is a reply to a reply (depth 3)
            calculatedDepth = 3;
            
            // The root comment is the parent's root or parent's parent
            calculatedRootId = parentComment['RootCommentId']?.toString() ?? 
                              parentComment['ParentCommentId']?.toString();
            
            if (kDebugMode) {
              print('This is a level 3 comment (reply to a reply)');
            }
          } else {
            // This is a reply to a top-level comment (depth 2)
            calculatedDepth = 2;
            
            // The root comment is the parent comment
            calculatedRootId = parentCommentId;
            
            if (kDebugMode) {
              print('This is a level 2 comment (reply to a top-level comment)');
            }
          }
        } catch (e) {
          // If we can't get the parent comment, default to depth 2
          calculatedDepth = 2;
          calculatedRootId = parentCommentId;
          
          if (kDebugMode) {
            print('Error getting parent comment: $e');
            print('Defaulting to depth 2 and root comment ID $parentCommentId');
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
      
      // We'll use a two-step approach to handle the RootCommentId issue
      // First, insert the comment without RootCommentId to avoid the schema cache error
      // Then, if needed, update the comment with RootCommentId using a direct SQL query
      
      // Remove RootCommentId from the initial insert to avoid schema cache errors
      if (kDebugMode) {
        print('Will set RootCommentId: $calculatedRootId in a separate step if needed');
      }
      
      // Log what we're sending to the database for debugging
      if (kDebugMode) {
        print('Creating comment with data: $commentData');
      }
      
      // Step 1: Insert the comment without RootCommentId
      final response = await supabase
          .from('PostComment')
          .insert(commentData)
          .select()
          .single();

      final String commentId = response['Id']?.toString() ?? '';
      
      if (kDebugMode) {
        print('Comment created with ID: $commentId');
      }
      
      // Step 2: If this is a reply and we have a root comment ID, try to update it
      if (parentCommentId != null && calculatedRootId != null && commentId.isNotEmpty) {
        try {
          // Use a direct SQL update to set the RootCommentId
          // This bypasses the schema cache issue
          await supabase
              .from('PostComment')
              .update({'RootCommentId': calculatedRootId})
              .eq('Id', commentId);
          
          if (kDebugMode) {
            print('Updated RootCommentId to $calculatedRootId for comment $commentId');
          }
        } catch (e) {
          // If the update fails, log the error but continue
          // The comment was still created successfully
          if (kDebugMode) {
            print('Could not update RootCommentId: $e');
            print('This might be due to a schema cache issue in Supabase');
          }
        }
      }
      
      // Create a PostCommentModel from the response
      return PostCommentModel(
        id: response['Id']?.toString() ?? '',
        postId: response['PostId']?.toString() ?? '',
        userId: response['UserId']?.toString() ?? '',
        parentCommentId: response['ParentCommentId']?.toString(),
        // Use the values from the database response
        rootCommentId: response['RootCommentId']?.toString(),
        depth: response['Depth'] != null ? int.tryParse(response['Depth'].toString()) ?? 1 : 1,
        content: response['Content']?.toString() ?? '',
        createdAt: DateTime.parse(response['CreatedAt']?.toString() ?? DateTime.now().toIso8601String()),
        userName: userProfileResponse['DisplayName']?.toString() ?? 'Unknown User',
        userAvatar: userProfileResponse['AvatarUrl']?.toString(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error creating comment: $e');
      }
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
        depth: response['Depth'] != null ? int.tryParse(response['Depth'].toString()) ?? 1 : 1,
        content: response['Content']?.toString() ?? '',
        createdAt: DateTime.parse(response['CreatedAt']?.toString() ?? DateTime.now().toIso8601String()),
        userName: userProfileResponse['DisplayName']?.toString() ?? 'Unknown User',
        userAvatar: userProfileResponse['AvatarUrl']?.toString(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error editing comment: $e');
      }
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
      // Just check if the comment exists and belongs to the user
      await supabase
          .from('PostComment')
          .select()
          .eq('Id', commentId)
          .eq('PostId', postId)
          .eq('UserId', userId)
          .single();
      
      // If we get here, the comment exists and the user is the author
      // Delete the comment
      await supabase
          .from('PostComment')
          .delete()
          .eq('Id', commentId);
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting comment: $e');
      }
      return false;
    }
  }
}
