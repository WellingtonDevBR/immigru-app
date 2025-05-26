import 'package:dartz/dartz.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/profile/domain/entities/user_profile.dart';
import 'package:immigru/features/profile/domain/repositories/user_profile_repository.dart';

/// Use case for getting a user profile
class GetUserProfileUseCase {
  final UserProfileRepository repository;

  /// Constructor
  GetUserProfileUseCase(this.repository);

  /// Execute the use case
  /// 
  /// [userId] - ID of the user whose profile to fetch
  /// [bypassCache] - Whether to bypass the cache and fetch fresh data
  Future<Either<Failure, UserProfile>> call({
    required String userId,
    bool bypassCache = false,
  }) {
    return repository.getUserProfile(
      userId: userId,
      bypassCache: bypassCache,
    );
  }
}
