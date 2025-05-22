import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/features/home/domain/entities/post_media.dart';
import 'package:immigru/features/home/presentation/bloc/post_creation/post_creation_event.dart';
import 'package:immigru/features/home/presentation/bloc/post_creation/post_creation_state.dart';

/// BLoC for managing post creation state
class PostCreationBloc extends Bloc<PostCreationEvent, PostCreationState> {
  final UnifiedLogger _logger = UnifiedLogger();

  PostCreationBloc() : super(const PostCreationState()) {
    on<PostContentChanged>(_onPostContentChanged);
    on<CategorySelected>(_onCategorySelected);
    on<MediaAdded>(_onMediaAdded);
    on<MediaRemoved>(_onMediaRemoved);
    on<PostSubmitted>(_onPostSubmitted);
    on<PostCreationReset>(_onPostCreationReset);
  }

  void _onPostContentChanged(
    PostContentChanged event,
    Emitter<PostCreationState> emit,
  ) {
    emit(state.copyWith(content: event.content));
  }

  void _onCategorySelected(
    CategorySelected event,
    Emitter<PostCreationState> emit,
  ) {
    emit(state.copyWith(category: event.category));
  }

  void _onMediaAdded(
    MediaAdded event,
    Emitter<PostCreationState> emit,
  ) {
    final updatedMedia = List<PostMedia>.from(state.media)..add(event.media);
    emit(state.copyWith(media: updatedMedia));
    _logger.d('Media added: ${event.media.path}', tag: 'PostCreationBloc');
  }

  void _onMediaRemoved(
    MediaRemoved event,
    Emitter<PostCreationState> emit,
  ) {
    final updatedMedia = List<PostMedia>.from(state.media)
      ..removeWhere((media) => media.id == event.mediaId);
    emit(state.copyWith(media: updatedMedia));
    _logger.d('Media removed: ${event.mediaId}', tag: 'PostCreationBloc');
  }

  void _onPostSubmitted(
    PostSubmitted event,
    Emitter<PostCreationState> emit,
  ) async {
    if (event.content.trim().isEmpty) {
      emit(state.copyWith(
        errorMessage: 'Please enter some content',
      ));
      return;
    }

    emit(state.copyWith(
      isSubmitting: true,
      errorMessage: null,
    ));

    try {
      // In a real implementation, this would call a repository
      // For now, we'll just simulate a successful post creation
      await Future.delayed(const Duration(seconds: 1));
      
      emit(state.copyWith(
        isSubmitting: false,
        isSuccess: true,
      ));
      
      _logger.d('Post submitted successfully', tag: 'PostCreationBloc');
    } catch (e) {
      _logger.e('Error submitting post: $e', tag: 'PostCreationBloc');
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to submit post: $e',
      ));
    }
  }

  void _onPostCreationReset(
    PostCreationReset event,
    Emitter<PostCreationState> emit,
  ) {
    emit(const PostCreationState());
  }
}
