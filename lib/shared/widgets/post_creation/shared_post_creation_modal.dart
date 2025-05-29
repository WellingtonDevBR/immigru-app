import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/features/auth/domain/entities/user.dart';
import 'package:immigru/features/home/domain/entities/post_media.dart';
import 'package:immigru/features/home/presentation/bloc/post_creation/post_creation_bloc.dart';
import 'package:immigru/shared/widgets/post_creation/post_creation_screen.dart';
import 'package:immigru/shared/theme/app_colors.dart';
import 'package:get_it/get_it.dart';

/// A shared modal component for post creation that can be used across different screens
/// This component is designed to be reusable in profile, home, and community pages
/// 
/// This modal follows the clean architecture principles and is designed to be
/// used across different features (home, profile, community) while maintaining
/// a consistent user experience and behavior.
class SharedPostCreationModal extends StatelessWidget {
  /// The current user creating the post
  final User user;
  
  /// Callback when a post is submitted
  /// Parameters: content, category, mediaItems
  final Function(String, String, List<PostMedia>) onPost;

  final UnifiedLogger _logger = GetIt.instance<UnifiedLogger>();

  SharedPostCreationModal({
    super.key,
    required this.user,
    required this.onPost,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    _logger.d('Building SharedPostCreationModal', 
        tag: 'SharedPostCreationModal');

    // Pass the onPost callback directly to the PostCreationScreen
    void handlePost(String content, String category, List<PostMedia> media) {
      _logger.d('Post submitted with ${media.length} media items', 
          tag: 'SharedPostCreationModal');
      onPost(content, category, media);
    }

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(bottom: keyboardHeight),
      curve: Curves.easeOut,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: BlocProvider(
          create: (context) => PostCreationBloc(),
          child: PostCreationScreen(
            user: user,
            scrollController: ScrollController(),
            onPost: handlePost,
          ),
        ),
      ),
    );
  }
}

/// Show the shared post creation modal
/// This function can be called from any screen that needs post creation functionality
/// 
/// This modal can be used across different features (home, profile, community)
/// while maintaining a consistent user experience and behavior.
/// 
/// Example usage:
/// ```dart
/// showSharedPostCreationModal(
///   context: context,
///   user: currentUser,
///   onPostCreated: (content, category, mediaItems) {
///     // Handle the created post
///   },
/// );
/// ```
void showSharedPostCreationModal({
  required BuildContext context,
  required User user,
  required Function(String, String, List<PostMedia>) onPostCreated,
  String? sourceFeature, // Optional parameter to track which feature is using this modal
}) {
  final logger = GetIt.instance<UnifiedLogger>();
  logger.d('Showing SharedPostCreationModal from ${sourceFeature ?? 'unknown source'}', 
      tag: 'showSharedPostCreationModal');

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    enableDrag: true,
    elevation: 8,
    transitionAnimationController: AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 300),
    ),
    builder: (modalContext) {
      return SharedPostCreationModal(
        user: user,
        onPost: (content, category, mediaItems) {
          // Call the provided callback with all the post data
          onPostCreated(content, category, mediaItems);
          
          HapticFeedback.mediumImpact();
          Navigator.pop(modalContext);

          // Show a success message with custom styling
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text(
                    'Post created successfully!',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              backgroundColor: AppColors.sproutGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(12),
              duration: const Duration(seconds: 3),
            ),
          );
        },
      );
    },
  );
}
