import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:immigru/features/home/domain/entities/post.dart';
import 'package:immigru/features/home/domain/entities/post_comment.dart';
import 'package:immigru/features/home/domain/repositories/comment_repository.dart';
import 'package:immigru/features/home/domain/usecases/create_comment_usecase.dart';
import 'package:immigru/features/home/domain/usecases/delete_comment_usecase.dart';
import 'package:immigru/features/home/domain/usecases/edit_comment_usecase.dart';
import 'package:immigru/features/home/domain/usecases/get_comments_usecase.dart';
import 'package:immigru/features/home/domain/usecases/like_comment_usecase.dart';
import 'package:immigru/features/home/domain/usecases/unlike_comment_usecase.dart';
import 'package:immigru/features/home/presentation/bloc/comments/comments_bloc.dart';
import 'package:immigru/features/home/presentation/bloc/home_bloc.dart';
import 'package:immigru/features/home/presentation/bloc/home_event.dart';
import 'package:immigru/features/home/presentation/widgets/comment_input_widget.dart';
import 'package:immigru/features/home/presentation/widgets/comment_list_widget.dart';
import 'package:immigru/shared/widgets/error_message_widget.dart';
import 'package:immigru/shared/widgets/loading_indicator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:immigru/core/storage/supabase_storage_utils.dart';

/// Screen to display and manage comments for a post
class PostCommentsScreen extends StatefulWidget {
  /// Post to show comments for
  final Post post;

  /// Current user ID
  final String userId;

  /// HomeBloc instance
  final HomeBloc homeBloc;

  /// Create a new PostCommentsScreen
  const PostCommentsScreen({
    super.key,
    required this.post,
    required this.userId,
    required this.homeBloc,
  });

  @override
  State<PostCommentsScreen> createState() => _PostCommentsScreenState();
}

class _PostCommentsScreenState extends State<PostCommentsScreen> {
  late CommentsBloc _commentsBloc;
  PostComment? _replyingTo;

  // Storage utils for handling image URLs
  final _storageUtils = SupabaseStorageUtils.instance;

  @override
  void initState() {
    super.initState();
    
    // Create a new instance of CommentsBloc with all required dependencies
    final commentRepository = GetIt.instance.get<CommentRepository>();
    
    // Create all the required use cases
    final getCommentsUseCase = GetCommentsUseCase(commentRepository);
    final createCommentUseCase = CreateCommentUseCase(repository: commentRepository);
    final editCommentUseCase = EditCommentUseCase(repository: commentRepository);
    final deleteCommentUseCase = DeleteCommentUseCase(repository: commentRepository);
    final likeCommentUseCase = LikeCommentUseCase(commentRepository);
    final unlikeCommentUseCase = UnlikeCommentUseCase(commentRepository);
    
    // Create a new instance of CommentsBloc with all required use cases
    _commentsBloc = CommentsBloc(
      getCommentsUseCase: getCommentsUseCase,
      createCommentUseCase: createCommentUseCase,
      editCommentUseCase: editCommentUseCase,
      deleteCommentUseCase: deleteCommentUseCase,
      likeCommentUseCase: likeCommentUseCase,
      unlikeCommentUseCase: unlikeCommentUseCase,
    );
    
    // Load comments when the screen initializes
    _loadComments();
  }

  /// Validates if the provided URL is a valid image URL
  bool _isValidImageUrl(String? url) {
    return _storageUtils.isValidImageUrl(url);
  }

  void _loadComments() {
    _commentsBloc.add(LoadComments(postId: widget.post.id));
  }

  Future<void> _handleCommentSubmit(
      String content, String? parentCommentId, String? rootCommentId) async {
    // Calculate comment depth based on parent comment
    int depth = 1; // Default for direct post comments

    if (parentCommentId != null && _replyingTo != null) {
      // If replying to a comment, set depth accordingly
      depth = _replyingTo!.depth + 1;

      // Cap depth at maximum level (3)
      if (depth > CommentInputWidget.maxDepth) {
        depth = CommentInputWidget.maxDepth;
      }
    }

    _commentsBloc.add(
      CreateComment(
        postId: widget.post.id,
        userId: widget.userId,
        content: content,
        parentCommentId: parentCommentId,
        rootCommentId: rootCommentId,
        depth: depth,
      ),
    );

    // If this was a reply in a modal, close the modal
    if (_replyingTo != null) {
      Navigator.of(context).pop();
      _replyingTo = null;
    }

    // Mark that the user has commented on this post
    // This will be used to control the comment animation
    _updatePostHasUserComment();

    return Future.value();
  }

  /// Updates the post's hasUserComment flag to indicate the current user has commented
  void _updatePostHasUserComment() {
    // Use the HomeBloc passed as a parameter
    widget.homeBloc.add(UpdatePostHasUserComment(
      postId: widget.post.id,
      hasUserComment: true,
    ));
  }

