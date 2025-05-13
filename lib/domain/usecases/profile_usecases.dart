import 'package:immigru/domain/entities/profile.dart';
import 'package:immigru/domain/repositories/profile_repository.dart';

/// Use case for getting the user's profile
class GetProfileUseCase {
  final ProfileRepository _repository;

  GetProfileUseCase(this._repository);

  /// Call method to execute the use case
  Future<Profile?> call() async {
    return await _repository.getProfile();
  }
}

/// Use case for saving the user's profile
class SaveProfileUseCase {
  final ProfileRepository _repository;

  SaveProfileUseCase(this._repository);

  /// Call method to execute the use case
  Future<void> call(Profile profile) async {
    await _repository.saveProfile(profile);
  }
}

/// Use case for uploading a profile photo
class UploadProfilePhotoUseCase {
  final ProfileRepository _repository;

  UploadProfilePhotoUseCase(this._repository);

  /// Call method to execute the use case
  Future<String?> call(String localPath) async {
    return await _repository.uploadProfilePhoto(localPath);
  }
}

/// Use case for updating privacy settings
class UpdatePrivacySettingsUseCase {
  final ProfileRepository _repository;

  UpdatePrivacySettingsUseCase(this._repository);

  /// Call method to execute the use case
  Future<void> call({required VisibilityType visibility}) async {
    await _repository.updatePrivacySettings(visibility: visibility);
  }
}
