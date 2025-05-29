import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  /// Constructor
  const ProfileTabs({
    super.key,
    required this.tabController,
    required this.userId,
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
    // TODO: Implement this when HomeBloc supports user media posts
    // For now, we'll just show a placeholder
  }

  /// Load the posts liked by the user
  void _loadUserLikes() {
    // TODO: Implement this when HomeBloc supports user liked posts
    // For now, we'll just show a placeholder
  }

  /// Build a placeholder content widget with theme-aware styling
  Widget _buildPlaceholderContent({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String message,
  }) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: widget.tabController,
      physics:
          widget.disableScrolling ? const NeverScrollableScrollPhysics() : null,
      children: [
        // Posts tab
        ProfilePostsTab(
          userId: widget.userId,
          disableScrolling: widget.disableScrolling,
        ),

        // Media tab
        _buildPlaceholderContent(
          context: context,
          icon: Icons.image_outlined,
          title: 'User Media',
          message: 'This is where the user\'s photos and videos will appear.',
        ),

        // Likes tab
        _buildPlaceholderContent(
          context: context,
          icon: Icons.favorite_outline,
          title: 'User Likes',
          message: 'This is where the posts liked by the user will appear.',
        ),
      ],
    );
  }
}