  void _showReplyModal(PostComment parentComment) {
    setState(() {
      _replyingTo = parentComment;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: CommentInputWidget(
            postId: widget.post.id,
            onSubmit: _handleCommentSubmit,
            parentComment: parentComment,
          ),
        );
      },
    ).then((_) {
      setState(() {
        _replyingTo = null;
      });
    });
  }
  
  /// Show a modal to edit a comment
  void _showEditCommentModal(PostComment comment) {
    // Create a text controller pre-filled with the comment content
    final TextEditingController controller = TextEditingController(text: comment.content);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Edit Comment',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Edit your comment...',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      final editedContent = controller.text.trim();
                      if (editedContent.isNotEmpty) {
                        _handleEditComment(comment, editedContent);
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Save'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    ).then((_) {
      controller.dispose();
    });
  }
  
  /// Show confirmation dialog before deleting a comment
  void _showDeleteCommentDialog(PostComment comment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: Text(
          'Are you sure you want to delete this comment? ${comment.replies.isNotEmpty 
              ? 'All replies to this comment will also be deleted.'
              : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleDeleteComment(comment);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  /// Handle editing a comment
  void _handleEditComment(PostComment comment, String newContent) {
    _commentsBloc.add(
      EditComment(
        commentId: comment.id,
        postId: widget.post.id,
        userId: widget.userId,
        content: newContent,
      ),
    );
  }
  
  /// Handle deleting a comment
  void _handleDeleteComment(PostComment comment) {
    _commentsBloc.add(
      DeleteComment(
        commentId: comment.id,
        postId: widget.post.id,
        userId: widget.userId,
      ),
    );
  }
  
  /// Handle liking a comment
  void _handleLikeComment(PostComment comment) {
    _commentsBloc.add(
      LikeComment(
        commentId: comment.id,
        userId: widget.userId,
      ),
    );
  }
  
  /// Handle unliking a comment
  void _handleUnlikeComment(PostComment comment) {
    _commentsBloc.add(
      UnlikeComment(
        commentId: comment.id,
        userId: widget.userId,
      ),
    );
  }
  
  /// Toggle like status for a comment
  void _toggleCommentLike(PostComment comment) {
    // Get current user ID from Supabase
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    
    // If user is not logged in, show a message
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to like comments')),
      );
      return;
    }
    
    // Toggle like status based on current state
    if (comment.isLikedByCurrentUser) {
      _handleUnlikeComment(comment);
    } else {
      _handleLikeComment(comment);
    }
  }
  
  /// Handle copying a comment to clipboard
  void _handleCopyComment(PostComment comment) {
    Clipboard.setData(ClipboardData(text: comment.content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comment copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Post summary (optional)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage:
                      widget.post.author != null
                          ? _isValidImageUrl(widget.post.author?.avatarUrl)
                              ? NetworkImage(_storageUtils.getImageUrl(widget.post.author!.avatarUrl!))
                              : _isValidImageUrl(widget.post.userAvatar)
                                  ? NetworkImage(_storageUtils.getImageUrl(widget.post.userAvatar!))
                                  : null
                          : null,
                  child: (!_isValidImageUrl(widget.post.author?.avatarUrl) &&
                          !_isValidImageUrl(widget.post.userAvatar))
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.author?.displayName ??
                            widget.post.userName ??
                            'User',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.post.content,
                        style: const TextStyle(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(thickness: 1),

          // Comments list
          Expanded(
            child: BlocBuilder<CommentsBloc, CommentsState>(
              bloc: _commentsBloc,
              builder: (context, state) {
                if (state is CommentsLoading) {
                  return const Center(child: LoadingIndicator());
                } else if (state is CommentsError) {
                  return ErrorMessageWidget(
                    message: state.message,
                    onRetry: _loadComments,
                  );
                } else if (state is CommentsLoaded) {
                  return RefreshIndicator(
                    onRefresh: () async => _loadComments(),
                    child: ListView(
                      children: [
                        CommentListWidget(
                          comments: state.comments,
                          onReply: _showReplyModal,
                          onEdit: _showEditCommentModal,
                          onDelete: _showDeleteCommentDialog,
                          onLike: _toggleCommentLike,
                          onCopy: _handleCopyComment,
                          onReport: (comment) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Comment reported')),
                            );
                          },
                          onHide: (comment) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Comment hidden')),
                            );
                          },
                        ),
                        // Add some padding at the bottom for the input field
                        const SizedBox(height: 80),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      // Comment input at the bottom
      bottomSheet: CommentInputWidget(
        postId: widget.post.id,
        onSubmit: _handleCommentSubmit,
      ),
    );
  }

  @override
  void dispose() {
    _commentsBloc.close();
    super.dispose();
  }
}
