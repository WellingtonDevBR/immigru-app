import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/core/error/error_handler.dart';
import 'package:immigru/core/logging/logger_interface.dart';
import 'package:immigru/features/home/data/datasources/post_datasource.dart';
import 'package:immigru/features/home/domain/entities/post.dart';
import 'package:immigru/features/home/domain/usecases/create_post_usecase.dart';
import 'package:immigru/features/home/domain/usecases/delete_post_usecase.dart';
import 'package:immigru/features/home/domain/usecases/edit_post_usecase.dart';
import 'package:immigru/features/home/domain/usecases/get_posts_usecase.dart';
import 'package:immigru/features/home/domain/usecases/like_post_usecase.dart';
import 'package:immigru/features/home/presentation/bloc/home_event.dart';
import 'package:immigru/features/home/presentation/bloc/home_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// BLoC for managing home screen state and posts
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetPostsUseCase getPostsUseCase;
  final CreatePostUseCase createPostUseCase;
  final EditPostUseCase editPostUseCase;
  final DeletePostUseCase deletePostUseCase;
  final LikePostUseCase likePostUseCase;
  final LoggerInterface logger;

  // Pagination parameters
  static const int _postsLimit = 10;

  // Instance cache to store all posts - this is our single source of truth
  final List<Post> _allPosts = <Post>[];

  // Set to track all processed post IDs to prevent duplicates
  final Set<String> _processedPostIds = <String>{};

  // Track the last refresh time to efficiently check for new posts
  DateTime _lastRefreshTime = DateTime.now();

  // Reference to PostDataSource for efficient refreshing
  late final PostDataSource _postDataSource;

  // Subscription for real-time updates
  StreamSubscription? _postsSubscription;

  HomeBloc({
    required this.getPostsUseCase,
    required this.createPostUseCase,
    required this.editPostUseCase,
    required this.deletePostUseCase,
    required this.likePostUseCase,
    required this.logger,
    PostDataSource? postDataSource,
  })  : _postDataSource = postDataSource ?? PostDataSource(),
        super(const HomeInitial()) {
    on<FetchPosts>(_onFetchPosts);
    on<FetchMorePosts>(_onFetchMorePosts);
    on<CreatePost>(_onCreatePost);
    on<EditPost>(_onEditPost);
    on<DeletePost>(_onDeletePost);
    on<LikePost>(_onLikePost);
    on<SelectCategory>(_onSelectCategory);
    on<HomeError>(_onHomeError);
    on<InitializeHomeData>(_onInitializeHomeData);
    on<UpdatePostHasUserComment>(_onUpdatePostHasUserComment);
    on<EfficientRefreshPosts>(_onEfficientRefreshPosts);
  }

  /// Handle InitializeHomeData event - initialize all data for the home screen
  Future<void> _onInitializeHomeData(
      InitializeHomeData event, Emitter<HomeState> emit) async {
    // Generate a unique request ID for logging
    final requestId =
        DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    logger.d(
        '[INIT_HOME:$requestId] Initializing home data with category: ${event.category}, userId: ${event.userId}',
        tag: 'HomeBloc');

    try {
      // CRITICAL SAFETY CHECK: Don't proceed with fetching if we don't have a user ID
      // This prevents the issue where posts are fetched without proper filtering
      if (event.userId == null) {
        logger.e(
            '[INIT_HOME:$requestId] ERROR: No user ID provided, cannot initialize home data safely',
            tag: 'HomeBloc');
        emit(PostsError(message: 'Cannot load posts without a user ID'));
        return; // Don't fetch posts without a user ID
      }

      // Check if we're already in a loaded state to prevent duplicate fetches
      if (state is PostsLoaded) {
        final loadedState = state as PostsLoaded;

        // If we already have posts and not forcing a refresh, skip fetching
        if (!event.forceRefresh &&
            loadedState.initialFetchPerformed &&
            loadedState.posts.isNotEmpty) {
          logger.d(
              '[INIT_HOME:$requestId] Posts already loaded (${loadedState.posts.length} posts), skipping fetch',
              tag: 'HomeBloc');
          return;
        }
      }

      // Fetch posts (either initial state or force refresh) using simplified approach
      logger.d(
          '[INIT_HOME:$requestId] Fetching posts with valid userId: ${event.userId}',
          tag: 'HomeBloc');
      add(FetchPosts(
        category: event.category, // Pass category if provided
        currentUserId: event.userId, // Always pass current user ID
        refresh: true,
      ));
    } catch (e) {
      logger.e('[INIT_HOME:$requestId] Error initializing home data: $e',
          tag: 'HomeBloc');
      final failure = ErrorHandler.instance.handleException(
        e,
        tag: 'HomeBloc',
        customMessage: 'Failed to initialize home data',
      );
      emit(PostsError(message: failure.message));
    }
  }

  /// Handle HomeError event - directly emit an error state
  void _onHomeError(HomeError event, Emitter<HomeState> emit) {
    logger.e('HomeError event received: ${event.message}', tag: 'HomeBloc');
    emit(PostsError(message: event.message));
  }

  /// Handle FetchPosts event
  Future<void> _onFetchPosts(
    FetchPosts event,
    Emitter<HomeState> emit,
  ) async {
    try {
      // Emit loading state, preserving current posts if available
      if (state is PostsLoaded && !event.refresh) {
        final currentState = state as PostsLoaded;
        emit(PostsLoading(currentPosts: currentState.posts));
      } else {
        emit(const PostsLoading());
      }

      logger.d('Fetching posts', tag: 'HomeBloc');

      // SIMPLIFIED APPROACH: Always exclude current user's posts
      // This is a hard requirement for the app's design and user experience

      // Optimize refresh behavior for better performance
      if (event.refresh) {
        // Check if we have existing posts that we can update efficiently
        if (_allPosts.isNotEmpty && state is PostsLoaded) {
          final currentState = state as PostsLoaded;
          final currentPosts = List<Post>.from(_allPosts);

          // First emit a loading state with current posts to avoid UI flicker
          emit(PostsLoading(currentPosts: currentPosts));

          try {
            // Try to update like and comment counts for existing posts
            // This is more efficient than a full refresh
            final updatedPosts = await _postDataSource.updatePostCounts(
              posts: currentPosts,
              currentUserId: event.currentUserId ?? '',
            );

            // Update the last refresh time
            _lastRefreshTime = DateTime.now();

            // Update our cache with the updated posts
            _allPosts.clear();
            _allPosts.addAll(updatedPosts);
            _processedPostIds.clear();
            for (final post in updatedPosts) {
              _processedPostIds.add(post.id);
            }

            // Emit updated state with the same posts but updated counts
            emit(PostsLoaded(
              posts: updatedPosts,
              hasReachedMax: currentState.hasReachedMax,
              initialFetchPerformed: true,
              isLoadingMore: false,
            ));

            logger.d(
                'Efficiently updated like and comment counts for ${updatedPosts.length} posts',
                tag: 'HomeBloc');

            // Return early since we've handled the refresh efficiently
            return;
          } catch (e) {
            // If the efficient update fails, fall back to a full refresh
            logger.e(
                'Error during efficient update: $e, falling back to full refresh',
                tag: 'HomeBloc');
          }
        }

        // If we can't do an efficient update or it failed, do a full refresh
        final oldPosts = List<Post>.from(_allPosts);
        _processedPostIds.clear();
        _allPosts.clear();

        // Emit an optimistic loading state that preserves the current posts
        // This prevents the UI from showing a blank screen during refresh
        if (oldPosts.isNotEmpty) {
          emit(PostsLoading(currentPosts: oldPosts));
        }

        logger.d(
            'Performing full refresh with ${oldPosts.length} preserved posts',
            tag: 'HomeBloc');
      }

      // Add a unique request ID to help track and debug duplicate post issues
      final requestId = DateTime.now().millisecondsSinceEpoch.toString();
      logger.d('Post fetch request ID: $requestId', tag: 'HomeBloc');

      // SIMPLIFIED APPROACH: Get posts from the repository
      // The key is to always pass the currentUserId to ensure proper filtering
      final result = await Future.any([
        getPostsUseCase(
          // Only pass parameters that are actually needed and used
          category: event.category, // Pass category if provided
          currentUserId:
              event.currentUserId, // CRITICAL: Always pass current user ID
          excludeCurrentUser: true, // Always exclude current user's posts
          limit: _postsLimit,
          offset: 0,
          bypassCache: event.bypassCache, // Use bypassCache parameter to ensure fresh data
        ),
        Future.delayed(const Duration(seconds: 10), () {
          throw Exception('Request timed out after 10 seconds');
        }),
      ]);

      // Check if the widget is still mounted by verifying we can emit a state
      // This is a safety check to prevent emitting after the bloc is closed
      result.fold(
        (failure) {
          logger.e('Error fetching posts: ${failure.message}', tag: 'HomeBloc');
          emit(PostsError(message: failure.message));
        },
        (posts) {
          // Generate a unique request ID for logging
          final requestId =
              DateTime.now().millisecondsSinceEpoch.toString().substring(7);
          logger.d('[FETCH_POSTS:$requestId] Fetched ${posts.length} posts',
              tag: 'HomeBloc');

          // Log the first few post IDs to help identify duplicates
          if (posts.isNotEmpty) {
            final postIds = posts.take(3).map((p) => p.id).join(', ');
            logger.d('[FETCH_POSTS:$requestId] Sample post IDs: $postIds',
                tag: 'HomeBloc');
          }

          // Comprehensive deduplication to prevent duplicates
          // 1. First deduplicate within this batch
          final Map<String, Post> uniquePostsMap = {};

          for (final post in posts) {
            uniquePostsMap[post.id] = post;
          }

          // 2. For refresh, we already cleared the processed IDs set, so we can just use all posts
          // For non-refresh, we still want to filter out duplicates
          final List<Post> newUniquePosts = [];

          if (event.refresh) {
            // For refresh, use all posts from this batch
            newUniquePosts.addAll(uniquePostsMap.values);

            // Update the processed IDs set with these posts
            for (final post in newUniquePosts) {
              _processedPostIds.add(post.id);
            }
          } else {
            // For non-refresh, filter out posts we've already seen
            for (final post in uniquePostsMap.values) {
              // Skip posts we've already seen
              if (_processedPostIds.contains(post.id)) {
                logger.d(
                    '[FETCH_POSTS:$requestId] Filtered out already processed post: ${post.id}',
                    tag: 'HomeBloc');
                continue;
              }

              // Add to our tracking set and the result list
              _processedPostIds.add(post.id);
              newUniquePosts.add(post);
            }
          }

          // Log deduplication results
          if (posts.length != newUniquePosts.length) {
            logger.w(
                '[FETCH_POSTS:$requestId] Removed ${posts.length - newUniquePosts.length} duplicate posts',
                tag: 'HomeBloc');
          }

          // 3. Update our static cache with the deduplicated posts
          // For a refresh, replace the entire list; for pagination, append
          if (event.refresh) {
            _allPosts.clear();
            _allPosts.addAll(newUniquePosts);
          } else {
            _allPosts.addAll(newUniquePosts);
          }

          // Sort by creation date (newest first)
          _allPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          // Use the cached posts as our source of truth
          final finalPosts = List<Post>.from(_allPosts);

          // Create the loaded state with simplified parameters
          // Add initialFetchPerformed flag to track if posts have been fetched
          // This helps prevent duplicate fetches between HomeScreen and AllPostsTab
          final loadedState = PostsLoaded(
            posts: finalPosts,
            hasReachedMax: newUniquePosts.length < _postsLimit,
            currentUserId: event.currentUserId,
            isLoadingMore: false,
            initialFetchPerformed:
                true, // Mark that initial fetch has been performed
          );

          emit(loadedState);
        },
      );
    } catch (e) {
      logger.e('Error fetching posts: $e', tag: 'HomeBloc');
      emit(PostsError(message: 'Failed to fetch posts: $e'));
    }
  }

  /// Handle FetchMorePosts event (pagination)
  Future<void> _onFetchMorePosts(
    FetchMorePosts event,
    Emitter<HomeState> emit,
  ) async {
    try {
      // Only proceed if we're in a loaded state and haven't reached max posts
      if (state is PostsLoaded) {
        final currentState = state as PostsLoaded;

        // Check if we've already reached the maximum number of posts
        if (currentState.hasReachedMax) {
          logger.d('Already reached maximum posts, skipping fetch',
              tag: 'HomeBloc');
          return;
        }

        // Update state to indicate we're loading more posts
        emit(currentState.copyWith(isLoadingMore: true));

        // Get the current offset based on the number of posts we already have
        final offset = currentState.posts.length;

        // Get more posts from the repository using the simplified approach
        final result = await getPostsUseCase(
          // Only pass parameters that are actually needed and used
          category: event.category, // Pass category if provided
          currentUserId:
              event.currentUserId, // CRITICAL: Always pass current user ID
          excludeCurrentUser: true, // Always exclude current user's posts
          limit: _postsLimit,
          offset: offset,
        );

        result.fold(
          (failure) {
            logger.e('Error fetching more posts: ${failure.message}',
                tag: 'HomeBloc');
            // Restore previous state but turn off loading indicator
            emit(currentState.copyWith(isLoadingMore: false));
          },
          (newPosts) {
            logger.d('Fetched ${newPosts.length} more posts', tag: 'HomeBloc');

            // Comprehensive deduplication to prevent duplicates
            // 1. First deduplicate within this batch
            final Map<String, Post> uniquePostsMap = {};

            for (final post in newPosts) {
              uniquePostsMap[post.id] = post;
            }

            // 2. For pagination, we only want to filter out posts that are already in the current list
            final List<Post> newUniquePosts = [];
            final Set<String> currentPostIds =
                currentState.posts.map((p) => p.id).toSet();

            for (final post in uniquePostsMap.values) {
              // Skip posts we've already seen in the current list
              if (currentPostIds.contains(post.id)) {
                logger.d('Skipping duplicate post in pagination: ${post.id}',
                    tag: 'HomeBloc');
                continue;
              }

              // Add to our tracking set and the result list
              _processedPostIds.add(post.id);
              newUniquePosts.add(post);
            }

            // 3. Update our static cache with the deduplicated posts
            // Append the new posts to our cache
            _allPosts.addAll(newUniquePosts);

            // Sort by creation date (newest first)
            _allPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            // Use the cached posts as our source of truth
            final finalPosts = List<Post>.from(_allPosts);

            // Emit new state with updated posts and hasReachedMax flag
            emit(PostsLoaded(
              posts: finalPosts,
              hasReachedMax: newUniquePosts.length < _postsLimit,
              currentUserId: currentState.currentUserId,
              initialFetchPerformed: currentState.initialFetchPerformed,
              isLoadingMore: false,
            ));
          },
        );
      }
    } catch (e) {
      logger.e('Error fetching more posts: $e', tag: 'HomeBloc');
      // If we're in a loaded state, restore it but turn off loading indicator
      if (state is PostsLoaded) {
        final currentState = state as PostsLoaded;
        emit(currentState.copyWith(isLoadingMore: false));
      } else {
        final failure = ErrorHandler.instance.handleException(
          e,
          tag: 'HomeBloc',
          customMessage: 'Failed to fetch more posts',
        );
        emit(PostsError(message: failure.message));
      }
    }
  }

  /// Handle CreatePost event
  Future<void> _onCreatePost(
    CreatePost event,
    Emitter<HomeState> emit,
  ) async {
    try {
      logger.d('Creating post with content: ${event.content}', tag: 'HomeBloc');

      // Create the post with default category
      final result = await createPostUseCase(
        content: event.content,
        userId: event.userId,
        category: 'General', // Use a default category
      );

      result.fold(
        (failure) {
          logger.e('Error creating post: ${failure.message}', tag: 'HomeBloc');
          emit(PostCreationError(message: failure.message));
        },
        (post) {
          logger.i('Post created successfully', tag: 'HomeBloc');

          // Add the new post to our cache
          _processedPostIds.add(post.id);

          // Add to the beginning of the list (newest first)
          _allPosts.insert(0, post);

          // Emit success state
          emit(PostCreated(post: post));

          // Refresh posts to ensure UI is updated
          add(FetchPosts(
            category: null, // No category filtering
            currentUserId: event.userId,
            refresh: true,
          ));
        },
      );
    } catch (e) {
      logger.e('Error creating post: $e', tag: 'HomeBloc');
      final failure = ErrorHandler.instance.handleException(
        e,
        tag: 'HomeBloc',
        customMessage: 'Failed to create post',
      );
      emit(PostCreationError(message: failure.message));
    }
  }

  /// Handle EditPost event
  Future<void> _onEditPost(
    EditPost event,
    Emitter<HomeState> emit,
  ) async {
    try {
      // Get the current state
      final currentState = state;

      // Emit loading state
      emit(const PostsLoading());

      // Edit the post
      final result = await editPostUseCase(
        postId: event.postId,
        userId: event.userId,
        content: event.content,
        category: event.category,
        // We don't pass media since it's not in the event definition
        // The use case will handle this internally
      );

      // Handle the result
      result.fold(
        (failure) {
          logger.e('Failed to edit post: ${failure.message}', tag: 'HomeBloc');
          emit(PostsError(message: failure.message));
        },
        (post) {
          logger.i('Post edited successfully', tag: 'HomeBloc');
          // Restore the previous state and update the edited post
          if (currentState is PostsLoaded) {
            // Update the post in the list
            final updatedPosts = currentState.posts.map((p) {
              if (p.id == post.id) {
                return post; // Replace with the updated post
              }
              return p;
            }).toList();

            emit(PostsLoaded(
              posts: updatedPosts,
              hasReachedMax: currentState.hasReachedMax,
              currentUserId: currentState.currentUserId,
              initialFetchPerformed: currentState.initialFetchPerformed,
              isLoadingMore: currentState.isLoadingMore,
            ));
          } else {
            emit(currentState);
          }
        },
      );
    } catch (e) {
      logger.e('Error editing post: $e', tag: 'HomeBloc');
      final failure = ErrorHandler.instance.handleException(
        e,
        tag: 'HomeBloc',
        customMessage: 'Failed to edit post',
      );
      emit(PostsError(message: failure.message));
    }
  }

  /// Handle LikePost event - like or unlike a post
  Future<void> _onLikePost(
    LikePost event,
    Emitter<HomeState> emit,
  ) async {
    try {
      logger.d('${event.like ? "Liking" : "Unliking"} post: ${event.postId}',
          tag: 'HomeBloc');

      // Get the current state
      final currentState = state;
      if (currentState is! PostsLoaded) {
        logger.w('Cannot like post: Invalid state', tag: 'HomeBloc');
        return;
      }

      // Find the post to like/unlike
      final postIndex = _allPosts.indexWhere((post) => post.id == event.postId);
      if (postIndex == -1) {
        logger.w('Post not found: ${event.postId}', tag: 'HomeBloc');
        return;
      }

      // Get the post and create an optimistically updated version
      final post = _allPosts[postIndex];

      // Only update if the action changes the current state
      if (post.isLiked == event.like) {
        logger.d('Post is already in the desired like state', tag: 'HomeBloc');
        return;
      }

      // Create updated post with new like status and count
      final updatedPost = Post(
        id: post.id,
        userId: post.userId,
        userName: post.userName,
        userAvatar: post.userAvatar,
        content: post.content,
        imageUrl: post.imageUrl,
        category: post.category,
        createdAt: post.createdAt,
        likeCount:
            event.like ? post.likeCount + 1 : math.max(0, post.likeCount - 1),
        commentCount: post.commentCount,
        isLiked: event.like,
        location: post.location,
        author: post.author,
        hasUserComment: post.hasUserComment,
      );

      // Update the posts list optimistically
      final updatedPosts = List<Post>.from(_allPosts);
      updatedPosts[postIndex] = updatedPost;
      _allPosts[postIndex] = updatedPost;

      // Emit the updated state
      emit(PostsLoaded(
        posts: updatedPosts,
        hasReachedMax: currentState.hasReachedMax,
        currentUserId: currentState.currentUserId,
        isLoadingMore: currentState.isLoadingMore,
        initialFetchPerformed: currentState.initialFetchPerformed,
      ));

      // Call the use case to like/unlike the post
      final params = LikePostParams(
        postId: event.postId,
        userId: event.userId,
        like: event.like,
      );
      final result = await likePostUseCase.call(params);

      // Handle the result
      result.fold(
        (failure) {
          // Revert the optimistic update on failure
          logger.e(
              'Failed to ${event.like ? "like" : "unlike"} post: ${failure.message}',
              tag: 'HomeBloc');

          // Restore the original post
          final revertedPosts = List<Post>.from(_allPosts);
          revertedPosts[postIndex] = post;
          _allPosts[postIndex] = post;

          emit(PostsLoaded(
            posts: revertedPosts,
            hasReachedMax: currentState.hasReachedMax,
            currentUserId: currentState.currentUserId,
            isLoadingMore: currentState.isLoadingMore,
            initialFetchPerformed: currentState.initialFetchPerformed,
          ));
        },
        (success) {
          logger.d('Post ${event.like ? "liked" : "unliked"} successfully',
              tag: 'HomeBloc');
          
          // After successful like/unlike, we don't need to refresh the entire feed
          // The optimistic update we did earlier is sufficient
          logger.d('Like/unlike action completed successfully', tag: 'HomeBloc');
          _lastRefreshTime = DateTime.now();
          
          // The post is already updated in the UI due to our optimistic update
          // No need to trigger a full refresh which would be inefficient
        },
      );
    } catch (e) {
      logger.e('Error ${event.like ? "liking" : "unliking"} post: $e',
          tag: 'HomeBloc');
      // Don't emit error state here as we've already done an optimistic update
      // Just log the error for debugging purposes
    }
  }

  /// Handle DeletePost event
  Future<void> _onDeletePost(
    DeletePost event,
    Emitter<HomeState> emit,
  ) async {
    try {
      // Get the current state
      final currentState = state;

      // Emit loading state
      emit(const PostsLoading());

      // Get current user ID from Supabase for security
      final supabase = Supabase.instance.client;
      final currentUserId = supabase.auth.currentUser?.id;

      if (currentUserId == null) {
        logger.e('Failed to delete post: No authenticated user',
            tag: 'HomeBloc');
        emit(PostsError(message: 'You must be logged in to delete a post'));
        return;
      }

      // Delete the post
      final result = await deletePostUseCase.call(
        postId: event.postId,
        userId: currentUserId,
      );

      // Handle the result
      result.fold(
        (failure) {
          logger.e('Failed to delete post: ${failure.message}',
              tag: 'HomeBloc');
          emit(PostsError(message: failure.message));
        },
        (success) {
          logger.i('Post deleted successfully', tag: 'HomeBloc');
          // Restore the previous state and remove the deleted post
          if (currentState is PostsLoaded) {
            // Remove the deleted post from the list
            final updatedPosts = currentState.posts
                .where((post) => post.id != event.postId)
                .toList();

            emit(PostsLoaded(
              posts: updatedPosts,
              hasReachedMax: currentState.hasReachedMax,
              currentUserId: currentState.currentUserId,
              initialFetchPerformed: currentState.initialFetchPerformed,
              isLoadingMore: currentState.isLoadingMore,
            ));
          } else {
            emit(currentState);
          }
        },
      );
    } catch (e) {
      logger.e('Error deleting post: $e', tag: 'HomeBloc');
      final failure = ErrorHandler.instance.handleException(
        e,
        tag: 'HomeBloc',
        customMessage: 'Failed to delete post',
      );
      emit(PostsError(message: failure.message));
    }
  }

  /// Handle UpdatePostHasUserComment event
  Future<void> _onUpdatePostHasUserComment(
    UpdatePostHasUserComment event,
    Emitter<HomeState> emit,
  ) async {
    try {
      // Get the current state
      final currentState = state;

      // Only proceed if we have posts loaded
      if (currentState is PostsLoaded) {
        // Find the post and update its hasUserComment flag
        final updatedPosts = currentState.posts.map((post) {
          if (post.id == event.postId) {
            // Create a copy of the post with updated hasUserComment flag
            return post.copyWith(hasUserComment: event.hasUserComment);
          }
          return post;
        }).toList();

        // Emit updated state
        emit(PostsLoaded(
          posts: updatedPosts,
          hasReachedMax: currentState.hasReachedMax,
          currentUserId: currentState.currentUserId,
          initialFetchPerformed: currentState.initialFetchPerformed,
          isLoadingMore: currentState.isLoadingMore,
        ));
        
        // After updating the comment flag, schedule a refresh to update all posts
        // This ensures that other users' interactions are also reflected
        logger.d('Scheduling refresh after comment update', tag: 'HomeBloc');
        _lastRefreshTime = DateTime.now();
        
        // Only refresh if we have a current user ID to avoid errors
        if (currentState.currentUserId != null && currentState.currentUserId!.isNotEmpty) {
          // Use a small delay to ensure the UI updates first
          Future.delayed(const Duration(milliseconds: 300), () {
            // Add a new event to the bloc to refresh posts
            // This is safer than trying to emit states directly
            if (!isClosed) {
              add(FetchPosts(
                refresh: true,
                currentUserId: currentState.currentUserId,
                bypassCache: true,
              ));
              logger.d('Scheduled refresh after comment update', tag: 'HomeBloc');
            }
          });
        }

        logger.d(
            'Updated hasUserComment flag for post ${event.postId} to ${event.hasUserComment}',
            tag: 'HomeBloc');
      }
    } catch (e) {
      logger.e('Error updating post hasUserComment flag: $e', tag: 'HomeBloc');
      // Don't emit error state to avoid disrupting the UI
    }
  }

  /// Handle SelectCategory event - simplified to just refresh posts
  Future<void> _onSelectCategory(
    SelectCategory event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final String selectedCategory = event.category;
      logger.d('Category selected: $selectedCategory', tag: 'HomeBloc');

      // For any state, just trigger a fetch with the new category
      // This is a simplified approach that doesn't rely on tracking the selected category
      logger.d('Triggering fetch for category: $selectedCategory',
          tag: 'HomeBloc');
      add(FetchPosts(category: selectedCategory, refresh: true));
    } catch (e) {
      logger.e('Error selecting category: $e', tag: 'HomeBloc');
      emit(PostsError(message: 'Failed to select category: $e'));
    }
  }

  /// Handle efficient post refreshing
  /// This method checks for new posts and updates like/comment counts without a full refresh
  Future<void> _onEfficientRefreshPosts(
    EfficientRefreshPosts event,
    Emitter<HomeState> emit,
  ) async {
    // Extract currentUserId at the beginning to use throughout the method
    final String currentUserId = event.currentUserId ?? '';  // Use empty string as fallback
    
    try {
      logger.d('Efficiently refreshing posts', tag: 'HomeBloc');
      
      // Ensure we have a current user ID
      if (currentUserId.isEmpty) {
        logger.w('No current user ID provided for refresh', tag: 'HomeBloc');
        return;
      }

      // Only proceed if we're in a loaded state with posts
      if (state is! PostsLoaded) {
        logger.d('Not in a loaded state, performing full refresh', tag: 'HomeBloc');
      } else {
        final currentState = state as PostsLoaded;
        final currentPosts = currentState.posts;
        
        // Show loading state with current posts to avoid UI flicker
        if (currentPosts.isNotEmpty) {
          emit(PostsLoading(currentPosts: currentPosts));
        }
      }
      
      // Always perform a full refresh with cache bypass to ensure we get the latest data
      // This is the most reliable way to ensure we see updates from other users
      logger.d('Performing full refresh with cache bypass', tag: 'HomeBloc');
      
      // Update the refresh time
      _lastRefreshTime = DateTime.now();
      logger.d('Updated refresh time to: ${_lastRefreshTime.toIso8601String()}', tag: 'HomeBloc');
      
      // Directly fetch fresh posts from the repository with cache bypass
      final result = await getPostsUseCase.call(
        filter: 'all',
        category: event.category,
        currentUserId: currentUserId,
        bypassCache: true,  // Force bypass cache to get fresh data
        excludeCurrentUser: event.excludeCurrentUser,  // Explicitly exclude current user's posts
      );
      
      // Handle the result
      result.fold(
        (failure) {
          logger.e('Failed to refresh posts: ${failure.message}', tag: 'HomeBloc');
          // If we're in a loaded state, keep showing the current posts
          if (state is! PostsLoaded) {
            emit(HomeInitial()); // Reset to initial state on error if not already loaded
          }
        },
        (posts) {
          logger.d('Successfully refreshed ${posts.length} posts with fresh data', tag: 'HomeBloc');
          emit(PostsLoaded(
            posts: posts,
            hasReachedMax: posts.length < 10, // Assume we've reached max if fewer than expected posts
            initialFetchPerformed: true,
            isLoadingMore: false,
          ));
        },
      );
    } catch (e) {
      logger.e('Error during efficient refresh: $e', tag: 'HomeBloc');
      
      // If we're in a loaded state, keep showing the current posts
      if (state is! PostsLoaded) {
        emit(HomeInitial()); // Reset to initial state on error if not already loaded
      }
    }
  }

  /// Clean up resources when the bloc is closed
  @override
  Future<void> close() async {
    // Cancel any active subscriptions
    _postsSubscription?.cancel();

    // Clear cached data to prevent memory leaks
    _allPosts.clear();
    _processedPostIds.clear();

    logger.d('HomeBloc resources cleaned up', tag: 'HomeBloc');

    // Call the parent close method
    return super.close();
  }
}
