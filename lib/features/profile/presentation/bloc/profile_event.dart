import 'package:equatable/equatable.dart';
import 'package:immigru/features/profile/domain/entities/user_profile.dart';

/// Base class for all profile events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load a user profile
class LoadUserProfile extends ProfileEvent {
  /// ID of the user whose profile to load
  final String userId;
  
  /// Whether to bypass the cache and fetch fresh data
  final bool bypassCache;

  /// Constructor
  const LoadUserProfile({
    required this.userId,
    this.bypassCache = false,
  });

  @override
  List<Object?> get props => [userId, bypassCache];
}

/// Event to update a user profile
class UpdateUserProfile extends ProfileEvent {
  /// The updated profile data
  final UserProfile profile;

  /// Constructor
  const UpdateUserProfile({
    required this.profile,
  });

  @override
  List<Object?> get props => [profile];
}

/// Event to upload a profile avatar
class UploadAvatar extends ProfileEvent {
  /// ID of the user whose avatar to upload
  final String userId;
  
  /// Path to the avatar image file
  final String filePath;

  /// Constructor
  const UploadAvatar({
    required this.userId,
    required this.filePath,
  });

  @override
  List<Object?> get props => [userId, filePath];
}

/// Event to upload a profile cover image
class UploadCoverImage extends ProfileEvent {
  /// ID of the user whose cover image to upload
  final String userId;
  
  /// Path to the cover image file
  final String filePath;

  /// Constructor
  const UploadCoverImage({
    required this.userId,
    required this.filePath,
  });

  @override
  List<Object?> get props => [userId, filePath];
}

/// Event to remove a profile cover image
class RemoveCoverImage extends ProfileEvent {
  /// ID of the user whose cover image to remove
  final String userId;

  /// Constructor
  const RemoveCoverImage({
    required this.userId,
  });

  @override
  List<Object?> get props => [userId];
}

/// Event to load user stats
class LoadUserStats extends ProfileEvent {
  /// ID of the user whose stats to load
  final String userId;
  
  /// Whether to bypass the cache and fetch fresh data
  final bool bypassCache;

  /// Constructor
  const LoadUserStats({
    required this.userId,
    this.bypassCache = false,
  });

  @override
  List<Object?> get props => [userId, bypassCache];
}

/// Event to load user posts
class LoadUserPosts extends ProfileEvent {
  /// ID of the user whose posts to load
  final String userId;
  
  /// Maximum number of posts to load
  final int limit;
  
  /// Offset for pagination
  final int offset;
  
  /// Whether to bypass the cache and fetch fresh data
  final bool bypassCache;

  /// Constructor
  const LoadUserPosts({
    required this.userId,
    this.limit = 10,
    this.offset = 0,
    this.bypassCache = false,
  });

  @override
  List<Object?> get props => [userId, limit, offset, bypassCache];
}
