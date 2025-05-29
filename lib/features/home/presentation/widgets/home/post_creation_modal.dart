import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/auth/domain/entities/user.dart';
import 'package:immigru/features/home/domain/entities/post_media.dart';
import 'package:immigru/features/home/presentation/bloc/home_bloc.dart';
import 'package:immigru/features/home/presentation/bloc/home_event.dart';
import 'package:immigru/features/home/presentation/bloc/post_creation/post_creation_bloc.dart';
import 'package:immigru/shared/widgets/post_creation/post_creation_screen.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:get_it/get_it.dart';

/// Modal wrapper for post creation in the home feed
/// This uses the shared post creation screen for a consistent experience
class PostCreationModal extends StatefulWidget {
  final User user;
  final HomeBloc homeBloc;
  
  const PostCreationModal({
    super.key,
    required this.user,
    required this.homeBloc,
  });

  @override
  State<PostCreationModal> createState() => _PostCreationModalState();
}

class _PostCreationModalState extends State<PostCreationModal> {
  final UnifiedLogger _logger = GetIt.instance<UnifiedLogger>();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    _logger.d('Building PostCreationModal for home feed', 
        tag: 'PostCreationModal');

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(bottom: keyboardHeight),
      curve: Curves.easeOut,
      child: BlocProvider(
        create: (context) => PostCreationBloc(),
        child: PostCreationScreen(
          user: widget.user,
          scrollController: _scrollController,
          onPost: (content, category, media) {
            _logger.d('Post submitted from home feed with ${media.length} media items', 
                tag: 'PostCreationModal');
            
            // First close the modal
            Navigator.pop(context);
            
            // Then create the post after the modal is closed
            _createPost(content, category, media);
          },
        ),
      ),
    );
  }
  
  /// Create a post after the modal is closed to avoid bloc closed errors
  void _createPost(String content, String category, List<PostMedia> media) {
    // Use a slight delay to ensure the modal is fully closed
    Future.delayed(const Duration(milliseconds: 100), () {
      _logger.d('Creating post with ${media.length} media items', 
          tag: 'PostCreationModal');
          
      // Create the post using the HomeBloc with all media items
      widget.homeBloc.add(
        CreatePost(
          content: content,
          userId: widget.user.id,
          category: category,
          imageUrl: media.isNotEmpty ? media.first.path : null,
          media: media,
        ),
      );
      
      _logger.d('Post added to home feed with ${media.length} media items', 
          tag: 'PostCreationModal');
    });
  }
}

/// Show the post creation modal for the home feed
/// This uses the shared post creation screen for a consistent experience
void showPostCreationModal({
  required BuildContext context,
  required User user,
  required HomeBloc homeBloc,
}) {
  HapticFeedback.mediumImpact();
  
  final logger = GetIt.instance<UnifiedLogger>();
  logger.d('Showing post creation modal for home feed', tag: 'showPostCreationModal');

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (context) => PostCreationModal(
      user: user,
      homeBloc: homeBloc,
    ),
  );
}
