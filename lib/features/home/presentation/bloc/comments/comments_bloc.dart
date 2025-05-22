import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:immigru/features/home/domain/entities/post_comment.dart';
import 'package:immigru/features/home/domain/usecases/create_comment_usecase.dart';
import 'package:immigru/features/home/domain/usecases/get_comments_usecase.dart';

part 'comments_event.dart';
part 'comments_state.dart';

/// BLoC for managing comments state
class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final GetCommentsUseCase getCommentsUseCase;
  final CreateCommentUseCase createCommentUseCase;

  /// Create a new CommentsBloc
  CommentsBloc({
    required this.getCommentsUseCase,
    required this.createCommentUseCase,
  }) : super(CommentsInitial()) {
    on<LoadComments>(_onLoadComments);
    on<CreateComment>(_onCreateComment);
  }

  /// Handle LoadComments event
  Future<void> _onLoadComments(
    LoadComments event,
    Emitter<CommentsState> emit,
  ) async {
    emit(CommentsLoading());

    final result = await getCommentsUseCase.call(
      postId: event.postId,
      limit: event.limit,
      offset: event.offset,
    );

    result.fold(
      (failure) => emit(CommentsError(message: failure.message)),
      (comments) => emit(CommentsLoaded(comments: comments)),
    );
  }

  /// Handle CreateComment event
  Future<void> _onCreateComment(
    CreateComment event,
    Emitter<CommentsState> emit,
  ) async {
    // Get current state to preserve existing comments
    final currentState = state;
    List<PostComment> currentComments = [];
    
    if (currentState is CommentsLoaded) {
      currentComments = List.from(currentState.comments);
      // Show loading state but keep existing comments
      emit(CommentsLoading(comments: currentComments));
    } else {
      emit(CommentsLoading());
    }

    final result = await createCommentUseCase.execute(
      postId: event.postId,
      userId: event.userId,
      content: event.content,
      parentCommentId: event.parentCommentId,
    );

    result.fold(
      (failure) {
        // Restore previous state on error
        if (currentState is CommentsLoaded) {
          emit(currentState);
        }
        emit(CommentsError(message: failure.message));
      },
      (newComment) {
        // If this is a reply to an existing comment, add it to the replies
        if (event.parentCommentId != null && currentComments.isNotEmpty) {
          final updatedComments = _addReplyToComment(
            currentComments,
            event.parentCommentId!,
            newComment,
          );
          emit(CommentsLoaded(comments: updatedComments));
        } else {
          // Add the new comment to the top of the list
          emit(CommentsLoaded(
            comments: [newComment, ...currentComments],
          ));
        }
      },
    );
  }

  /// Helper method to add a reply to a comment in the tree
  List<PostComment> _addReplyToComment(
    List<PostComment> comments,
    String parentId,
    PostComment newReply,
  ) {
    return comments.map((comment) {
      if (comment.id == parentId) {
        // Add the reply to this comment
        return PostComment(
          id: comment.id,
          postId: comment.postId,
          userId: comment.userId,
          content: comment.content,
          createdAt: comment.createdAt,
          userName: comment.userName,
          userAvatar: comment.userAvatar,
          parentCommentId: comment.parentCommentId,
          replies: [newReply, ...comment.replies],
        );
      } else if (comment.replies.isNotEmpty) {
        // Check if the parent is in the replies
        return PostComment(
          id: comment.id,
          postId: comment.postId,
          userId: comment.userId,
          content: comment.content,
          createdAt: comment.createdAt,
          userName: comment.userName,
          userAvatar: comment.userAvatar,
          parentCommentId: comment.parentCommentId,
          replies: _addReplyToComment(comment.replies, parentId, newReply),
        );
      }
      return comment;
    }).toList();
  }
}
