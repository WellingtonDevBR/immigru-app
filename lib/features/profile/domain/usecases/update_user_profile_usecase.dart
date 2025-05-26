import 'package:dartz/dartz.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/profile/domain/entities/user_profile.dart';
import 'package:immigru/features/profile/domain/repositories/user_profile_repository.dart';

/// Use case for updating a user profile
class UpdateUserProfileUseCase {
  final UserProfileRepository repository;

  /// Constructor
  UpdateUserProfileUseCase(this.repository);

  /// Execute the use case
  /// 
  /// [profile] - The updated profile data
  Future<Either<Failure, UserProfile>> call({
    required UserProfile profile,
  }) {
    return repository.updateUserProfile(
      profile: profile,
    );
  }
}
