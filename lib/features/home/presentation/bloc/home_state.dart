import 'package:equatable/equatable.dart';
import 'package:immigru/features/home/domain/entities/event.dart';
import 'package:immigru/features/home/domain/entities/post.dart';

/// Base state for the home feature
abstract class HomeState extends Equatable {
  /// Constructor
  const HomeState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class HomeInitial extends HomeState {
  /// Constructor
  const HomeInitial();
}

/// Loading posts state
class PostsLoading extends HomeState {
  /// Current posts if refreshing
  final List<Post>? currentPosts;

  /// Whether this is a refresh operation
  final bool isRefreshing;

  /// Constructor
  const PostsLoading({
    this.currentPosts,
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [currentPosts, isRefreshing];
}

/// Posts loaded state
class PostsLoaded extends HomeState {
  /// List of posts
  final List<Post> posts;

  /// Whether we've reached the maximum number of posts
  final bool hasReachedMax;

  /// Selected category
  final String selectedCategory;

  /// Filter type: 'all', 'user', 'following', 'my-immigroves'
  final String filter;

  /// Optional user ID to filter posts by
  final String? userId;

  /// Optional ImmiGrove ID to filter posts by
  final String? immigroveId;

  /// Whether to exclude the current user's posts
  final bool excludeCurrentUser;

  /// ID of the current user (needed for some filters)
  final String? currentUserId;

  /// Whether more posts are being loaded (pagination)
  final bool isLoadingMore;

  /// Constructor
  const PostsLoaded({
    required this.posts,
    required this.hasReachedMax,
    required this.selectedCategory,
    this.filter = 'all',
    this.userId,
    this.immigroveId,
    this.excludeCurrentUser = false,
    this.currentUserId,
    this.isLoadingMore = false,
  });

  /// Create a copy with some fields changed
  PostsLoaded copyWith({
    List<Post>? posts,
    bool? hasReachedMax,
    String? selectedCategory,
    String? filter,
    String? userId,
    String? immigroveId,
    bool? excludeCurrentUser,
    String? currentUserId,
    bool? isLoadingMore,
  }) {
    return PostsLoaded(
      posts: posts ?? this.posts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      filter: filter ?? this.filter,
      userId: userId ?? this.userId,
      immigroveId: immigroveId ?? this.immigroveId,
      excludeCurrentUser: excludeCurrentUser ?? this.excludeCurrentUser,
      currentUserId: currentUserId ?? this.currentUserId,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
    posts, 
    hasReachedMax, 
    selectedCategory, 
    filter,
    userId,
    immigroveId,
    excludeCurrentUser,
    currentUserId,
    isLoadingMore
  ];
}

/// Error state for posts
class PostsError extends HomeState {
  /// Error message
  final String message;

  /// Constructor
  const PostsError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

/// Loading personalized posts state
class PersonalizedPostsLoading extends HomeState {
  /// Current posts if refreshing
  final List<Post>? currentPosts;

  /// Whether this is a refresh operation
  final bool isRefreshing;

  /// Constructor
  const PersonalizedPostsLoading({
    this.currentPosts,
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [currentPosts, isRefreshing];
}

/// Personalized posts loaded state
class PersonalizedPostsLoaded extends HomeState {
  /// List of personalized posts
  final List<Post> posts;

  /// Whether we've reached the maximum number of posts
  final bool hasReachedMax;

  /// Constructor
  const PersonalizedPostsLoaded({
    required this.posts,
    required this.hasReachedMax,
  });

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

  @override
  List<Object?> get props => [posts, hasReachedMax];
}

/// Error state for personalized posts
class PersonalizedPostsError extends HomeState {
  /// Error message
  final String message;

  /// Constructor
  const PersonalizedPostsError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

/// Loading events state
class EventsLoading extends HomeState {
  /// Current events if refreshing
  final List<Event>? currentEvents;

  /// Whether this is a refresh operation
  final bool isRefreshing;

  /// Constructor
  const EventsLoading({
    this.currentEvents,
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [currentEvents, isRefreshing];
}

/// Events loaded state
class EventsLoaded extends HomeState {
  /// List of events
  final List<Event> events;

  /// Whether we've reached the maximum number of events
  final bool hasReachedMax;

  /// Constructor
  const EventsLoaded({
    required this.events,
    required this.hasReachedMax,
  });

  @override
  List<Object?> get props => [events, hasReachedMax];

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
  /// Error message
  final String message;

  /// Constructor
  const EventsError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

/// Loading state for post creation
class PostCreating extends HomeState {
  /// Constructor
  const PostCreating();
}

/// Success state for post creation
class PostCreated extends HomeState {
  /// Created post
  final Post post;

  /// Constructor
  const PostCreated({
    required this.post,
  });

  @override
  List<Object?> get props => [post];
}

/// Error state for post creation
class PostCreationError extends HomeState {
  /// Error message
  final String message;

  /// Constructor
  const PostCreationError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

/// State indicating the home screen is ready for navigation
class HomeNavigationReady extends HomeState {
  /// Constructor
  const HomeNavigationReady();
}

/// State indicating the home screen is fully initialized
class HomeFullyInitialized extends HomeState {
  /// Constructor
  const HomeFullyInitialized();
}
