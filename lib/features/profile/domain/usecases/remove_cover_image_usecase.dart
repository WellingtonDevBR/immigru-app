import 'package:dartz/dartz.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/profile/domain/repositories/user_profile_repository.dart';

/// Use case for removing a user's cover image
class RemoveCoverImageUseCase {
  final UserProfileRepository repository;

  /// Constructor
  RemoveCoverImageUseCase(this.repository);

  /// Execute the use case
  /// 
  /// [userId] - ID of the user whose cover image to remove
  Future<Either<Failure, bool>> call({
    required String userId,
  }) {
    return repository.removeCoverImage(
      userId: userId,
    );
  }
}
