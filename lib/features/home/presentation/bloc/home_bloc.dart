import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/home/domain/usecases/create_post_usecase.dart';
import 'package:immigru/features/home/domain/usecases/get_events_usecase.dart';
import 'package:immigru/features/home/domain/usecases/get_personalized_posts_usecase.dart';
import 'package:immigru/features/home/domain/usecases/get_posts_usecase.dart';
import 'package:immigru/features/home/presentation/bloc/home_event.dart';
import 'package:immigru/features/home/presentation/bloc/home_state.dart';
import 'package:immigru/core/logging/logger_interface.dart';

/// BLoC for the home screen
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetPostsUseCase getPostsUseCase;
  final GetPersonalizedPostsUseCase getPersonalizedPostsUseCase;
  final GetEventsUseCase getEventsUseCase;
  final CreatePostUseCase createPostUseCase;
  final LoggerInterface logger;

  // Pagination parameters
  static const int _postsLimit = 10;
  static const int _eventsLimit = 5;

  HomeBloc({
    required this.getPostsUseCase,
    required this.getPersonalizedPostsUseCase,
    required this.getEventsUseCase,
    required this.createPostUseCase,
    required this.logger,
  }) : super(const HomeInitial()) {
    on<FetchPosts>(_onFetchPosts);
    on<FetchMorePosts>(_onFetchMorePosts);
    on<FetchPersonalizedPosts>(_onFetchPersonalizedPosts);
    on<FetchMorePersonalizedPosts>(_onFetchMorePersonalizedPosts);
    on<FetchEvents>(_onFetchEvents);
    on<FetchMoreEvents>(_onFetchMoreEvents);
    on<CreatePost>(_onCreatePost);
    on<SelectCategory>(_onSelectCategory);
    on<HomeError>(_onHomeError);
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
      logger.d('Fetching posts with category: ${event.category}',
          tag: 'HomeBloc');

      // If refreshing, show loading state but keep current posts
      if (event.refresh) {
        final currentState = state;
        if (currentState is PostsLoaded) {
          // Emit a loaded state with isLoadingMore flag to show a loading indicator
          // while preserving the current posts for a smoother UX
          emit(currentState.copyWith(
            isLoadingMore: true,
          ));
        } else {
          emit(const PostsLoading(isRefreshing: true));
        }
      } else {
        emit(const PostsLoading());
      }

      // Use a default category if none is provided
      final category = event.category ?? 'All';

      // Add a timeout to the API call to prevent UI freezing
      final result = await Future.any([
        getPostsUseCase(
          category: category,
          limit: _postsLimit,
          offset: 0,
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
          logger.d('Fetched ${posts.length} posts', tag: 'HomeBloc');
          
          // Create the loaded state
          final loadedState = PostsLoaded(
            posts: posts,
            hasReachedMax: posts.length < _postsLimit,
            selectedCategory: category,
            isLoadingMore: false,
          );
          
          // Emit the loaded state - no need for additional HomeNavigationReady state
          emit(loadedState);
        },
      );
    } catch (e) {
      logger.e('Error fetching posts: $e', tag: 'HomeBloc');

      // If we're in a loaded state, preserve it but turn off loading indicator
      final currentState = state;
      if (currentState is PostsLoaded) {
        emit(currentState.copyWith(
          isLoadingMore: false,
        ));
      } else {
        // Otherwise emit an error state
        emit(PostsError(message: e.toString()));
      }
      
      // No need to emit HomeNavigationReady state - it's causing infinite loops
    }
  }

  /// Handle FetchMorePosts event (pagination)
  Future<void> _onFetchMorePosts(
    FetchMorePosts event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final currentState = state;

      // More comprehensive state checking
      if (currentState is! PostsLoaded) {
        logger.d('Not in a loaded state, ignoring fetch more posts',
            tag: 'HomeBloc');
        return;
      }

      // Check if we've already reached max
      if (currentState.hasReachedMax) {
        logger.d('Already reached max posts, ignoring fetch more',
            tag: 'HomeBloc');
        return;
      }

      // Emit a loading indicator state while preserving current posts
      emit(PostsLoaded(
        posts: currentState.posts,
        hasReachedMax: false,
        selectedCategory: currentState.selectedCategory,
        isLoadingMore: true, // Add this flag to the state
      ));

      // Fetch more posts with proper offset
      final result = await getPostsUseCase(
        category: currentState.selectedCategory,
        limit: _postsLimit,
        offset: currentState.posts.length,
      );

      result.fold(
        (failure) {
          logger.e('Error fetching more posts: ${failure.message}',
              tag: 'HomeBloc');
          // Emit the current state again but with loading more set to false
          emit(currentState.copyWith(
            isLoadingMore: false,
          ));
        },
        (newPosts) {
          // Check if we got any new posts
          if (newPosts.isEmpty) {
            logger.d('No more posts available', tag: 'HomeBloc');
            emit(currentState.copyWith(
              hasReachedMax: true,
              isLoadingMore: false,
            ));
            return;
          }

          // Emit new state with combined posts
          emit(PostsLoaded(
            posts: [...currentState.posts, ...newPosts],
            hasReachedMax: newPosts.length < _postsLimit,
            selectedCategory: currentState.selectedCategory,
            isLoadingMore: false,
          ));
        },
      );
    } catch (e) {
      logger.e('Error fetching more posts: $e', tag: 'HomeBloc');
      // Don't emit error state for pagination to preserve current posts
      // But we should reset the loading state if we're in a loaded state
      final currentState = state;
      if (currentState is PostsLoaded) {
        emit(currentState.copyWith(
          isLoadingMore: false,
        ));
      }
    }
  }

  /// Handle FetchPersonalizedPosts event
  Future<void> _onFetchPersonalizedPosts(
    FetchPersonalizedPosts event,
    Emitter<HomeState> emit,
  ) async {
    try {
      // If refreshing, show loading state but keep current posts
      if (event.refresh) {
        final currentState = state;
        if (currentState is PersonalizedPostsLoaded) {
          emit(PersonalizedPostsLoading(
            currentPosts: currentState.posts,
            isRefreshing: true,
          ));
        } else {
          emit(const PersonalizedPostsLoading(isRefreshing: true));
        }
      } else {
        emit(const PersonalizedPostsLoading());
      }

      final result = await getPersonalizedPostsUseCase(
        userId: event.userId,
        limit: _postsLimit,
        offset: 0,
      );

      result.fold(
        (failure) => emit(PersonalizedPostsError(message: failure.message)),
        (posts) => emit(PersonalizedPostsLoaded(
          posts: posts,
          hasReachedMax: posts.length < _postsLimit,
        )),
      );
    } catch (e) {
      logger.e('Error fetching personalized posts: $e', tag: 'HomeBloc');
      emit(PersonalizedPostsError(message: e.toString()));
    }
  }

  /// Handle FetchMorePersonalizedPosts event (pagination)
  Future<void> _onFetchMorePersonalizedPosts(
    FetchMorePersonalizedPosts event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is PersonalizedPostsLoaded &&
          !currentState.hasReachedMax) {
        final result = await getPersonalizedPostsUseCase(
          userId: event.userId,
          limit: _postsLimit,
          offset: currentState.posts.length,
        );

        result.fold(
          (failure) => emit(PersonalizedPostsError(message: failure.message)),
          (newPosts) => emit(currentState.copyWith(
            posts: [...currentState.posts, ...newPosts],
            hasReachedMax: newPosts.length < _postsLimit,
          )),
        );
      }
    } catch (e) {
      logger.e('Error fetching more personalized posts: $e', tag: 'HomeBloc');
      // Don't emit error state for pagination to preserve current posts
    }
  }

  /// Handle FetchEvents event
  Future<void> _onFetchEvents(
    FetchEvents event,
    Emitter<HomeState> emit,
  ) async {
    try {
      // If refreshing, show loading state but keep current events
      if (event.refresh) {
        final currentState = state;
        if (currentState is EventsLoaded) {
          emit(EventsLoading(
            currentEvents: currentState.events,
            isRefreshing: true,
          ));
        } else {
          emit(const EventsLoading(isRefreshing: true));
        }
      } else {
        emit(const EventsLoading());
      }

      final result = await getEventsUseCase(
        upcoming: event.upcoming,
        limit: _eventsLimit,
        offset: 0,
      );

      result.fold(
        (failure) => emit(EventsError(message: failure.message)),
        (events) => emit(EventsLoaded(
          events: events,
          hasReachedMax: events.length < _eventsLimit,
        )),
      );
    } catch (e) {
      logger.e('Error fetching events: $e', tag: 'HomeBloc');
      emit(EventsError(message: e.toString()));
    }
  }

  /// Handle FetchMoreEvents event (pagination)
  Future<void> _onFetchMoreEvents(
    FetchMoreEvents event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is EventsLoaded && !currentState.hasReachedMax) {
        final result = await getEventsUseCase(
          upcoming: event.upcoming,
          limit: _eventsLimit,
          offset: currentState.events.length,
        );

        result.fold(
          (failure) => emit(EventsError(message: failure.message)),
          (newEvents) => emit(currentState.copyWith(
            events: [...currentState.events, ...newEvents],
            hasReachedMax: newEvents.length < _eventsLimit,
          )),
        );
      }
    } catch (e) {
      logger.e('Error fetching more events: $e', tag: 'HomeBloc');
      // Don't emit error state for pagination to preserve current events
    }
  }

  /// Handle CreatePost event
  Future<void> _onCreatePost(
    CreatePost event,
    Emitter<HomeState> emit,
  ) async {
    try {
      emit(const PostCreating());

      final result = await createPostUseCase(
        content: event.content,
        userId: event.userId,
        category: event.category,
        imageUrl: event.imageUrl,
      );

      result.fold(
        (failure) => emit(PostCreationError(message: failure.message)),
        (post) => emit(PostCreated(post: post)),
      );
    } catch (e) {
      logger.e('Error creating post: $e', tag: 'HomeBloc');
      emit(PostCreationError(message: e.toString()));
    }
  }

  /// Handle SelectCategory event
  Future<void> _onSelectCategory(
    SelectCategory event,
    Emitter<HomeState> emit,
  ) async {
    try {
      // Get current state to preserve existing data during transition
      final currentState = state;
      String selectedCategory = event.category;

      // If we're already in a loaded state, update the category and show loading with current posts
      if (currentState is PostsLoaded) {
        // Only emit if category actually changed
        if (currentState.selectedCategory != selectedCategory) {
          logger.d(
              'Category changed from ${currentState.selectedCategory} to $selectedCategory',
              tag: 'HomeBloc');

          // Emit loading state but preserve current posts for smoother UX
          emit(PostsLoading(
            currentPosts: currentState.posts,
            isRefreshing: true,
          ));

          // Fetch posts with the new category
          final result = await getPostsUseCase(
            category: selectedCategory,
            limit: _postsLimit,
            offset: 0,
          );

          result.fold(
            (failure) => emit(PostsError(message: failure.message)),
            (posts) => emit(PostsLoaded(
              posts: posts,
              hasReachedMax: posts.length < _postsLimit,
              selectedCategory: selectedCategory,
            )),
          );
        } else {
          logger.d('Category unchanged, skipping fetch', tag: 'HomeBloc');
        }
      } else {
        // For other states, just trigger a fetch with the new category
        logger.d(
            'Triggering fetch for category: $selectedCategory from non-loaded state',
            tag: 'HomeBloc');
        add(FetchPosts(category: selectedCategory, refresh: true));
      }
    } catch (e) {
      logger.e('Error handling category selection: $e', tag: 'HomeBloc');
      // Don't emit error state here to avoid disrupting the UI
    }
  }
}
