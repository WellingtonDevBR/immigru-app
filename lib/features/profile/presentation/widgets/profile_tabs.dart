import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/auth/domain/entities/user.dart';
import 'package:immigru/features/media/presentation/bloc/media_bloc.dart';
import 'package:immigru/features/media/presentation/bloc/media_event.dart';
import 'package:immigru/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:immigru/features/profile/presentation/bloc/profile_event.dart';
import 'package:immigru/features/profile/presentation/widgets/profile_posts_tab.dart';

/// Widget for displaying the profile tabs content
class ProfileTabs extends StatefulWidget {
  /// Tab controller for managing the tabs
  final TabController tabController;

  /// ID of the user whose content to display
  final String userId;

  /// Whether to disable scrolling within the tabs
  final bool disableScrolling;

  /// The user entity for the profile
  final User user;

  /// Whether this is the current user's profile
  final bool isCurrentUser;

  /// Constructor
  const ProfileTabs({
    super.key,
    required this.tabController,
    required this.userId,
    required this.user,
    required this.isCurrentUser,
    this.disableScrolling = false,
  });

  @override
  State<ProfileTabs> createState() => _ProfileTabsState();
}

class _ProfileTabsState extends State<ProfileTabs> {
  @override
  void initState() {
    super.initState();

    // Load the user's posts when the widget is first shown
    _loadUserPosts();

    // Add listener to reload content when tab changes
    widget.tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_handleTabChange);
    super.dispose();
  }

  /// Handle tab change events
  void _handleTabChange() {
    if (!widget.tabController.indexIsChanging) {
      switch (widget.tabController.index) {
        case 0: // Posts tab
          _loadUserPosts();
          break;
        case 1: // Media tab
          _loadUserMedia();
          break;
        case 2: // Likes tab
          _loadUserLikes();
          break;
      }
    }
  }

  /// Load the user's posts
  void _loadUserPosts() {
    debugPrint('ProfileTabs: Loading posts for user ${widget.userId}');

    // Add a small delay to ensure the ProfileBloc is fully initialized
    Future.microtask(() {
      if (mounted) {
        try {
          context.read<ProfileBloc>().add(LoadUserPosts(
                userId: widget.userId,
                bypassCache: true,
              ));
        } catch (e) {
          debugPrint('Error loading user posts in ProfileTabs: $e');
          // Try again after a short delay
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              context.read<ProfileBloc>().add(LoadUserPosts(
                    userId: widget.userId,
                    bypassCache: true,
                  ));
            }
          });
        }
      }
    });
  }

  /// Load the user's media posts
  void _loadUserMedia() {
    // Load the user's albums using the MediaBloc
    Future.microtask(() {
      if (mounted) {
        try {
          final mediaBloc = context.read<MediaBloc>();
          mediaBloc.add(LoadUserAlbums(userId: widget.userId));
        } catch (e) {
          debugPrint('Error loading user media in ProfileTabs: $e');
          // Try again after a short delay
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              final mediaBloc = context.read<MediaBloc>();
              mediaBloc.add(LoadUserAlbums(userId: widget.userId));
            }
          });
        }
      }
    });
  }

  /// Load the posts liked by the user
  void _loadUserLikes() {
    // TODO: Implement this when HomeBloc supports user liked posts
    // For now, we'll just show a placeholder
  }

  // Removed unused _buildPlaceholderContent method

  @override
  Widget build(BuildContext context) {
    // Use a listener to handle tab changes instead of directly using the index
    // This ensures we load the appropriate content when tabs change
    return ProfilePostsTab(
      userId: widget.userId,
      disableScrolling: widget.disableScrolling,
    );
  }
}
