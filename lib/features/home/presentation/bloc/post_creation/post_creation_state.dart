import 'package:equatable/equatable.dart';
import 'package:immigru/features/home/domain/entities/post_media.dart';

/// Base class for all post creation states
class PostCreationState extends Equatable {
  final String content;
  final String category;
  final List<PostMedia> media;
  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;

  const PostCreationState({
    this.content = '',
    this.category = 'General',
    this.media = const [],
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  /// Create a copy of the state with updated fields
  PostCreationState copyWith({
    String? content,
    String? category,
    List<PostMedia>? media,
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return PostCreationState(
      content: content ?? this.content,
      category: category ?? this.category,
      media: media ?? this.media,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        content,
        category,
        media,
        isSubmitting,
        isSuccess,
        errorMessage,
      ];
}
