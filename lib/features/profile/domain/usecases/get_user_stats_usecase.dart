import 'package:dartz/dartz.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/profile/domain/repositories/user_profile_repository.dart';

/// Use case for getting user statistics (posts, followers, following)
class GetUserStatsUseCase {
  final UserProfileRepository repository;

  /// Constructor
  GetUserStatsUseCase(this.repository);

  /// Execute the use case
  /// 
  /// [userId] - ID of the user whose stats to fetch
  /// [bypassCache] - Whether to bypass the cache and fetch fresh data
  Future<Either<Failure, Map<String, int>>> call({
    required String userId,
    bool bypassCache = false,
  }) {
    return repository.getUserStats(
      userId: userId,
      bypassCache: bypassCache,
    );
  }
}
