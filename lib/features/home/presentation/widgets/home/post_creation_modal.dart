import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/auth/domain/entities/user.dart';
import 'package:immigru/features/home/domain/entities/post_media.dart';
import 'package:immigru/features/home/presentation/bloc/home_bloc.dart';
import 'package:immigru/features/home/presentation/bloc/home_event.dart';
import 'package:immigru/features/home/presentation/bloc/post_creation/post_creation_bloc.dart';
import 'package:immigru/features/home/presentation/screens/post_creation_screen.dart';

/// Modal wrapper for post creation
class PostCreationModal extends StatelessWidget {
  final User user;
  final HomeBloc homeBloc;
  final Function(String, String, List<PostMedia>) onPost;

  const PostCreationModal({
    super.key,
    required this.user,
    required this.homeBloc,
    required this.onPost,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // Pass the onPost callback directly to the PostCreationScreen
    void handlePost(String content, String category, List<PostMedia> media) {
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

/// Show the post creation modal
void showPostCreationModal({
  required BuildContext context,
  required User user,
  required HomeBloc homeBloc,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (modalContext) {
      return PostCreationModal(
        user: user,
        homeBloc: homeBloc,
        onPost: (content, category, mediaItems) {
          // Extract the first media URL if available for backward compatibility with HomeBloc
          final String? firstMediaUrl =
              mediaItems.isNotEmpty ? mediaItems.first.path : null;

          // Create the post using the captured HomeBloc
          homeBloc.add(
            CreatePost(
              content: content,
              userId: user.id,
              category: category,
              imageUrl: firstMediaUrl,
            ),
          );

          HapticFeedback.mediumImpact();
          Navigator.pop(modalContext);

          // Show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post created successfully!')),
          );
        },
      );
    },
  );
}
