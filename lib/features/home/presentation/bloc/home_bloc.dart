import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/home/domain/usecases/create_post_usecase.dart';
import 'package:immigru/features/home/domain/usecases/get_events_usecase.dart';
import 'package:immigru/features/home/domain/usecases/get_personalized_posts_usecase.dart';
import 'package:immigru/features/home/domain/usecases/get_posts_usecase.dart';
import 'package:immigru/features/home/presentation/bloc/home_event.dart';
import 'package:immigru/features/home/presentation/bloc/home_state.dart';
import 'package:immigru/new_core/logging/logger_interface.dart';

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
  }

  /// Handle FetchPosts event
  Future<void> _onFetchPosts(
    FetchPosts event,
    Emitter<HomeState> emit,
  ) async {
    try {
      // If refreshing, show loading state but keep current posts
      if (event.refresh) {
        final currentState = state;
        if (currentState is PostsLoaded) {
          emit(PostsLoading(
            currentPosts: currentState.posts,
            isRefreshing: true,
          ));
        } else {
          emit(const PostsLoading(isRefreshing: true));
        }
      } else {
        emit(const PostsLoading());
      }

      final result = await getPostsUseCase(
        category: event.category,
        limit: _postsLimit,
        offset: 0,
      );

      result.fold(
        (failure) => emit(PostsError(message: failure.message)),
        (posts) => emit(PostsLoaded(
          posts: posts,
          hasReachedMax: posts.length < _postsLimit,
          selectedCategory: event.category,
        )),
      );
    } catch (e) {
      logger.e('Error fetching posts: $e', tag: 'HomeBloc');
      emit(PostsError(message: e.toString()));
    }
  }

  /// Handle FetchMorePosts event (pagination)
  Future<void> _onFetchMorePosts(
    FetchMorePosts event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is PostsLoaded && !currentState.hasReachedMax) {
        final result = await getPostsUseCase(
          category: currentState.selectedCategory,
          limit: _postsLimit,
          offset: currentState.posts.length,
        );

        result.fold(
          (failure) => emit(PostsError(message: failure.message)),
          (newPosts) => emit(currentState.copyWith(
            posts: [...currentState.posts, ...newPosts],
            hasReachedMax: newPosts.length < _postsLimit,
          )),
        );
      }
    } catch (e) {
      logger.e('Error fetching more posts: $e', tag: 'HomeBloc');
      // Don't emit error state for pagination to preserve current posts
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
      if (currentState is PersonalizedPostsLoaded && !currentState.hasReachedMax) {
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
  void _onSelectCategory(
    SelectCategory event,
    Emitter<HomeState> emit,
  ) {
    add(FetchPosts(category: event.category, refresh: true));
  }
}
