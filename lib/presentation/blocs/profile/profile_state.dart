import 'package:equatable/equatable.dart';
import 'package:immigru/domain/entities/profile.dart';

/// Enum representing the different steps in the profile setup flow
enum ProfileSetupStep {
  basicInfo,
  displayName,
  bio,
  location,
  photo,
  privacy,
  completed,
}

/// State for the profile setup flow
class ProfileState extends Equatable {
  final Profile profile;
  final ProfileSetupStep currentStep;
  final bool isLoading;
  final String? errorMessage;
  final bool isSubmitting;
  final bool isPhotoUploading;

  const ProfileState({
    this.profile = const Profile(),
    this.currentStep = ProfileSetupStep.basicInfo,
    this.isLoading = false,
    this.errorMessage,
    this.isSubmitting = false,
    this.isPhotoUploading = false,
  });

  /// Create a copy of this ProfileState with the given fields replaced with new values
  ProfileState copyWith({
    Profile? profile,
    ProfileSetupStep? currentStep,
    bool? isLoading,
    String? errorMessage,
    bool? isSubmitting,
    bool? isPhotoUploading,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isPhotoUploading: isPhotoUploading ?? this.isPhotoUploading,
    );
  }

  /// Check if the current step is valid
  bool get isCurrentStepValid {
    switch (currentStep) {
      case ProfileSetupStep.basicInfo:
        return profile.firstName != null &&
            profile.firstName!.isNotEmpty &&
            profile.lastName != null &&
            profile.lastName!.isNotEmpty;
      case ProfileSetupStep.displayName:
        return profile.displayName != null && profile.displayName!.isNotEmpty;
      case ProfileSetupStep.bio:
        // Bio is optional
        return true;
      case ProfileSetupStep.location:
        // Location is optional
        return true;
      case ProfileSetupStep.photo:
        // Photo is optional
        return true;
      case ProfileSetupStep.privacy:
        // Privacy settings are pre-filled
        return true;
      case ProfileSetupStep.completed:
        return true;
    }
  }

  @override
  List<Object?> get props => [
        profile,
        currentStep,
        isLoading,
        errorMessage,
        isSubmitting,
        isPhotoUploading,
      ];
}
