import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:immigru/features/home/domain/entities/post.dart';
import 'package:immigru/features/home/domain/entities/post_comment.dart';
import 'package:immigru/features/home/presentation/bloc/comments/comments_bloc.dart';
import 'package:immigru/features/home/presentation/widgets/comment_input_widget.dart';
import 'package:immigru/features/home/presentation/widgets/comment_list_widget.dart';
import 'package:immigru/shared/widgets/error_message_widget.dart';
import 'package:immigru/shared/widgets/loading_indicator.dart';

/// Screen to display and manage comments for a post
class PostCommentsScreen extends StatefulWidget {
  /// Post to show comments for
  final Post post;

  /// Current user ID
  final String userId;

  /// Create a new PostCommentsScreen
  const PostCommentsScreen({
    Key? key,
    required this.post,
    required this.userId,
  }) : super(key: key);

  @override
  State<PostCommentsScreen> createState() => _PostCommentsScreenState();
}

class _PostCommentsScreenState extends State<PostCommentsScreen> {
  late CommentsBloc _commentsBloc;
  PostComment? _replyingTo;

  @override
  void initState() {
    super.initState();
    _commentsBloc = GetIt.instance<CommentsBloc>();
    _loadComments();
  }
  
  /// Validates if the provided URL is a valid image URL
  bool _isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    if (url == 'custom') return false; // Filter out invalid 'custom' URL
    
    // Basic URL validation
    return url.startsWith('http://') || url.startsWith('https://') || url.startsWith('data:image/');
  }

  void _loadComments() {
    _commentsBloc.add(LoadComments(postId: widget.post.id));
  }

  Future<void> _handleCommentSubmit(String content, String? parentCommentId) async {
    _commentsBloc.add(
      CreateComment(
        postId: widget.post.id,
        userId: widget.userId,
        content: content,
        parentCommentId: parentCommentId,
      ),
    );

    // If this was a reply in a modal, close the modal
    if (_replyingTo != null) {
      Navigator.of(context).pop();
      _replyingTo = null;
    }
    
    return Future.value();
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
                  backgroundImage: _isValidImageUrl(widget.post.author?.avatarUrl)
                      ? NetworkImage(widget.post.author!.avatarUrl!)
                      : _isValidImageUrl(widget.post.userAvatar)
                          ? NetworkImage(widget.post.userAvatar!)
                          : null,
                  child: (!_isValidImageUrl(widget.post.author?.avatarUrl) && !_isValidImageUrl(widget.post.userAvatar))
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.author?.displayName ?? widget.post.userName ?? 'User',
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
