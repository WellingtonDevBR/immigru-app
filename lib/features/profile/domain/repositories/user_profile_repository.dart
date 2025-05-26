import 'package:dartz/dartz.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/profile/domain/entities/user_profile.dart';

/// Repository interface for user profile operations
abstract class UserProfileRepository {
  /// Get a user profile by user ID
  /// 
  /// Returns a [UserProfile] entity on success or a [Failure] on error
  Future<Either<Failure, UserProfile>> getUserProfile({
    required String userId,
    bool bypassCache = false,
  });
  
  /// Update a user profile
  /// 
  /// Returns the updated [UserProfile] entity on success or a [Failure] on error
  Future<Either<Failure, UserProfile>> updateUserProfile({
    required UserProfile profile,
  });
  
  /// Upload a profile avatar
  /// 
  /// Returns the avatar URL on success or a [Failure] on error
  Future<Either<Failure, String>> uploadAvatar({
    required String userId,
    required String filePath,
  });
  
  /// Upload a profile cover image
  /// 
  /// Returns the cover image URL on success or a [Failure] on error
  Future<Either<Failure, String>> uploadCoverImage({
    required String userId,
    required String filePath,
  });
  
  /// Remove a profile cover image
  /// 
  /// Returns true on success or a [Failure] on error
  Future<Either<Failure, bool>> removeCoverImage({
    required String userId,
  });
  
  /// Get user stats (posts count, followers count, following count)
  /// 
  /// Returns a map with the stats on success or a [Failure] on error
  Future<Either<Failure, Map<String, int>>> getUserStats({
    required String userId,
    bool bypassCache = false,
  });
}
