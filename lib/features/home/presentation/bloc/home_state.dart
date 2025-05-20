import 'package:equatable/equatable.dart';
import 'package:immigru/features/home/domain/entities/event.dart';
import 'package:immigru/features/home/domain/entities/post.dart';

/// States for the home screen
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class HomeInitial extends HomeState {
  const HomeInitial();
}

/// Loading state for posts
class PostsLoading extends HomeState {
  final List<Post>? currentPosts;
  final bool isRefreshing;

  const PostsLoading({
    this.currentPosts,
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [currentPosts, isRefreshing];
}

/// Loaded state for posts
class PostsLoaded extends HomeState {
  final List<Post> posts;
  final bool hasReachedMax;
  final String? selectedCategory;

  const PostsLoaded({
    required this.posts,
    this.hasReachedMax = false,
    this.selectedCategory,
  });

  @override
  List<Object?> get props => [posts, hasReachedMax, selectedCategory];

  /// Create a copy with updated values
  PostsLoaded copyWith({
    List<Post>? posts,
    bool? hasReachedMax,
    String? selectedCategory,
  }) {
    return PostsLoaded(
      posts: posts ?? this.posts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

/// Error state for posts
class PostsError extends HomeState {
  final String message;

  const PostsError({required this.message});

  @override
  List<Object> get props => [message];
}

/// Loading state for personalized posts
class PersonalizedPostsLoading extends HomeState {
  final List<Post>? currentPosts;
  final bool isRefreshing;

  const PersonalizedPostsLoading({
    this.currentPosts,
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [currentPosts, isRefreshing];
}

/// Loaded state for personalized posts
class PersonalizedPostsLoaded extends HomeState {
  final List<Post> posts;
  final bool hasReachedMax;

  const PersonalizedPostsLoaded({
    required this.posts,
    this.hasReachedMax = false,
  });

  @override
  List<Object> get props => [posts, hasReachedMax];

  /// Create a copy with updated values
  PersonalizedPostsLoaded copyWith({
    List<Post>? posts,
    bool? hasReachedMax,
  }) {
    return PersonalizedPostsLoaded(
      posts: posts ?? this.posts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

/// Error state for personalized posts
class PersonalizedPostsError extends HomeState {
  final String message;

  const PersonalizedPostsError({required this.message});

  @override
  List<Object> get props => [message];
}

/// Loading state for events
class EventsLoading extends HomeState {
  final List<Event>? currentEvents;
  final bool isRefreshing;

  const EventsLoading({
    this.currentEvents,
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [currentEvents, isRefreshing];
}

/// Loaded state for events
class EventsLoaded extends HomeState {
  final List<Event> events;
  final bool hasReachedMax;

  const EventsLoaded({
    required this.events,
    this.hasReachedMax = false,
  });

  @override
  List<Object> get props => [events, hasReachedMax];

  /// Create a copy with updated values
  EventsLoaded copyWith({
    List<Event>? events,
    bool? hasReachedMax,
  }) {
    return EventsLoaded(
      events: events ?? this.events,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

/// Error state for events
class EventsError extends HomeState {
  final String message;

  const EventsError({required this.message});

  @override
  List<Object> get props => [message];
}

/// Loading state for post creation
class PostCreating extends HomeState {
  const PostCreating();
}

/// Success state for post creation
class PostCreated extends HomeState {
  final Post post;

  const PostCreated({required this.post});

  @override
  List<Object> get props => [post];
}

/// Error state for post creation
class PostCreationError extends HomeState {
  final String message;

  const PostCreationError({required this.message});

  @override
  List<Object> get props => [message];
}
