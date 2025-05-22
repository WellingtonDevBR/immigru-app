import 'package:equatable/equatable.dart';
import 'package:immigru/features/home/domain/entities/post_media.dart';

/// Base class for all post creation events
abstract class PostCreationEvent extends Equatable {
  const PostCreationEvent();

  @override
  List<Object?> get props => [];
}

/// Event when content text is changed
class PostContentChanged extends PostCreationEvent {
  final String content;

  const PostContentChanged(this.content);

  @override
  List<Object?> get props => [content];
}

/// Event when a category is selected
class CategorySelected extends PostCreationEvent {
  final String category;

  const CategorySelected(this.category);

  @override
  List<Object?> get props => [category];
}

/// Event when media is added
class MediaAdded extends PostCreationEvent {
  final PostMedia media;

  const MediaAdded(this.media);

  @override
  List<Object?> get props => [media];
}

/// Event when media is removed
class MediaRemoved extends PostCreationEvent {
  final String mediaId;

  const MediaRemoved(this.mediaId);

  @override
  List<Object?> get props => [mediaId];
}

/// Event when post is submitted
class PostSubmitted extends PostCreationEvent {
  final String userId;
  final String content;
  final String category;
  final List<PostMedia> media;

  const PostSubmitted({
    required this.userId,
    required this.content,
    required this.category,
    required this.media,
  });

  @override
  List<Object?> get props => [userId, content, category, media];
}

/// Event to reset the post creation state
class PostCreationReset extends PostCreationEvent {}
