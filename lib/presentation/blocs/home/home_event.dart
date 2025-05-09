import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadPostsEvent extends HomeEvent {
  final String? category;

  const LoadPostsEvent({this.category});

  @override
  List<Object?> get props => [category];
}

class LoadEventsEvent extends HomeEvent {
  final bool upcomingOnly;

  const LoadEventsEvent({this.upcomingOnly = true});

  @override
  List<Object?> get props => [upcomingOnly];
}

class CreatePostEvent extends HomeEvent {
  final String userId;
  final String content;
  final String category;
  final String? location;
  final String? imageUrl;

  const CreatePostEvent({
    required this.userId,
    required this.content,
    required this.category,
    this.location,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [userId, content, category, location, imageUrl];
}

class CreateEventEvent extends HomeEvent {
  final String title;
  final DateTime eventDate;
  final String location;
  final String? description;
  final String? imageUrl;
  final String createdBy;

  const CreateEventEvent({
    required this.title,
    required this.eventDate,
    required this.location,
    this.description,
    this.imageUrl,
    required this.createdBy,
  });

  @override
  List<Object?> get props => [title, eventDate, location, description, imageUrl, createdBy];
}

class FilterPostsByCategoryEvent extends HomeEvent {
  final String category;

  const FilterPostsByCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}
