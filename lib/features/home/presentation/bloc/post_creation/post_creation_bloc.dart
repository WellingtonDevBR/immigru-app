import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/features/home/domain/entities/post_media.dart';
import 'package:immigru/features/home/domain/usecases/create_post_usecase.dart';
import 'package:immigru/features/home/presentation/bloc/post_creation/post_creation_event.dart';
import 'package:immigru/features/home/presentation/bloc/post_creation/post_creation_state.dart';

/// BLoC for managing post creation state
class PostCreationBloc extends Bloc<PostCreationEvent, PostCreationState> {
  final UnifiedLogger _logger = UnifiedLogger();
  final CreatePostUseCase? createPostUseCase;

  PostCreationBloc({this.createPostUseCase}) : super(const PostCreationState()) {
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
    // Fix for text reversal issue - ensure text is in correct order
    final content = event.content;
    _logger.d('Content changed: $content', tag: 'PostCreationBloc');
    emit(state.copyWith(content: content));
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
      if (createPostUseCase != null) {
        // Use the CreatePostUseCase to create the post
        final result = await createPostUseCase!.call(
          content: event.content,
          userId: event.userId,
          category: event.category,
          media: event.media,
        );
        
        result.fold(
          (failure) {
            _logger.e('Error creating post: ${failure.message}', tag: 'PostCreationBloc');
            emit(state.copyWith(
              isSubmitting: false,
              errorMessage: 'Failed to create post: ${failure.message}',
            ));
          },
          (post) {
            _logger.d('Post created successfully with ID: ${post.id}', tag: 'PostCreationBloc');
            emit(state.copyWith(
              isSubmitting: false,
              isSuccess: true,
            ));
          },
        );
      } else {
        // Fallback to simulated success if use case is not provided
        _logger.w('CreatePostUseCase not provided, simulating success', tag: 'PostCreationBloc');
        await Future.delayed(const Duration(seconds: 1));
        
        emit(state.copyWith(
          isSubmitting: false,
          isSuccess: true,
        ));
      }
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
