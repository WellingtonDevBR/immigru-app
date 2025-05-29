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
  })  : _getUserProfileUseCase = getUserProfileUseCase,
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
    on<ClearPostsError>(_onClearPostsError);
    on<EnableProfileScrolling>(_onEnableProfileScrolling);
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

        _logger.d('Cover image removed for user: ${event.userId}',
            tag: 'ProfileBloc');
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
      // Generate a unique request ID for logging
      final requestId =
          DateTime.now().millisecondsSinceEpoch.toString().substring(5);
      
      // Enforce a consistent batch size for better performance
      // If the requested limit is too large, cap it at 10 posts per batch
      final optimizedLimit = event.limit > 10 ? 10 : event.limit;
      
      _logger.d(
          'Loading posts for user: ${event.userId}, offset: ${event.offset}, optimized limit: $optimizedLimit (original: ${event.limit}), bypassCache: ${event.bypassCache}',
          tag: 'ProfileBloc:$requestId');

      // Log current state
      _logger.d(
          'Current state: postsCount=${state.userPosts?.length}, isLoading=${state.isPostsLoading}, hasError=${state.postsError != null}',
          tag: 'ProfileBloc:$requestId');

      // Don't emit loading state if we're already loading
      if (state.isPostsLoading) {
        _logger.d('Already loading posts, skipping request',
            tag: 'ProfileBloc:$requestId');
        return;
      }

      // Emit loading state
      emit(state.copyWith(isPostsLoading: true));
      

      // Use the existing GetPostsUseCase with the 'user' filter
      final result = await Future.any([
        _getPostsUseCase(
          filter: 'user', // Use the 'user' filter to get only this user's posts
          userId: event.userId, // Specify which user's posts to fetch
          limit: optimizedLimit, // Use the optimized limit for better performance
          offset: event.offset,
          bypassCache: event.bypassCache, // Use the provided bypass cache value
          // Don't exclude current user when viewing their own profile
          excludeCurrentUser: false,
        ),
        // Add a timeout to prevent hanging but still catch extremely long requests
        Future.delayed(const Duration(seconds: 15), () {
          throw Exception('Request timed out after 15 seconds');
        }),
      ]);

      // If we're already in a different state, don't proceed
      if (!state.isPostsLoading) {
        _logger.d('State changed during request, not updating',
            tag: 'ProfileBloc:$requestId');
        return;
      }

      await result.fold(
        (failure) async {
          _logger.e('Failed to load posts: ${failure.message}',
              tag: 'ProfileBloc:$requestId');

          // If this is a timeout or network error, we'll try again with a smaller batch size
          final isTimeoutOrNetwork =
              failure.message.toLowerCase().contains('timeout') ||
                  failure.message.toLowerCase().contains('network') ||
                  failure.message.toLowerCase().contains('connection');

          emit(state.copyWith(
            isPostsLoading: false,
            postsError: failure,
            // If we're paginating or it's a timeout, keep hasMorePosts as true to allow retrying
            hasMorePosts:
                (event.offset > 0 || isTimeoutOrNetwork) ? true : false,
          ));

          // If this is a timeout or network error and we're doing an initial load,
          // try again with a smaller batch size after a short delay
          if (isTimeoutOrNetwork && event.offset == 0) {
            // Don't await this Future to avoid blocking the event handler
            // but don't emit after it either
            Future.delayed(const Duration(seconds: 2), () {
              if (!isClosed) {
                _logger.d(
                    'Retrying with smaller batch size after timeout/network error',
                    tag: 'ProfileBloc:$requestId');
                add(LoadUserPosts(
                  userId: event.userId,
                  offset: 0,
                  limit: 5, // Use an even smaller batch size for retry
                  bypassCache: true,
                ));
              }
            });
          }
        },
        (posts) async {
          _logger.d('Successfully loaded ${posts.length} posts',
              tag: 'ProfileBloc:$requestId');

          // Log the first few posts if available
          if (posts.isNotEmpty) {
            for (int i = 0; i < min(3, posts.length); i++) {
              final post = posts[i];
              _logger.d(
                  'Post $i: id=${post.id}, content=${post.content.substring(0, min(20, post.content.length))}...',
                  tag: 'ProfileBloc:$requestId');
            }
          } else {
            _logger.d('No posts returned from repository',
                tag: 'ProfileBloc:$requestId');
          }

          // If this is a pagination request (offset > 0), append to existing posts
          // Make sure to avoid duplicates by checking post IDs
          List<Post> updatedPosts;
          if (event.offset > 0 &&
              state.userPosts != null &&
              state.userPosts!.isNotEmpty) {
            // Create a set of existing post IDs for quick lookup
            final existingPostIds = state.userPosts!.map((p) => p.id).toSet();

            // Only add posts that don't already exist in the list
            final newPosts = posts
                .where((post) => !existingPostIds.contains(post.id))
                .toList();

            _logger.d(
                'Found ${posts.length - newPosts.length} duplicate posts, adding ${newPosts.length} new posts',
                tag: 'ProfileBloc:$requestId');

            updatedPosts = [...state.userPosts!, ...newPosts];
          } else {
            updatedPosts = posts;
          }

          // Sort posts by createdAt to ensure newest posts are first
          updatedPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          // Determine if there are more posts to load based on the number of posts received
          // FIXED LOGIC: We need to be more careful about determining if there are more posts
          // We'll assume there might be more posts unless we're certain there aren't
          bool hasMore = true;

          _logger.d('DEBUG PAGINATION: Received ${posts.length} posts with limit ${event.limit} and offset ${event.offset}',
              tag: 'ProfileBloc:$requestId');

          if (event.offset > 0 && posts.isEmpty) {
            // If we're paginating and got no posts, we've reached the end
            hasMore = false;
            _logger.d('No posts received during pagination, reached the end',
                tag: 'ProfileBloc:$requestId');
          } else if (posts.length < event.limit) {
            // If we received fewer posts than requested, we might have reached the end
            // But we'll verify with stats before making a final decision
            _logger.d(
                'Received fewer posts (${posts.length}) than limit (${event.limit}), but will verify with stats before deciding',
                tag: 'ProfileBloc:$requestId');
          } else {
            // If we received exactly the limit, there are likely more posts
            hasMore = true;
            _logger.d('Received full batch of posts, there are likely more',
                tag: 'ProfileBloc:$requestId');
          }

          // If we're doing pagination and got no new posts after filtering duplicates,
          // we've likely reached the end
          if (event.offset > 0 &&
              state.userPosts != null &&
              updatedPosts.length == state.userPosts!.length) {
            hasMore = false;
            _logger.d(
                'No new posts after filtering duplicates, reached the end',
                tag: 'ProfileBloc:$requestId');
          } else {
            // IMPORTANT FIX: Even if we received fewer posts than the limit,
            // we should check against the total post count from stats before deciding there are no more
            // This ensures we don't prematurely stop pagination
            _logger.d(
                'Keeping hasMore=$hasMore for now, will verify with stats later',
                tag: 'ProfileBloc:$requestId');
          }

          _logger.d(
              'Received ${posts.length} posts, limit was ${event.limit}, hasMore=$hasMore',
              tag: 'ProfileBloc:$requestId');
          _logger.d(
              'Total posts after update: ${updatedPosts.length}, hasMore: $hasMore',
              tag: 'ProfileBloc:$requestId');

          // Emit the updated state with the posts we've loaded so far
          emit(state.copyWith(
            isPostsLoading: false,
            userPosts: updatedPosts,
            hasMorePosts: hasMore,
            // Clear any previous error when we successfully load posts
            postsError: null,
          ));

          // If this is the initial load (offset = 0), verify against user stats
          if (event.offset == 0) {
            try {
              // Get the user stats to check the actual post count
              final statsResult = await _getUserStatsUseCase(
                  userId: event.userId, bypassCache: true);

              if (isClosed) return; // Check if bloc is closed before proceeding

              await statsResult.fold(
                (failure) async {
                  _logger.w(
                      'Failed to get user stats for post count verification: ${failure.message}',
                      tag: 'ProfileBloc:$requestId');
                },
                (stats) async {
                  if (isClosed) {
                    return; // Double check if bloc is closed before proceeding
                  }

                  final actualPostCount = stats['postsCount'] ?? 0;
                  _logger.d(
                      'User stats show $actualPostCount posts, we loaded ${updatedPosts.length} posts',
                      tag: 'ProfileBloc:$requestId');

                  // IMPROVED LOGIC: Better handling of post count verification
                  _logger.d(
                      'STATS VERIFICATION: Stats show $actualPostCount posts, we have loaded ${updatedPosts.length}',
                      tag: 'ProfileBloc:$requestId');

                  // If we have fewer posts than the stats indicate, there are definitely more to load
                  if (actualPostCount > updatedPosts.length) {
                    _logger.d(
                        'Stats show more posts ($actualPostCount) than loaded (${updatedPosts.length}). Setting hasMorePosts=true',
                        tag: 'ProfileBloc:$requestId');

                    // First update the state to indicate there are more posts
                    emit(state.copyWith(hasMorePosts: true));

                    // Calculate remaining posts to load
                    final remainingCount = actualPostCount - updatedPosts.length;
                    
                    // Always use a small batch size (10) for reliable loading
                    final batchSize = 10;
                    
                    _logger.d('Proactively loading remaining $remainingCount posts with batch size $batchSize',
                        tag: 'ProfileBloc:$requestId');
                    
                    // Don't await this - it will be handled by another event handler
                    // Only trigger this if we have a significant number of posts remaining
                    if (remainingCount > 0) {
                      add(LoadUserPosts(
                        userId: event.userId,
                        offset: updatedPosts.length,
                        limit: batchSize,
                        bypassCache: true,
                      ));
                    }
                  } else if (actualPostCount <= updatedPosts.length) {
                    // If we've loaded all posts according to stats, update the state
                    // to indicate the correct status based on the actual post count
                    _logger.d('We have loaded all $actualPostCount posts according to stats.',
                        tag: 'ProfileBloc:$requestId');
                    
                    // Set hasMorePosts to false when we've loaded all posts according to stats
                    emit(state.copyWith(hasMorePosts: false));
                  }

                  // Update the user stats in the state to ensure UI shows correct counts
                  if (state.stats != null) {
                    final updatedStats = Map<String, int>.from(state.stats!);
                    updatedStats['postsCount'] = actualPostCount;
                    emit(state.copyWith(stats: updatedStats));
                  } else {
                    // Convert to Map<String, int> since that's what the state expects
                    final typedStats = Map<String, int>.from(stats);
                    emit(state.copyWith(stats: typedStats));
                  }
                },
              );
            } catch (e) {
              if (isClosed) return; // Check if bloc is closed before proceeding
              _logger.e('Error checking post count with stats: $e',
                  tag: 'ProfileBloc:$requestId');
            }
          }

          // Log the updated state after all operations
          _logger.d(
              'Final state: postsCount=${state.userPosts?.length}, hasMore=${state.hasMorePosts}',
              tag: 'ProfileBloc:$requestId');
        },
      );
    } catch (e) {
      _logger.e('Exception loading posts: $e', tag: 'ProfileBloc');

      // Determine if this is a timeout exception
      final isTimeout = e.toString().contains('timeout');

      emit(state.copyWith(
        isPostsLoading: false,
        postsError: Failure(
          message: isTimeout
              ? 'Request timed out. Please check your connection and try again.'
              : e.toString(),
        ),
        // If it's a timeout exception and we're paginating, don't change hasMorePosts
        // This allows the user to retry loading more posts
        hasMorePosts:
            isTimeout && event.offset > 0 ? state.hasMorePosts : false,
      ));
    }
  }

  /// Handle the LikeUserPost event
  Future<void> _onLikeUserPost(
    LikeUserPost event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final requestId =
          DateTime.now().millisecondsSinceEpoch.toString().substring(5);
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
        _logger.e('Cannot like post: User ID is null',
            tag: 'ProfileBloc:$requestId');
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
      final requestId =
          DateTime.now().millisecondsSinceEpoch.toString().substring(5);
      _logger.d('Deleting post: ${event.postId}',
          tag: 'ProfileBloc:$requestId');

      // Get the current user ID from state
      final userId = state.profile?.user.id;
      if (userId == null) {
        _logger.e('Cannot delete post: User ID is null',
            tag: 'ProfileBloc:$requestId');
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
          _logger.d('Successfully deleted post', tag: 'ProfileBloc:$requestId');
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
      final requestId =
          DateTime.now().millisecondsSinceEpoch.toString().substring(5);
      _logger.d('Updating post: ${event.postId} with content: ${event.content}',
          tag: 'ProfileBloc:$requestId');

      // Get the current user ID from state
      final userId = state.profile?.user.id;
      if (userId == null) {
        _logger.e('Cannot update post: User ID is null',
            tag: 'ProfileBloc:$requestId');
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
          _logger.e('Post not found for update: ${event.postId}',
              tag: 'ProfileBloc:$requestId');
          emit(state.copyWith(postsError: Failure(message: 'Post not found')));
        }
      } else {
        _logger.e('No posts available for update',
            tag: 'ProfileBloc:$requestId');
        emit(
            state.copyWith(postsError: Failure(message: 'No posts available')));
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
      final requestId =
          DateTime.now().millisecondsSinceEpoch.toString().substring(5);
      _logger.d(
          'Updating post comment status: ${event.postId}, hasUserComment: ${event.hasUserComment}',
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
            commentCount: event.hasUserComment
                ? post.commentCount + 1
                : post.commentCount,
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
      _logger.e('Exception updating post comment status: $e',
          tag: 'ProfileBloc');
      emit(state.copyWith(
        postsError: Failure(message: e.toString()),
      ));
    }
  }

  /// Handle the ClearPostsError event
  void _onClearPostsError(
    ClearPostsError event,
    Emitter<ProfileState> emit,
  ) {
    _logger.d('Clearing posts error state', tag: 'ProfileBloc');
    emit(state.copyWith(clearPostsError: true));
  }

  /// Handle the EnableProfileScrolling event
  /// This event is triggered when a double pull-to-refresh is detected in the posts tab
  void _onEnableProfileScrolling(
    EnableProfileScrolling event,
    Emitter<ProfileState> emit,
  ) {
    _logger.d('Handling EnableProfileScrolling event');
    
    // Set the flag to enable profile scrolling
    emit(state.copyWith(shouldEnableProfileScrolling: true));
    
    // Reset the flag after a short delay to prevent it from persisting
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!isClosed) {
        emit(state.copyWith(shouldEnableProfileScrolling: false));
        _logger.d('Reset shouldEnableProfileScrolling flag');
      }
    });
  }
}
