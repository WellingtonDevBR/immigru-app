import 'package:dartz/dartz.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/profile/domain/repositories/user_profile_repository.dart';

/// Use case for uploading a user cover image
class UploadCoverImageUseCase {
  final UserProfileRepository repository;

  /// Constructor
  UploadCoverImageUseCase(this.repository);

  /// Execute the use case
  /// 
  /// [userId] - ID of the user whose cover image to upload
  /// [filePath] - Path to the cover image file
  Future<Either<Failure, String>> call({
    required String userId,
    required String filePath,
  }) {
    return repository.uploadCoverImage(
      userId: userId,
      filePath: filePath,
    );
  }
}
