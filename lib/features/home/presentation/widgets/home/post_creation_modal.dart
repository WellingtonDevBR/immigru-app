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
  late PostCreationBloc _postCreationBloc;

  @override
  void initState() {
    super.initState();
    _postCreationBloc = PostCreationBloc();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _postCreationBloc.close();
    super.dispose();
  }
  
  /// Check if there's unsaved content in the post creation form
  bool hasUnsavedContent() {
    final state = _postCreationBloc.state;
    return state.content.trim().isNotEmpty || state.media.isNotEmpty;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    _logger.d('Building PostCreationModal for home feed', 
        tag: 'PostCreationModal');

    // When keyboard is visible, we don't set a fixed height to allow the modal to resize with keyboard
    // This ensures all content remains visible
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Container(
        // Don't set a fixed height to allow content to be fully visible
        constraints: BoxConstraints(
          maxHeight: isKeyboardVisible ? screenHeight * 0.6 : screenHeight * 0.5,
        ),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: BlocProvider(
          create: (context) => _postCreationBloc,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with drag handle
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              // Main content
              Flexible(
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
            ],
          ),
        ),
      ),
    );
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
  
  // Create a key to access the modal state for confirmation dialog
  final GlobalKey<_PostCreationModalState> modalKey = GlobalKey<_PostCreationModalState>();
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    enableDrag: true,
    isDismissible: true, // Allow dismissal by tapping outside
    // Handle modal close attempts with confirmation if needed
    routeSettings: RouteSettings(
      name: 'post_creation_modal',
      arguments: {'checkUnsavedContent': true},
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => PopScope(
      // This will intercept back button and outside taps
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        
        // Get the modal state to check for unsaved content
        final PostCreationBloc bloc = BlocProvider.of<PostCreationBloc>(context);
        final state = bloc.state;
        
        // Check if there's any unsaved content
        final hasUnsavedContent = state.content.trim().isNotEmpty || state.media.isNotEmpty;
        
        if (hasUnsavedContent) {
          // Show confirmation dialog if there's unsaved content
          final shouldDiscard = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Discard post?'),
              content: const Text('You have unsaved content. Are you sure you want to discard this post?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false), // Don't discard
                  child: const Text('Keep editing'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true), // Discard
                  child: const Text('Discard'),
                ),
              ],
            ),
          ) ?? false;
          
          if (shouldDiscard) {
            // If user confirms discard, close the modal
            if (context.mounted) Navigator.of(context).pop();
          }
        } else {
          // No unsaved content, just close the modal
          if (context.mounted) Navigator.of(context).pop();
        }
      },
      child: PostCreationModal(
        key: modalKey,
        user: user,
        homeBloc: homeBloc,
      ),
    ),
  );
}
