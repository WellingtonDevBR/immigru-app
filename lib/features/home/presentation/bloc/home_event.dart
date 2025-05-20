import 'package:equatable/equatable.dart';

/// Events for the home screen
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch posts
class FetchPosts extends HomeEvent {
  final String? category;
  final bool refresh;

  const FetchPosts({
    this.category,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [category, refresh];
}

/// Event to fetch more posts (pagination)
class FetchMorePosts extends HomeEvent {
  const FetchMorePosts();
}

/// Event to fetch personalized posts
class FetchPersonalizedPosts extends HomeEvent {
  final String userId;
  final bool refresh;

  const FetchPersonalizedPosts({
    required this.userId,
    this.refresh = false,
  });

  @override
  List<Object> get props => [userId, refresh];
}

/// Event to fetch more personalized posts (pagination)
class FetchMorePersonalizedPosts extends HomeEvent {
  final String userId;

  const FetchMorePersonalizedPosts({
    required this.userId,
  });

  @override
  List<Object> get props => [userId];
}

/// Event to fetch events
class FetchEvents extends HomeEvent {
  final bool upcoming;
  final bool refresh;

  const FetchEvents({
    this.upcoming = true,
    this.refresh = false,
  });

  @override
  List<Object> get props => [upcoming, refresh];
}

/// Event to fetch more events (pagination)
class FetchMoreEvents extends HomeEvent {
  final bool upcoming;

  const FetchMoreEvents({
    this.upcoming = true,
  });

  @override
  List<Object> get props => [upcoming];
}

/// Event to create a post
class CreatePost extends HomeEvent {
  final String content;
  final String userId;
  final String category;
  final String? imageUrl;

  const CreatePost({
    required this.content,
    required this.userId,
    required this.category,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [content, userId, category, imageUrl];
}

/// Event to like or unlike a post
class LikePost extends HomeEvent {
  final String postId;
  final String userId;
  final bool like;

  const LikePost({
    required this.postId,
    required this.userId,
    required this.like,
  });

  @override
  List<Object> get props => [postId, userId, like];
}

/// Event to register for an event
class RegisterForEvent extends HomeEvent {
  final String eventId;
  final String userId;

  const RegisterForEvent({
    required this.eventId,
    required this.userId,
  });

  @override
  List<Object> get props => [eventId, userId];
}

/// Event to select a category
class SelectCategory extends HomeEvent {
  final String category;

  const SelectCategory({required this.category});

  @override
  List<Object> get props => [category];
}
