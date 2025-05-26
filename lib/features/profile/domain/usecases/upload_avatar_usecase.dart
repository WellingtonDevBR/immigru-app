import 'package:dartz/dartz.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/profile/domain/repositories/user_profile_repository.dart';

/// Use case for uploading a user avatar
class UploadAvatarUseCase {
  final UserProfileRepository repository;

  /// Constructor
  UploadAvatarUseCase(this.repository);

  /// Execute the use case
  /// 
  /// [userId] - ID of the user whose avatar to upload
  /// [filePath] - Path to the avatar image file
  Future<Either<Failure, String>> call({
    required String userId,
    required String filePath,
  }) {
    return repository.uploadAvatar(
      userId: userId,
      filePath: filePath,
    );
  }
}
