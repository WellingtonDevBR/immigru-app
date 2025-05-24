import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:immigru/features/home/domain/entities/post_comment.dart';
import 'package:immigru/features/home/domain/usecases/create_comment_usecase.dart';
import 'package:immigru/features/home/domain/usecases/get_comments_usecase.dart';
import 'package:immigru/features/home/domain/usecases/edit_comment_usecase.dart';
import 'package:immigru/features/home/domain/usecases/delete_comment_usecase.dart';
import 'package:immigru/features/home/domain/usecases/like_comment_usecase.dart';
import 'package:immigru/features/home/domain/usecases/unlike_comment_usecase.dart';

part 'comments_event.dart';
part 'comments_state.dart';

/// BLoC for managing comments state
class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final GetCommentsUseCase getCommentsUseCase;
  final CreateCommentUseCase createCommentUseCase;
  final EditCommentUseCase editCommentUseCase;
  final DeleteCommentUseCase deleteCommentUseCase;
  final LikeCommentUseCase likeCommentUseCase;
  final UnlikeCommentUseCase unlikeCommentUseCase;

  /// Create a new CommentsBloc
  CommentsBloc({
    required this.getCommentsUseCase,
    required this.createCommentUseCase,
    required this.editCommentUseCase,
    required this.deleteCommentUseCase,
    required this.likeCommentUseCase,
    required this.unlikeCommentUseCase,
  }) : super(CommentsInitial()) {
    on<LoadComments>(_onLoadComments);
    on<CreateComment>(_onCreateComment);
    on<EditComment>(_onEditComment);
    on<DeleteComment>(_onDeleteComment);
    on<LikeComment>(_onLikeComment);
    on<UnlikeComment>(_onUnlikeComment);
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
      // Keep all existing comments in the updating state
      emit(CommentsUpdating(comments: currentComments));
    } else {
      emit(CommentsLoading());
    }

    // Calculate depth and root comment ID based on parent comment
    int depth = 1; // Default depth for direct post comments
    String? rootCommentId;

    if (event.parentCommentId != null && currentComments.isNotEmpty) {
      // Find the parent comment to determine depth and root
      final parentComment =
          _findCommentById(currentComments, event.parentCommentId!);

      if (parentComment != null) {
        // If parent already has a rootCommentId, use that (it's a reply to a reply)
        if (parentComment.rootCommentId != null) {
          rootCommentId = parentComment.rootCommentId;
          // Increment parent's depth, but cap at 3
          depth = parentComment.depth < 3 ? parentComment.depth + 1 : 3;
        } else {
          // This is a reply to a top-level comment, so the parent is the root
          rootCommentId = parentComment.id;
          depth = 2; // Second level
        }
      }
    }

    final result = await createCommentUseCase.execute(
      postId: event.postId,
      userId: event.userId,
      content: event.content,
      parentCommentId: event.parentCommentId,
      rootCommentId: rootCommentId,
      depth: depth,
    );

    result.fold(
      (failure) => emit(CommentsError(message: failure.message)),
      (newComment) {
        if (currentState is CommentsLoaded) {
          // Create a deep copy of the current comments to update
          final updatedComments = _addCommentToTree(
            List.from(currentState.comments),
            newComment,
            event.parentCommentId,
          );
          // Emit the updated comments while preserving the structure
          emit(CommentsLoaded(comments: updatedComments));

          // Reload all comments to ensure consistency
          add(LoadComments(postId: event.postId));
        } else {
          emit(CommentsLoaded(comments: [newComment]));

          // Reload all comments to ensure consistency
          add(LoadComments(postId: event.postId));
        }
      },
    );
  }

  /// Handle EditComment event
  Future<void> _onEditComment(
    EditComment event,
    Emitter<CommentsState> emit,
  ) async {
    if (state is CommentsLoaded) {
      final currentState = state as CommentsLoaded;
      // Keep all existing comments in the updating state
      emit(CommentsUpdating(comments: currentState.comments));

      final result = await editCommentUseCase.execute(
        commentId: event.commentId,
        postId: event.postId,
        userId: event.userId,
        content: event.content,
      );

      result.fold(
        (failure) => emit(CommentsError(message: failure.message)),
        (updatedComment) {
          // Create a deep copy of the current comments to update
          final updatedComments = _updateCommentInTree(
            List.from(currentState.comments),
            event.commentId,
            updatedComment.content,
          );
          // Emit the updated comments while preserving the structure
          emit(CommentsLoaded(comments: updatedComments));

          // Reload all comments to ensure consistency
          add(LoadComments(postId: event.postId));
        },
      );
    }
  }

  /// Handle DeleteComment event
  Future<void> _onDeleteComment(
    DeleteComment event,
    Emitter<CommentsState> emit,
  ) async {
    if (state is CommentsLoaded) {
      final currentState = state as CommentsLoaded;
      // Keep all existing comments in the updating state
      emit(CommentsUpdating(comments: currentState.comments));

      final result = await deleteCommentUseCase.execute(
        commentId: event.commentId,
        postId: event.postId,
        userId: event.userId,
      );

      result.fold(
        (failure) => emit(CommentsError(message: failure.message)),
        (success) {
          if (success) {
            // Create a deep copy of the current comments to update
            final updatedComments = _removeCommentFromTree(
              List.from(currentState.comments),
              event.commentId,
            );
            // Emit the updated comments while preserving the structure
            emit(CommentsLoaded(comments: updatedComments));

            // Reload all comments to ensure consistency
            add(LoadComments(postId: event.postId));
          } else {
            emit(CommentsError(message: 'Failed to delete comment'));
          }
        },
      );
    }
  }

  /// Helper method to find a comment by ID in the comment tree
  PostComment? _findCommentById(List<PostComment> comments, String commentId) {
    for (final comment in comments) {
      if (comment.id == commentId) {
        return comment;
      }

      // Search in replies recursively
      if (comment.replies.isNotEmpty) {
        final foundInReplies = _findCommentById(comment.replies, commentId);
        if (foundInReplies != null) {
          return foundInReplies;
        }
      }
    }

    return null;
  }

  /// Helper method to add a new comment to the comment tree
  List<PostComment> _addCommentToTree(
    List<PostComment> comments,
    PostComment newComment,
    String? parentCommentId,
  ) {
    // If this is a top-level comment (no parent), add it to the list
    if (parentCommentId == null) {
      return [newComment, ...comments];
    }

    // Otherwise, find the parent and add the comment as a reply
    return comments.map((comment) {
      if (comment.id == parentCommentId) {
        // Add the reply to this comment
        final updatedReplies = [newComment, ...comment.replies];
        return comment.copyWith(replies: updatedReplies);
      } else if (comment.replies.isNotEmpty) {
        // Check if the parent is in the replies
        final updatedReplies =
            _addCommentToTree(comment.replies, newComment, parentCommentId);
        return comment.copyWith(replies: updatedReplies);
      }
      return comment;
    }).toList();
  }

  /// Helper method to update a comment's content in the tree
  List<PostComment> _updateCommentInTree(
    List<PostComment> comments,
    String commentId,
    String newContent,
  ) {
    return comments.map((comment) {
      if (comment.id == commentId) {
        // Update this comment
        return comment.copyWith(content: newContent);
      } else if (comment.replies.isNotEmpty) {
        // Check if the comment is in the replies
        final updatedReplies =
            _updateCommentInTree(comment.replies, commentId, newContent);
        return comment.copyWith(replies: updatedReplies);
      }
      return comment;
    }).toList();
  }

  /// Helper method to remove a comment from the tree
  List<PostComment> _removeCommentFromTree(
    List<PostComment> comments,
    String commentId,
  ) {
    // First, check if the comment is at this level
    final filteredComments =
        comments.where((comment) => comment.id != commentId).toList();

    // If we removed a comment, return the filtered list
    if (filteredComments.length < comments.length) {
      return filteredComments;
    }

    // Otherwise, check in the replies of each comment
    return filteredComments.map((comment) {
      if (comment.replies.isNotEmpty) {
        final updatedReplies =
            _removeCommentFromTree(comment.replies, commentId);
        return comment.copyWith(replies: updatedReplies);
      }
      return comment;
    }).toList();
  }

  /// Helper method to update a comment's like status in the tree
  List<PostComment> _updateCommentLikeStatus({
    required List<PostComment> comments,
    required String commentId,
    required bool isLiked,
  }) {
    return comments.map((comment) {
      if (comment.id == commentId) {
        // Update this comment's like status
        final currentLikeCount = comment.likeCount;
        final newLikeCount = isLiked
            ? currentLikeCount + 1
            : (currentLikeCount > 0 ? currentLikeCount - 1 : 0);

        return comment.copyWith(
          isLikedByCurrentUser: isLiked,
          likeCount: newLikeCount,
        );
      } else if (comment.replies.isNotEmpty) {
        // Check if the comment is in the replies
        final updatedReplies = _updateCommentLikeStatus(
          comments: comment.replies,
          commentId: commentId,
          isLiked: isLiked,
        );
        return comment.copyWith(replies: updatedReplies);
      }
      return comment;
    }).toList();
  }

  /// Handle LikeComment event
  Future<void> _onLikeComment(
    LikeComment event,
    Emitter<CommentsState> emit,
  ) async {
    // Get the current comments if available
    final currentState = state;
    List<PostComment> currentComments = [];
    if (currentState is CommentsLoaded) {
      currentComments = List.from(currentState.comments);
    } else {
      // If we don't have comments loaded, we can't like one
      return;
    }
    // Optimistically update the UI to show the comment as liked
    final updatedComments = _updateCommentLikeStatus(
      comments: currentComments,
      commentId: event.commentId,
      isLiked: true,
    );

    // Update the UI immediately
    emit(CommentsLoaded(comments: updatedComments));

    // Call the API to like the comment
    final result = await likeCommentUseCase.call(
      LikeCommentParams(
        commentId: event.commentId,
        userId: event.userId,
      ),
    );

    // Handle the result
    result.fold(
      (failure) {
        emit(CommentsLoaded(comments: currentComments));
        emit(CommentsError(message: failure.message));
      },
      (success) {},
    );
  }

  /// Handle UnlikeComment event
  Future<void> _onUnlikeComment(
    UnlikeComment event,
    Emitter<CommentsState> emit,
  ) async {
    // Get the current comments if available
    final currentState = state;
    List<PostComment> currentComments = [];
    if (currentState is CommentsLoaded) {
      currentComments = List.from(currentState.comments);
    } else {
      // If we don't have comments loaded, we can't unlike one
      return;
    }

    // Optimistically update the UI to show the comment as unliked
    final updatedComments = _updateCommentLikeStatus(
      comments: currentComments,
      commentId: event.commentId,
      isLiked: false,
    );

    // Update the UI immediately
    emit(CommentsLoaded(comments: updatedComments));

    // Call the API to unlike the comment
    final result = await unlikeCommentUseCase.call(
      UnlikeCommentParams(
        commentId: event.commentId,
        userId: event.userId,
      ),
    );

    // Handle the result
    result.fold(
      (failure) {
        emit(CommentsLoaded(comments: currentComments));
        emit(CommentsError(message: failure.message));
      },
      (success) {},
    );
  }
}