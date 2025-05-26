import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:immigru/features/profile/domain/entities/user_profile.dart';
import 'package:immigru/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:immigru/features/profile/presentation/bloc/profile_event.dart';
import 'package:immigru/features/profile/presentation/bloc/profile_state.dart';
import 'package:immigru/features/profile/presentation/widgets/profile_header.dart';
import 'package:immigru/features/profile/presentation/widgets/profile_info_section.dart';
import 'package:immigru/features/profile/presentation/widgets/profile_stats_section.dart';
import 'package:immigru/features/profile/presentation/widgets/profile_tabs.dart';
import 'package:immigru/shared/widgets/loading_indicator.dart';
import 'package:immigru/shared/widgets/error_message_widget.dart';

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

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load the user profile and stats when the screen is first shown
    _loadProfileData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      debugPrint('ProfileBloc not available in this context: $e');
    }
  }

  /// Handle refreshing the profile data
  Future<void> _onRefresh() async {
    final bloc = context.read<ProfileBloc>();
    
    // Load user profile
    bloc.add(LoadUserProfile(
      userId: widget.userId,
      bypassCache: true,
    ));
    
    // Load user stats
    bloc.add(LoadUserStats(
      userId: widget.userId,
      bypassCache: true,
    ));
    
    // Load user posts
    bloc.add(LoadUserPosts(
      userId: widget.userId,
      bypassCache: true,
    ));
    
    // Wait for a short time to simulate the refresh
    await Future.delayed(const Duration(milliseconds: 500));
  }

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

  /// Pick and upload a new cover image
  Future<void> _pickAndUploadCoverImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    
    if (image != null) {
      if (!mounted) return;
      
      context.read<ProfileBloc>().add(UploadCoverImage(
        userId: widget.userId,
        filePath: image.path,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    // We'll always wrap the screen content with a BlocProvider to ensure
    // the ProfileBloc is available to all children, including ProfilePostsTab
    return BlocProvider<ProfileBloc>.value(
      // Use the existing ProfileBloc from the parent if available, otherwise create a new one
      value: _getOrCreateProfileBloc(context),
      child: _buildScreenContent(),
    );
  }
  
  /// Get an existing ProfileBloc or create a new one if not available
  ProfileBloc _getOrCreateProfileBloc(BuildContext context) {
    try {
      // Try to get the existing ProfileBloc from the parent context
      final bloc = context.read<ProfileBloc>();
      
      // Check if the bloc is already initialized for this user
      // If not, we need to load the data for this specific user
      if (bloc.state.profile == null || bloc.state.profile?.user.id != widget.userId) {
        debugPrint('ProfileBloc exists but needs to be initialized for user: ${widget.userId}');
        
        // Load data for this specific user
        bloc.add(LoadUserProfile(userId: widget.userId));
        bloc.add(LoadUserStats(userId: widget.userId));
        
        // Force a fresh load of posts with bypass cache to avoid serialization issues
        bloc.add(LoadUserPosts(
          userId: widget.userId,
          bypassCache: true,
          limit: 10,
        ));
      }
      
      return bloc;
    } catch (e) {
      // If not available, create a new one using GetIt
      debugPrint('Creating new ProfileBloc for ProfileScreen: ${widget.userId}');
      
      // Import GetIt to access the service locator
      final profileBloc = GetIt.instance<ProfileBloc>();
      
      // Initialize the bloc with the required data for this specific user
      profileBloc.add(LoadUserProfile(userId: widget.userId));
      profileBloc.add(LoadUserStats(userId: widget.userId));
      
      // Force a fresh load of posts with bypass cache to avoid serialization issues
      profileBloc.add(LoadUserPosts(
        userId: widget.userId,
        bypassCache: true,
        limit: 10,
      ));
      
      return profileBloc;
    }
  }
  
  /// Build the main content of the screen
  Widget _buildScreenContent() {
    return Scaffold(
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state.isLoading && state.profile == null) {
            return const Center(child: LoadingIndicator());
          }
          
          if (state.error != null && state.profile == null) {
            return ErrorMessageWidget(
              message: state.error!.message,
              onRetry: _loadProfileData,
            );
          }
          
          final UserProfile? profile = state.profile;
          if (profile == null) {
            return const Center(
              child: Text('Profile not found'),
            );
          }
          
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      profile.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Cover image
                        ProfileHeader(
                          profile: profile,
                          onTapCoverImage: widget.isCurrentUser ? _pickAndUploadCoverImage : null,
                          isUploadingCover: state.isUploadingCover,
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile avatar and stats
                        ProfileStatsSection(
                          profile: profile,
                          stats: state.stats,
                          isStatsLoading: state.isStatsLoading,
                          onTapAvatar: widget.isCurrentUser ? _pickAndUploadAvatar : null,
                          isUploadingAvatar: state.isUploadingAvatar,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Profile info (bio, location, etc.)
                        ProfileInfoSection(
                          profile: profile,
                          isCurrentUser: widget.isCurrentUser,
                        ),
                        
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                
                // Tabs for posts, media, etc.
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      // Let the TabBarTheme from the app theme handle the styling
                      // This will automatically adapt to light/dark mode
                      tabs: const [
                        Tab(text: 'Posts'),
                        Tab(text: 'Media'),
                        Tab(text: 'Likes'),
                      ],
                    ),
                  ),
                  pinned: true,
                ),
                
                // Tab content
                SliverFillRemaining(
                  child: ProfileTabs(
                    tabController: _tabController,
                    userId: widget.userId,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Delegate for the sliver app bar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
