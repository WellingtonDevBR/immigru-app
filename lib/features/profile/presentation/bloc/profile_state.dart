import 'package:equatable/equatable.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/home/domain/entities/post.dart';
import 'package:immigru/features/profile/domain/entities/user_profile.dart';

/// Base class for all profile states
class ProfileState extends Equatable {
  /// Current user profile data
  final UserProfile? profile;
  
  /// Whether the profile is currently loading
  final bool isLoading;
  
  /// Any error that occurred
  final Failure? error;
  
  /// User stats (posts, followers, following)
  final Map<String, int>? stats;
  
  /// Whether stats are currently loading
  final bool isStatsLoading;
  
  /// Any error that occurred while loading stats
  final Failure? statsError;
  
  /// Whether an avatar upload is in progress
  final bool isUploadingAvatar;
  
  /// Any error that occurred during avatar upload
  final Failure? avatarUploadError;
  
  /// Whether a cover image upload is in progress
  final bool isUploadingCover;
  
  /// Any error that occurred during cover image upload
  final Failure? coverUploadError;

  /// User posts
  final List<Post>? userPosts;
  
  /// Whether posts are currently loading
  final bool isPostsLoading;
  
  /// Any error that occurred while loading posts
  final Failure? postsError;
  
  /// Whether there are more posts to load
  final bool hasMorePosts;
  
  /// Flag to indicate that profile scrolling should be enabled
  /// This is used when double pull-to-refresh is detected in posts tab
  final bool shouldEnableProfileScrolling;

  /// Constructor
  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
    this.stats,
    this.isStatsLoading = false,
    this.statsError,
    this.isUploadingAvatar = false,
    this.avatarUploadError,
    this.isUploadingCover = false,
    this.coverUploadError,
    this.userPosts,
    this.isPostsLoading = false,
    this.postsError,
    this.hasMorePosts = true,
    this.shouldEnableProfileScrolling = false,
  });

  /// Initial state
  factory ProfileState.initial() => const ProfileState();

  /// Create a copy of this state with the given fields replaced with new values
  ProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    Failure? error,
    bool clearError = false,
    Map<String, int>? stats,
    bool? isStatsLoading,
    Failure? statsError,
    bool clearStatsError = false,
    bool? isUploadingAvatar,
    Failure? avatarUploadError,
    bool clearAvatarUploadError = false,
    bool? isUploadingCover,
    Failure? coverUploadError,
    bool clearCoverUploadError = false,
    List<Post>? userPosts,
    bool? isPostsLoading,
    Failure? postsError,
    bool clearPostsError = false,
    bool? hasMorePosts,
    bool? shouldEnableProfileScrolling,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      stats: stats ?? this.stats,
      isStatsLoading: isStatsLoading ?? this.isStatsLoading,
      statsError: clearStatsError ? null : statsError ?? this.statsError,
      isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar,
      avatarUploadError: clearAvatarUploadError ? null : avatarUploadError ?? this.avatarUploadError,
      isUploadingCover: isUploadingCover ?? this.isUploadingCover,
      coverUploadError: clearCoverUploadError ? null : coverUploadError ?? this.coverUploadError,
      userPosts: userPosts ?? this.userPosts,
      isPostsLoading: isPostsLoading ?? this.isPostsLoading,
      postsError: clearPostsError ? null : (postsError ?? this.postsError),
      hasMorePosts: hasMorePosts ?? this.hasMorePosts,
      shouldEnableProfileScrolling: shouldEnableProfileScrolling ?? this.shouldEnableProfileScrolling,
    );
  }

  @override
  List<Object?> get props => [
    profile,
    isLoading,
    error,
    stats,
    isStatsLoading,
    statsError,
    isUploadingAvatar,
    avatarUploadError,
    isUploadingCover,
    coverUploadError,
    userPosts,
    isPostsLoading,
    postsError,
    hasMorePosts,
    shouldEnableProfileScrolling,
  ];
}
