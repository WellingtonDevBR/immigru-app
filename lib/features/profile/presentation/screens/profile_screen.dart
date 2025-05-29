import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:immigru/core/config/url_builder.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:immigru/features/home/presentation/bloc/home_bloc.dart';
import 'package:immigru/features/home/presentation/bloc/home_event.dart';
import 'package:immigru/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:immigru/features/profile/presentation/bloc/profile_event.dart';
import 'package:immigru/features/profile/presentation/bloc/profile_state.dart';
import 'package:immigru/features/profile/presentation/widgets/profile_tabs.dart';
import 'package:immigru/shared/widgets/post_creation/shared_post_creation_modal.dart';
import 'package:immigru/shared/widgets/loading_indicator.dart';
import 'package:immigru/shared/widgets/error_message_widget.dart';
import 'package:immigru/shared/theme/app_colors.dart';
import 'package:get_it/get_it.dart';

/// Screen for displaying a user's profile
class ProfileScreen extends StatefulWidget {
  /// ID of the user whose profile to display
  final String userId;

  /// Whether this is the current user's profile
  final bool isCurrentUser;

  /// Constructor
  const ProfileScreen({
    super.key,
    required this.userId,
    this.isCurrentUser = false,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

/// The state for the profile screen
class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _imagePicker = ImagePicker();
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  // For collapsible app bar and animations
  double _titleOpacity = 0.0;
  double _headerOpacity = 1.0;
  double _appBarElevation = 0.0;
  bool _enablePostsScrolling = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
    _loadProfileData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  /// Show the post creation modal
  void _showPostCreationModal(BuildContext context, ProfileState state) {
    // Get the current user from the auth bloc
    final authBloc = BlocProvider.of<AuthBloc>(context);
    final currentUser = authBloc.state.user;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to create a post')),
      );
      return;
    }

    // Use the shared post creation modal
    showSharedPostCreationModal(
      context: context,
      user: currentUser,
      onPostCreated: (content, category, mediaItems) {
        // Extract the first media URL if available
        final String? firstMediaUrl =
            mediaItems.isNotEmpty ? mediaItems.first.path : null;

        // Get the HomeBloc to create the post
        final homeBloc = GetIt.instance<HomeBloc>();
        homeBloc.add(
          CreatePost(
            content: content,
            userId: currentUser.id,
            category: category,
            imageUrl: firstMediaUrl,
          ),
        );

        // Refresh the profile posts after creating a new post
        context.read<ProfileBloc>().add(LoadUserPosts(
              userId: widget.userId,
              offset: 0,
              limit: 10,
              bypassCache: true,
            ));
      },
    );
  }

  /// Handle scrolling to control app bar appearance and load more posts
  void _onScroll() {
    // Calculate scroll progress for animations
    final scrollOffset = _scrollController.offset;
    final backgroundThreshold = 160.0; // When to start showing solid background
    final postsScrollThreshold = 220.0; // When to enable posts scrolling (reduced threshold)
    final maxElevation = 4.0;

    // Calculate opacity values based on scroll position
    double newTitleOpacity = 0.0;
    double newHeaderOpacity = 1.0;
    double newElevation = 0.0;
    
    // Once we've scrolled past the threshold, always enable posts scrolling
    // This prevents the screen from pulling back up when scrolling slowly
    bool newEnablePostsScrolling = scrollOffset > postsScrollThreshold;
    
    // If we're already in posts scrolling mode, don't disable it unless we're at the very top
    // This creates a strong hysteresis effect to prevent toggling back and forth
    if (_enablePostsScrolling) {
      newEnablePostsScrolling = scrollOffset > 50.0;
    }

    if (scrollOffset > backgroundThreshold) {
      // Calculate title opacity (0 to 1) - make it appear faster
      newTitleOpacity =
          ((scrollOffset - backgroundThreshold) / 40.0).clamp(0.0, 1.0);

      // Calculate header opacity (1 to 0)
      newHeaderOpacity =
          (1.0 - (scrollOffset - backgroundThreshold) / 40.0).clamp(0.0, 1.0);

      // Calculate app bar elevation (0 to 4)
      newElevation = ((scrollOffset - backgroundThreshold) / 20.0)
          .clamp(0.0, maxElevation);
    }

    // Update state if values changed
    if (newTitleOpacity != _titleOpacity ||
        newHeaderOpacity != _headerOpacity ||
        newElevation != _appBarElevation ||
        newEnablePostsScrolling != _enablePostsScrolling) {
      setState(() {
        _titleOpacity = newTitleOpacity;
        _headerOpacity = newHeaderOpacity;
        _appBarElevation = newElevation;
        _enablePostsScrolling = newEnablePostsScrolling;
      });
    }

    _loadMorePostsIfNeeded();
  }

