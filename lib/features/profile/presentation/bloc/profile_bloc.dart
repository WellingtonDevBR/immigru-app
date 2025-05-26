import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/home/domain/usecases/get_posts_usecase.dart';
import 'package:immigru/features/home/domain/entities/post.dart';
import 'package:immigru/features/home/domain/usecases/like_post_usecase.dart';
import 'package:immigru/features/home/domain/usecases/delete_post_usecase.dart';
import 'package:immigru/features/home/domain/usecases/edit_post_usecase.dart';
import 'package:immigru/features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:immigru/features/profile/domain/usecases/get_user_stats_usecase.dart';
import 'package:immigru/features/profile/domain/usecases/remove_cover_image_usecase.dart';
import 'package:immigru/features/profile/domain/usecases/update_user_profile_usecase.dart';
import 'package:immigru/features/profile/domain/usecases/upload_avatar_usecase.dart';
import 'package:immigru/features/profile/domain/usecases/upload_cover_image_usecase.dart';
import 'package:immigru/features/profile/presentation/bloc/profile_event.dart';
import 'package:immigru/features/profile/presentation/bloc/profile_post_events.dart';
import 'package:immigru/features/profile/presentation/bloc/profile_state.dart';
import 'package:get_it/get_it.dart';

/// BLoC for managing user profile state and operations
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase _getUserProfileUseCase;
  final UpdateUserProfileUseCase _updateUserProfileUseCase;
  final UploadAvatarUseCase _uploadAvatarUseCase;
  final UploadCoverImageUseCase _uploadCoverImageUseCase;
  final RemoveCoverImageUseCase _removeCoverImageUseCase;
  final GetUserStatsUseCase _getUserStatsUseCase;
  final GetPostsUseCase _getPostsUseCase;
  final LikePostUseCase _likePostUseCase;
  final DeletePostUseCase _deletePostUseCase;
  final EditPostUseCase _editPostUseCase;
  final UnifiedLogger _logger;

  /// Constructor
  ProfileBloc({
    required GetUserProfileUseCase getUserProfileUseCase,
    required UpdateUserProfileUseCase updateUserProfileUseCase,
    required UploadAvatarUseCase uploadAvatarUseCase,
    required UploadCoverImageUseCase uploadCoverImageUseCase,
    required RemoveCoverImageUseCase removeCoverImageUseCase,
    required GetUserStatsUseCase getUserStatsUseCase,
    required GetPostsUseCase getPostsUseCase,
    required LikePostUseCase likePostUseCase,
    required DeletePostUseCase deletePostUseCase,
    required EditPostUseCase editPostUseCase,
  }) : _getUserProfileUseCase = getUserProfileUseCase,
       _updateUserProfileUseCase = updateUserProfileUseCase,
       _uploadAvatarUseCase = uploadAvatarUseCase,
       _uploadCoverImageUseCase = uploadCoverImageUseCase,
       _removeCoverImageUseCase = removeCoverImageUseCase,
       _getUserStatsUseCase = getUserStatsUseCase,
       _getPostsUseCase = getPostsUseCase,
       _likePostUseCase = likePostUseCase,
       _deletePostUseCase = deletePostUseCase,
       _editPostUseCase = editPostUseCase,
       _logger = GetIt.instance<UnifiedLogger>(),
       super(const ProfileState()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<UploadAvatar>(_onUploadAvatar);
    on<UploadCoverImage>(_onUploadCoverImage);
    on<RemoveCoverImage>(_onRemoveCoverImage);
    on<LoadUserStats>(_onLoadUserStats);
    on<LoadUserPosts>(_onLoadUserPosts);
    on<LikeUserPost>(_onLikeUserPost);
    on<DeleteUserPost>(_onDeleteUserPost);
    on<UpdateUserPost>(_onUpdateUserPost);
    on<UpdateUserPostCommentStatus>(_onUpdateUserPostCommentStatus);
  }

  /// Handle the LoadUserProfile event
  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _getUserProfileUseCase(
      userId: event.userId,
      bypassCache: event.bypassCache,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        error: failure,
      )),
      (profile) => emit(state.copyWith(
        isLoading: false,
        profile: profile,
      )),
    );
  }

  /// Handle the UpdateUserProfile event
  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _updateUserProfileUseCase(
      profile: event.profile,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        error: failure,
      )),
      (profile) => emit(state.copyWith(
        isLoading: false,
        profile: profile,
      )),
    );
  }

  /// Handle the UploadAvatar event
  Future<void> _onUploadAvatar(
    UploadAvatar event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(
      isUploadingAvatar: true,
      clearAvatarUploadError: true,
    ));

    final result = await _uploadAvatarUseCase(
      userId: event.userId,
      filePath: event.filePath,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isUploadingAvatar: false,
        avatarUploadError: failure,
      )),
      (avatarUrl) {
        // Update the profile with the new avatar URL
        final updatedProfile = state.profile?.copyWith(
          avatarUrl: avatarUrl,
        );

        emit(state.copyWith(
          isUploadingAvatar: false,
          profile: updatedProfile,
        ));
      },
    );
  }

  /// Handle the UploadCoverImage event
  Future<void> _onUploadCoverImage(
    UploadCoverImage event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(
      isUploadingCover: true,
      clearCoverUploadError: true,
    ));

    final result = await _uploadCoverImageUseCase(
      userId: event.userId,
      filePath: event.filePath,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isUploadingCover: false,
        coverUploadError: failure,
      )),
      (coverUrl) {
        // Update the profile with the new cover image URL
        final updatedProfile = state.profile?.copyWith(
          coverImageUrl: coverUrl,
        );

        emit(state.copyWith(
          isUploadingCover: false,
          profile: updatedProfile,
        ));
      },
    );
  }
  
  /// Handle the RemoveCoverImage event
  Future<void> _onRemoveCoverImage(
    RemoveCoverImage event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(
      isUploadingCover: true, // Reuse the same loading state
      clearCoverUploadError: true,
    ));

    final result = await _removeCoverImageUseCase(
      userId: event.userId,
    );
    
    result.fold(
      (failure) => emit(state.copyWith(
        isUploadingCover: false,
        coverUploadError: failure,
      )),
      (success) {
        // Update the profile with an empty cover image URL
        final updatedProfile = state.profile?.copyWith(
          coverImageUrl: '', // Empty string to indicate no cover image
        );

        // Emit the updated state
        emit(state.copyWith(
          isUploadingCover: false,
          profile: updatedProfile,
        ));
        
        _logger.d('Cover image removed for user: ${event.userId}', tag: 'ProfileBloc');
      },
    );
  }

  /// Handle the LoadUserStats event
  Future<void> _onLoadUserStats(
    LoadUserStats event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(
      isStatsLoading: true,
      clearStatsError: true,
    ));

    final result = await _getUserStatsUseCase(
      userId: event.userId,
      bypassCache: event.bypassCache,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isStatsLoading: false,
        statsError: failure,
      )),
      (stats) => emit(state.copyWith(
        isStatsLoading: false,
        stats: stats,
      )),
    );
  }

  /// Handle the LoadUserPosts event
  Future<void> _onLoadUserPosts(
    LoadUserPosts event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      // Generate a request ID for logging
      final requestId = DateTime.now().millisecondsSinceEpoch.toString().substring(5);
      
      // If this is a first page load or refresh, set loading state
      if (event.offset == 0) {
        emit(state.copyWith(isPostsLoading: true, clearPostsError: true));
        _logger.d('Loading posts for user: ${event.userId}, bypassCache: ${event.bypassCache}, limit: ${event.limit}', 
            tag: 'ProfileBloc:$requestId');
      } else {
        _logger.d('Loading more posts for user: ${event.userId}, offset: ${event.offset}, bypassCache: ${event.bypassCache}', 
            tag: 'ProfileBloc:$requestId');
      }
      
      // Log the current state
      _logger.d('Current state: postsCount=${state.userPosts?.length}, ' +
          'isLoading=${state.isPostsLoading}, hasError=${state.postsError != null}',
          tag: 'ProfileBloc:$requestId');
      
      // Use the existing GetPostsUseCase with the 'user' filter
      final result = await Future.any([
        _getPostsUseCase(
          filter: 'user', // Use the 'user' filter to get only this user's posts
          userId: event.userId, // Specify which user's posts to fetch
          limit: event.limit,
          offset: event.offset,
          bypassCache: true, // Always bypass cache to avoid serialization issues
          // Don't exclude current user when viewing their own profile
          excludeCurrentUser: false,
        ),
        // Add a timeout to prevent hanging
        Future.delayed(const Duration(seconds: 15), () {
          throw Exception('Request timed out after 15 seconds');
        }),
      ]);
      
      result.fold(
        (failure) {
          _logger.e('Error loading posts: ${failure.message}', tag: 'ProfileBloc:$requestId');
          emit(state.copyWith(
            isPostsLoading: false,
            postsError: failure,
          ));
        },
        (posts) {
          _logger.d('Successfully loaded ${posts.length} posts', tag: 'ProfileBloc:$requestId');
          
          // Log the first few posts if available
          if (posts.isNotEmpty) {
            for (int i = 0; i < min(3, posts.length); i++) {
              final post = posts[i];
              _logger.d('Post $i: id=${post.id}, content=${post.content.substring(0, min(20, post.content.length))}...',
                  tag: 'ProfileBloc:$requestId');
            }
          } else {
            _logger.d('No posts returned from repository', tag: 'ProfileBloc:$requestId');
          }
          
          // If this is a pagination request (offset > 0), append to existing posts
          final updatedPosts = event.offset > 0 && state.userPosts != null
              ? [...state.userPosts!, ...posts]
              : posts;
              
          // Determine if there are more posts to load
          final hasMore = posts.length >= event.limit;
          
          _logger.d('Total posts: ${updatedPosts.length}, hasMore: $hasMore', 
              tag: 'ProfileBloc:$requestId');
          
          // Ensure we emit a new state even if the posts list is empty
          emit(state.copyWith(
            isPostsLoading: false,
            userPosts: updatedPosts,
            hasMorePosts: hasMore,
          ));
          
          // Log the updated state after emission
          _logger.d('Updated state: postsCount=${updatedPosts.length}, hasMore=$hasMore', 
              tag: 'ProfileBloc:$requestId');
        },
      );
    } catch (e) {
      _logger.e('Exception loading posts: $e', tag: 'ProfileBloc');
      emit(state.copyWith(
        isPostsLoading: false,
        postsError: Failure(message: e.toString()),
      ));
    }
  }
  
  /// Handle the LikeUserPost event
  Future<void> _onLikeUserPost(
    LikeUserPost event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final requestId = DateTime.now().millisecondsSinceEpoch.toString().substring(5);
      _logger.d('Liking post: ${event.postId}, isLiked: ${event.isLiked}', 
          tag: 'ProfileBloc:$requestId');
      
      // First update the UI optimistically
      if (state.userPosts != null) {
        final updatedPosts = List<Post>.from(state.userPosts!);
        final postIndex = updatedPosts.indexWhere((p) => p.id == event.postId);
        
        if (postIndex != -1) {
          final post = updatedPosts[postIndex];
          final updatedPost = Post(
            id: post.id,
            userId: post.userId,
            content: post.content,
            imageUrl: post.imageUrl,
            createdAt: post.createdAt,
            updatedAt: post.updatedAt,
            category: post.category,
            location: post.location,
            author: post.author,
            likeCount: event.isLiked ? post.likeCount + 1 : post.likeCount - 1,
            commentCount: post.commentCount,
            isLiked: event.isLiked,
            hasUserComment: post.hasUserComment,
            userName: post.userName,
            userAvatar: post.userAvatar,
          );
          
          updatedPosts[postIndex] = updatedPost;
          emit(state.copyWith(userPosts: updatedPosts));
          
          _logger.d('Optimistically updated post like status', 
              tag: 'ProfileBloc:$requestId');
        }
      }
      
      // Get the current user ID from state
      final userId = state.profile?.user.id;
      if (userId == null) {
        _logger.e('Cannot like post: User ID is null', tag: 'ProfileBloc:$requestId');
        emit(state.copyWith(postsError: Failure(message: 'User ID is null')));
        return;
      }
      
      // Then perform the actual API call
      final result = await _likePostUseCase(LikePostParams(
        postId: event.postId,
        userId: userId,
        like: event.isLiked,
      ));
      
      result.fold(
        (failure) {
          _logger.e('Error liking post: ${failure.message}', 
              tag: 'ProfileBloc:$requestId');
          // If there's an error, we should reload the posts to get the correct state
          // This is a simple approach - a more sophisticated one would revert the optimistic update
          emit(state.copyWith(postsError: failure));
        },
        (_) {
          _logger.d('Successfully liked/unliked post', 
              tag: 'ProfileBloc:$requestId');
        },
      );
    } catch (e) {
      _logger.e('Exception liking post: $e', tag: 'ProfileBloc');
      emit(state.copyWith(
        postsError: Failure(message: e.toString()),
      ));
    }
  }
  
  /// Handle the DeleteUserPost event
  Future<void> _onDeleteUserPost(
    DeleteUserPost event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final requestId = DateTime.now().millisecondsSinceEpoch.toString().substring(5);
      _logger.d('Deleting post: ${event.postId}', 
          tag: 'ProfileBloc:$requestId');
      
      // Get the current user ID from state
      final userId = state.profile?.user.id;
      if (userId == null) {
        _logger.e('Cannot delete post: User ID is null', tag: 'ProfileBloc:$requestId');
        emit(state.copyWith(postsError: Failure(message: 'User ID is null')));
        return;
      }
      
      // First update the UI optimistically
      if (state.userPosts != null) {
        final updatedPosts = List<Post>.from(state.userPosts!)
            .where((p) => p.id != event.postId)
            .toList();
        
        emit(state.copyWith(userPosts: updatedPosts));
        
        _logger.d('Optimistically removed post from UI', 
            tag: 'ProfileBloc:$requestId');
      }
      
      // Then perform the actual API call
      final result = await _deletePostUseCase(
        postId: event.postId,
        userId: userId,
      );
      
      result.fold(
        (failure) {
          _logger.e('Error deleting post: ${failure.message}', 
              tag: 'ProfileBloc:$requestId');
          // If there's an error, we should reload the posts to get the correct state
          emit(state.copyWith(postsError: failure));
        },
        (_) {
          _logger.d('Successfully deleted post', 
              tag: 'ProfileBloc:$requestId');
        },
      );
    } catch (e) {
      _logger.e('Exception deleting post: $e', tag: 'ProfileBloc');
      emit(state.copyWith(
        postsError: Failure(message: e.toString()),
      ));
    }
  }
  
  /// Handle the UpdateUserPost event
  Future<void> _onUpdateUserPost(
    UpdateUserPost event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final requestId = DateTime.now().millisecondsSinceEpoch.toString().substring(5);
      _logger.d('Updating post: ${event.postId} with content: ${event.content}', 
          tag: 'ProfileBloc:$requestId');
      
      // Get the current user ID from state
      final userId = state.profile?.user.id;
      if (userId == null) {
        _logger.e('Cannot update post: User ID is null', tag: 'ProfileBloc:$requestId');
        emit(state.copyWith(postsError: Failure(message: 'User ID is null')));
        return;
      }
      
      // First update the UI optimistically
      if (state.userPosts != null) {
        final updatedPosts = List<Post>.from(state.userPosts!);
        final postIndex = updatedPosts.indexWhere((p) => p.id == event.postId);
        
        if (postIndex != -1) {
          final post = updatedPosts[postIndex];
          final updatedPost = Post(
            id: post.id,
            userId: post.userId,
            content: event.content,
            imageUrl: post.imageUrl,
            createdAt: post.createdAt,
            updatedAt: DateTime.now(), // Update the timestamp
            category: post.category, // Keep the same category
            location: post.location,
            author: post.author,
            likeCount: post.likeCount,
            commentCount: post.commentCount,
            isLiked: post.isLiked,
            hasUserComment: post.hasUserComment,
            userName: post.userName,
            userAvatar: post.userAvatar,
          );
          
          updatedPosts[postIndex] = updatedPost;
          emit(state.copyWith(userPosts: updatedPosts));
          
          _logger.d('Optimistically updated post content', 
              tag: 'ProfileBloc:$requestId');
          
          // Then perform the actual API call
          final result = await _editPostUseCase(
            postId: event.postId, 
            userId: userId,
            content: event.content,
            category: post.category, // Use the existing category
          );
          
          result.fold(
            (failure) {
              _logger.e('Error updating post: ${failure.message}', 
                  tag: 'ProfileBloc:$requestId');
              // If there's an error, we should reload the posts to get the correct state
              emit(state.copyWith(postsError: failure));
            },
            (_) {
              _logger.d('Successfully updated post', 
                  tag: 'ProfileBloc:$requestId');
            },
          );
        } else {
          _logger.e('Post not found for update: ${event.postId}', tag: 'ProfileBloc:$requestId');
          emit(state.copyWith(postsError: Failure(message: 'Post not found')));
        }
      } else {
        _logger.e('No posts available for update', tag: 'ProfileBloc:$requestId');
        emit(state.copyWith(postsError: Failure(message: 'No posts available')));
      }
    } catch (e) {
      _logger.e('Exception updating post: $e', tag: 'ProfileBloc');
      emit(state.copyWith(
        postsError: Failure(message: e.toString()),
      ));
    }
  }
  
  /// Handle the UpdateUserPostCommentStatus event
  void _onUpdateUserPostCommentStatus(
    UpdateUserPostCommentStatus event,
    Emitter<ProfileState> emit,
  ) {
    try {
      final requestId = DateTime.now().millisecondsSinceEpoch.toString().substring(5);
      _logger.d('Updating post comment status: ${event.postId}, hasUserComment: ${event.hasUserComment}', 
          tag: 'ProfileBloc:$requestId');
      
      // Update the UI
      if (state.userPosts != null) {
        final updatedPosts = List<Post>.from(state.userPosts!);
        final postIndex = updatedPosts.indexWhere((p) => p.id == event.postId);
        
        if (postIndex != -1) {
          final post = updatedPosts[postIndex];
          final updatedPost = Post(
            id: post.id,
            userId: post.userId,
            content: post.content,
            imageUrl: post.imageUrl,
            createdAt: post.createdAt,
            updatedAt: post.updatedAt,
            category: post.category,
            location: post.location,
            author: post.author,
            likeCount: post.likeCount,
            commentCount: event.hasUserComment ? post.commentCount + 1 : post.commentCount,
            isLiked: post.isLiked,
            hasUserComment: event.hasUserComment,
            userName: post.userName,
            userAvatar: post.userAvatar,
          );
          
          updatedPosts[postIndex] = updatedPost;
          emit(state.copyWith(userPosts: updatedPosts));
          
          _logger.d('Updated post comment status', 
              tag: 'ProfileBloc:$requestId');
        }
      }
    } catch (e) {
      _logger.e('Exception updating post comment status: $e', tag: 'ProfileBloc');
      emit(state.copyWith(
        postsError: Failure(message: e.toString()),
      ));
    }
  }
}