  /// Check if we need to load more posts based on scroll position
  void _loadMorePostsIfNeeded() {
    // Don't process if we're already loading more posts
    if (_isLoadingMore) return;

    // Make sure we have a valid scroll position
    if (!_scrollController.hasClients) return;

    // Check if we're near the bottom of the scroll view (trigger at 70% of scroll extent to load earlier)
    final threshold = 0.7 * _scrollController.position.maxScrollExtent;

    if (_scrollController.position.pixels >= threshold) {
      // Get the current tab index
      final currentTabIndex = _tabController.index;

      // Only load more posts if we're on the posts tab (index 0)
      if (currentTabIndex == 0) {
        // Check the current state to determine if we should load more
        final state = context.read<ProfileBloc>().state;

        // Only attempt to load more if:
        // 1. Not currently loading
        // 2. Has more posts to load
        // 3. Not already in an error state
        if (!state.isPostsLoading &&
            state.hasMorePosts &&
            state.postsError == null) {
          debugPrint(
              'Loading more posts at scroll position: ${_scrollController.position.pixels}');
          debugPrint(
              'Current post count: ${state.userPosts?.length}, hasMore: ${state.hasMorePosts}');

          // Set flag to prevent multiple calls
          setState(() {
            _isLoadingMore = true;
          });

          // Fetch more posts
          context.read<ProfileBloc>().add(LoadUserPosts(
                userId: widget.userId,
                limit: 10, // Load 10 posts at a time for smoother experience
                offset: state.userPosts?.length ??
                    0, // Start from the current count
                bypassCache: true, // Always get fresh data for pagination
              ));

          // Reset flag after a short delay to prevent rapid successive calls
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                _isLoadingMore = false;
              });

              // Check if we need to try loading again (in case the previous attempt didn't trigger a state change)
              final updatedState = context.read<ProfileBloc>().state;
              if (updatedState.hasMorePosts &&
                  !updatedState.isPostsLoading &&
                  updatedState.postsError == null &&
                  _scrollController.position.pixels >= threshold) {
                debugPrint(
                    'Previous load may not have triggered properly, trying again');
                _loadMorePostsIfNeeded(); // Try again if we're still near the bottom
              }
            }
          });
        } else if (state.postsError != null) {
          // If we're in an error state, show a snackbar with the error and option to retry
          debugPrint('Error loading more posts: ${state.postsError?.message}');

          // Prevent showing multiple snackbars
          setState(() {
            _isLoadingMore = true;
          });

          // Show error message with retry option
          ScaffoldMessenger.of(context)
              .clearSnackBars(); // Clear any existing snackbars
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Failed to load more posts: ${state.postsError?.message}'),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () {
                  // Clear error state and try again
                  context.read<ProfileBloc>().add(const ClearPostsError());

                  // Wait a moment before retrying
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (mounted) {
                      context.read<ProfileBloc>().add(LoadUserPosts(
                            userId: widget.userId,
                            limit: 10,
                            offset: state.userPosts?.length ?? 0,
                            bypassCache: true,
                          ));
                    }
                  });
                },
              ),
              duration: const Duration(seconds: 5),
            ),
          );

          // Reset loading flag after a delay
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) {
              setState(() {
                _isLoadingMore = false;
              });
            }
          });
        }
      }
    }
  }

  /// Load the user profile, stats, and posts
  void _loadProfileData() {
    try {
      // Check if the bloc is available before using it
      final bloc = context.read<ProfileBloc>();

      // Load user profile
      bloc.add(LoadUserProfile(
        userId: widget.userId,
      ));

      // Load user stats
      bloc.add(LoadUserStats(
        userId: widget.userId,
      ));

      // Load user posts
      bloc.add(LoadUserPosts(
        userId: widget.userId,
      ));
    } catch (e) {
      // If the bloc is not available, it means it's being provided by the parent
      // This is expected when navigating from the drawer
    }
  }

  // We're not using _onRefresh anymore as we're using CustomScrollView
  // which provides its own refresh mechanism

  /// Pick and upload a new avatar image
  Future<void> _pickAndUploadAvatar() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      if (!mounted) return;

      context.read<ProfileBloc>().add(UploadAvatar(
            userId: widget.userId,
            filePath: image.path,
          ));
    }
  }

  /// Pick and upload a new cover image with modern UI
  Future<void> _pickAndUploadCoverImage() async {
    // Capture the ProfileBloc instance and profile state before showing the bottom sheet
    final profileBloc = context.read<ProfileBloc>();
    final hasExistingCover = profileBloc.state.profile?.coverImageUrl != null &&
        profileBloc.state.profile!.coverImageUrl!.isNotEmpty;

    // Show a modern bottom sheet with options for image management
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext bottomSheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Cover Image',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Gallery option
                InkWell(
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);
                    final XFile? image = await _imagePicker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                    );

                    if (image != null && mounted) {
                      profileBloc.add(UploadCoverImage(
                        userId: widget.userId,
                        filePath: image.path,
                      ));
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.photo_library_outlined,
                            color: Colors.blue.shade600,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Choose from Gallery',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Camera option
                InkWell(
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);
                    final XFile? image = await _imagePicker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 80,
                    );

                    if (image != null && mounted) {
                      profileBloc.add(UploadCoverImage(
                        userId: widget.userId,
                        filePath: image.path,
                      ));
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.green.shade600,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Take a Photo',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Only show remove option if there's an existing cover
                if (hasExistingCover)
                  InkWell(
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      profileBloc.add(RemoveCoverImage(
                        userId: widget.userId,
                      ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.delete_outline,
                              color: Colors.red.shade600,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Remove Cover Image',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        // Listen for the shouldEnableProfileScrolling flag
        if (state.shouldEnableProfileScrolling) {
          // Scroll to top and disable posts scrolling
          setState(() {
            _enablePostsScrolling = false;
          });

          // Scroll to the top of the profile with animation
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        }
        // Update display name when profile changes
        if (state.profile != null) {
          // Profile loaded successfully
          // No need to set state here as we'll use profile directly
        }
      },
      builder: (context, state) {
        // Handle loading state
        if (state.isLoading && state.profile == null) {
          return const Scaffold(
            body: Center(child: LoadingIndicator()),
          );
        }

        // Handle error state
        if (state.error != null && state.profile == null) {
          return Scaffold(
            body: Center(
              child: ErrorMessageWidget(
                message: state.error?.message ?? 'An error occurred',
                onRetry: _loadProfileData,
              ),
            ),
          );
        }

        // Handle null profile
        if (state.profile == null) {
          // If we get here, it means profile is null but we're not loading and don't have an error
          // This is an unexpected state, so we should reload the profile data
          _loadProfileData();
          return const Scaffold(
            body: Center(child: LoadingIndicator()),
          );
        }

        // Safe to use profile now - we've already checked it's not null above
        final profile = state.profile!;

        return Scaffold(
          extendBodyBehindAppBar: true, // Allow body to extend behind app bar
          appBar: _titleOpacity > 0.5
              ? null
              : AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.white,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  iconTheme: const IconThemeData(color: Colors.white),
                ),
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Cover image - taller to account for status bar and app bar
                    SizedBox(
                      height: 220, // Increased height to cover app bar area
                      width: double.infinity,
                      child: Stack(
                        children: [
                          // Cover image background
                          Container(
                            height: 220, // Increased height
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColors.cardDark
                                  : AppColors.cardLight,
                              // Add gradient overlay for better text visibility
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.center,
                                colors: [
                                  Colors.black.withValues(
                                      alpha:
                                          0.5), // Slightly darker for better visibility
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: profile.coverImageUrl != null &&
                                    profile.coverImageUrl!.isNotEmpty
                                ? ShaderMask(
                                    shaderCallback: (rect) {
                                      return LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.center,
                                        colors: [
                                          Colors.black.withValues(alpha: 0.8),
                                          Colors.transparent
                                        ],
                                      ).createShader(rect);
                                    },
                                    blendMode: BlendMode.srcATop,
                                    child: Image.network(
                                      UrlBuilder.buildCoverImageUrl(
                                          profile.coverImageUrl!),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: 220,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        // Log the error
                                        debugPrint(
                                            'Failed to load cover image: ${error.toString()}');
                                        // Show a placeholder if image fails to load
                                        return Container(
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? AppColors.surfaceDark
                                              : AppColors.surfaceLight,
                                          child: Center(
                                            child: Icon(Icons.image,
                                                size: 50,
                                                color: AppColors.icon(
                                                    Theme.of(context)
                                                        .brightness)),
                                          ),
                                        );
                                      },
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : Container(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? AppColors.surfaceDark
                                        : AppColors.surfaceLight,
                                    child: Center(
                                      child: Icon(Icons.image,
                                          size: 50,
                                          color: AppColors.icon(
                                              Theme.of(context).brightness)),
                                    ),
                                  ),
                          ),

                          // Cover image upload button (only for current user)
                          if (widget.isCurrentUser)
                            Positioned(
                              right: 16,
                              bottom: 16,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppColors.cardDark
                                          .withValues(alpha: 0.8)
                                      : AppColors.cardLight
                                          .withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.camera_alt,
                                    color: AppColors.primaryColor,
                                    size: 20,
                                  ),
                                  onPressed: state.isUploadingCover
                                      ? null
                                      : _pickAndUploadCoverImage,
                                  tooltip: 'Change cover image',
                                ),
                              ),
                            ),

                          // Loading indicator for cover upload
                          if (state.isUploadingCover)
                            const Positioned.fill(
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Avatar and stats section (with negative margin to overlap cover)
                    Transform.translate(
                      offset: const Offset(0, -60),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Avatar
                            Stack(
                              children: [
                                // Avatar image
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 4,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: profile.avatarUrl != null &&
                                            profile.avatarUrl!.isNotEmpty
                                        ? Image.network(
                                            UrlBuilder.buildAvatarUrl(
                                                profile.avatarUrl!),
                                            fit: BoxFit.cover,
                                            width: 120,
                                            height: 120,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              // Log the error
                                              debugPrint(
                                                  'Failed to load avatar image: ${error.toString()}');
                                              // Use UI Avatars for a better fallback
                                              return Image.network(
                                                UrlBuilder.buildDefaultAvatarUrl(profile.displayName ?? 'User'),
                                                fit: BoxFit.cover,
                                                width: 120,
                                                height: 120,
                                                // Fallback for the fallback
                                                errorBuilder:
                                                    (context, error, stackTrace) {
                                                  return Container(
                                                    color: Colors.grey.shade200,
                                                    child: Icon(
                                                      Icons.person,
                                                      size: 60,
                                                      color:
                                                          Colors.grey.shade400,
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          )
                                        : Image.network(
                                             UrlBuilder.buildDefaultAvatarUrl(profile.displayName ?? 'User'),
                                             fit: BoxFit.cover,
                                             width: 120,
                                             height: 120,
                                             // Fallback for the default avatar
                                             errorBuilder:
                                                 (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey.shade200,
                                                child: Icon(
                                                  Icons.person,
                                                  size: 60,
                                                  color: Colors.grey.shade400,
                                                ),
                                              );
                                            },
                                          ),
                                  ),
                                ),

                                // Avatar upload button (only for current user)
                                if (widget.isCurrentUser)
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        onPressed: state.isUploadingAvatar
                                            ? null
                                            : _pickAndUploadAvatar,
                                        tooltip: 'Change profile picture',
                                        constraints: const BoxConstraints(
                                          minWidth: 36,
                                          minHeight: 36,
                                        ),
                                        padding: const EdgeInsets.all(8),
                                      ),
                                    ),
                                  ),

                                // Loading indicator for avatar upload
                                if (state.isUploadingAvatar)
                                  const Positioned.fill(
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(width: 16),

                            // Stats
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Posts count
                                  _buildStatItem(
                                    context,
                                    state.stats != null
                                        ? state.stats!['posts'] ?? 0
                                        : 0,
                                    'Posts',
                                  ),

                                  // Followers count
                                  _buildStatItem(
                                    context,
                                    state.stats != null
                                        ? state.stats!['followers'] ?? 0
                                        : 0,
                                    'Followers',
                                  ),

                                  // Following count
                                  _buildStatItem(
                                    context,
                                    state.stats != null
                                        ? state.stats!['following'] ?? 0
                                        : 0,
                                    'Following',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Profile info section with display name, bio, etc.
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display name with fade out animation
                          AnimatedOpacity(
                            opacity: _headerOpacity,
                            duration: const Duration(milliseconds: 150),
                            child: Text(
                              profile.displayName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '@${profile.userName}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),

                          // Bio
                          if (profile.bio != null && profile.bio!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                profile.bio!,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),

                          // Edit profile button (only for current user)
                          if (widget.isCurrentUser)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () {
                                    // TODO: Navigate to edit profile screen
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Edit Profile'),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.label,
                    // Use theme-aware background color for the tab bar
                    dividerColor: Colors.transparent,
                    // Use theme-aware background color for the tab bar
                    overlayColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.hovered)) {
                          return Theme.of(context).colorScheme.primary.withOpacity(0.1);
                        }
                        return null;
                      },
                    ),
                    labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                    unselectedLabelStyle:
                        const TextStyle(fontWeight: FontWeight.normal),
                    tabs: const [
                      Tab(text: 'Posts'),
                      Tab(text: 'Media'),
                      Tab(text: 'Likes'),
                    ],
                  ),
                  showTitle: _titleOpacity > 0.5,
                  displayName: profile.displayName,
                ),
                pinned:
                    true, // This makes the tabs stick to the top when scrolling
                floating:
                    true, // This allows the header to float when scrolling up
              ),

              // Tab content
              SliverFillRemaining(
                hasScrollBody: true,
                fillOverscroll: true, // Removes the gap between tabs and content
                child: NotificationListener<ScrollNotification>(
                  // Always prevent scroll notifications from bubbling up to the parent scroll view
                  // This ensures the tab content scrolling is never interrupted
                  onNotification: (notification) {
                    // Always block scroll notifications once we're in the tab content
                    // This prevents the parent scroll view from interfering with tab scrolling
                    return true;
                  },
                  child: ClipRect(
                    child: TabBarView(
                      controller: _tabController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                    // Posts tab
                    ProfileTabs(
                      tabController: _tabController,
                      userId: widget.userId,
                      disableScrolling:
                          !_enablePostsScrolling, // Enable scrolling when header is not visible
                    ),

                    // Media tab
                    const Center(child: Text('Media Coming Soon')),

                    // Likes tab
                    const Center(child: Text('Likes Coming Soon')),
                  ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: widget.isCurrentUser
              ? FloatingActionButton(
                  onPressed: () => _showPostCreationModal(context, state),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  tooltip: 'Create Post',
                  child: const Icon(Icons.add),
                )
              : null,
        );
      },
    );
  }

  /// Build a stat item for the profile stats section
  Widget _buildStatItem(BuildContext context, int count, String label) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

/// Sliver delegate for the tab bar with optional display name
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final bool _showTitle;
  final String _displayName;

  _SliverAppBarDelegate(this._tabBar, {bool showTitle = false, String displayName = ''}) :
    _showTitle = showTitle,
    _displayName = displayName;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Calculate available height for the header
    final headerHeight = _showTitle ? maxExtent - _tabBar.preferredSize.height : 0.0;
    final totalAvailableHeight = maxExtent;
    
    if (_showTitle) {
      // When scrolled down - show header with name and tabs
      return SizedBox(
        height: totalAvailableHeight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Green header with name that respects safe area
            Container(
              width: double.infinity,
              height: headerHeight,
              color: AppColors.primaryColor,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Back button
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        color: Colors.white,
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      // Display name with white text
                      Expanded(
                        child: Text(
                          _displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Tab bar with theme-aware background
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                width: double.infinity,
                child: _tabBar,
              ),
            ),
          ],
        ),
      );
    } else {
      // When at the top - show only tabs
      return Container(
        color: Theme.of(context).colorScheme.surface,
        child: _tabBar,
      );
    }
  }

  @override
  double get maxExtent => _showTitle 
      ? _tabBar.preferredSize.height + 48 // Height with title and safe area
      : _tabBar.preferredSize.height;

  @override
  double get minExtent => _showTitle 
      ? _tabBar.preferredSize.height + 48 // Height with title and safe area
      : _tabBar.preferredSize.height;

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return _showTitle != oldDelegate._showTitle ||
        _displayName != oldDelegate._displayName ||
        _tabBar != oldDelegate._tabBar;
  }
}
