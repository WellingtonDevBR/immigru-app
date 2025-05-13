import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/core/services/logger_service.dart';
import 'package:immigru/domain/entities/profile.dart';
import 'package:immigru/domain/usecases/profile_usecases.dart';
import 'package:immigru/presentation/blocs/profile/profile_event.dart';
import 'package:immigru/presentation/blocs/profile/profile_state.dart';

/// BLoC for managing profile setup flow
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase _getProfileUseCase;
  final SaveProfileUseCase _saveProfileUseCase;
  final UploadProfilePhotoUseCase _uploadProfilePhotoUseCase;
  final UpdatePrivacySettingsUseCase _updatePrivacySettingsUseCase;
  final LoggerService _logger;

  ProfileBloc({
    required GetProfileUseCase getProfileUseCase,
    required SaveProfileUseCase saveProfileUseCase,
    required UploadProfilePhotoUseCase uploadProfilePhotoUseCase,
    required UpdatePrivacySettingsUseCase updatePrivacySettingsUseCase,
    required LoggerService logger,
  })  : _getProfileUseCase = getProfileUseCase,
        _saveProfileUseCase = saveProfileUseCase,
        _uploadProfilePhotoUseCase = uploadProfilePhotoUseCase,
        _updatePrivacySettingsUseCase = updatePrivacySettingsUseCase,
        _logger = logger,
        super(const ProfileState()) {
    on<ProfileLoaded>(_onProfileLoaded);
    on<BasicInfoUpdated>(_onBasicInfoUpdated);
    on<DisplayNameUpdated>(_onDisplayNameUpdated);
    on<BioUpdated>(_onBioUpdated);
    on<LocationUpdated>(_onLocationUpdated);
    on<ProfilePhotoUploaded>(_onProfilePhotoUploaded);
    on<PrivacySettingsUpdated>(_onPrivacySettingsUpdated);
    on<NextStepRequested>(_onNextStepRequested);
    on<PreviousStepRequested>(_onPreviousStepRequested);
    on<StepSkipped>(_onStepSkipped);
    on<ProfileSaved>(_onProfileSaved);
    on<ProfileSetupCompleted>(_onProfileSetupCompleted);
  }

  /// Handle profile loaded event
  void _onProfileLoaded(
    ProfileLoaded event,
    Emitter<ProfileState> emit,
  ) async {
    
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final profile = await _getProfileUseCase();
      if (profile != null) {
        emit(state.copyWith(
          profile: profile,
          isLoading: false,
        ));
        
      } else {
        emit(state.copyWith(isLoading: false));
        
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load profile: $e',
      ));
      _logger.error('ProfileBloc', 'Error loading profile: $e');
    }
  }

  /// Handle basic info updated event
  void _onBasicInfoUpdated(
    BasicInfoUpdated event,
    Emitter<ProfileState> emit,
  ) {
    
    emit(state.copyWith(
      profile: state.profile.copyWith(
        fullName: event.fullName,
        profilePhotoUrl: event.photoUrl ?? state.profile.profilePhotoUrl,
      ),
      errorMessage: null,
    ));
  }

  /// Handle display name updated event
  void _onDisplayNameUpdated(
    DisplayNameUpdated event,
    Emitter<ProfileState> emit,
  ) {
    
    emit(state.copyWith(
      profile: state.profile.copyWith(
        displayName: event.displayName,
      ),
      errorMessage: null,
    ));
  }

  /// Handle bio updated event
  void _onBioUpdated(
    BioUpdated event,
    Emitter<ProfileState> emit,
  ) {
    
    emit(state.copyWith(
      profile: state.profile.copyWith(
        bio: event.bio,
      ),
      errorMessage: null,
    ));
  }

  /// Handle location updated event
  void _onLocationUpdated(
    LocationUpdated event,
    Emitter<ProfileState> emit,
  ) {
    _logger.debug('ProfileBloc',
        'Location updated: ${event.currentLocation} -> ${event.destinationCity}');
    emit(state.copyWith(
      profile: state.profile.copyWith(
        currentLocation: event.currentLocation,
        destinationCity: event.destinationCity,
      ),
      errorMessage: null,
    ));
  }

  /// Handle profile photo uploaded event
  void _onProfilePhotoUploaded(
    ProfilePhotoUploaded event,
    Emitter<ProfileState> emit,
  ) async {
    
    emit(state.copyWith(isPhotoUploading: true, errorMessage: null));

    try {
      final photoUrl = await _uploadProfilePhotoUseCase(event.localPath);
      if (photoUrl != null) {
        emit(state.copyWith(
          profile: state.profile.copyWith(
            profilePhotoUrl: photoUrl,
          ),
          isPhotoUploading: false,
        ));
        
      } else {
        emit(state.copyWith(
          isPhotoUploading: false,
          errorMessage: 'Failed to upload profile photo',
        ));
        _logger.error('ProfileBloc', 'Failed to upload profile photo');
      }
    } catch (e) {
      emit(state.copyWith(
        isPhotoUploading: false,
        errorMessage: 'Error uploading profile photo: $e',
      ));
      _logger.error('ProfileBloc', 'Error uploading profile photo: $e');
    }
  }

  /// Handle privacy settings updated event
  void _onPrivacySettingsUpdated(
    PrivacySettingsUpdated event,
    Emitter<ProfileState> emit,
  ) {
    
    emit(state.copyWith(
      profile: state.profile.copyWith(
        showEmail: event.isPrivate ? VisibilityType.private : VisibilityType.public,
        showLocation: event.isPrivate ? VisibilityType.private : VisibilityType.public,
        showBirthdate: event.isPrivate ? VisibilityType.private : VisibilityType.public,
        showProfession: event.isPrivate ? VisibilityType.private : VisibilityType.public,
        showJourneyInfo: event.isPrivate ? VisibilityType.private : VisibilityType.public,
        showRelationshipStatus: event.isPrivate ? VisibilityType.private : VisibilityType.public,
      ),
      errorMessage: null,
    ));
  }

  /// Handle next step requested event
  void _onNextStepRequested(
    NextStepRequested event,
    Emitter<ProfileState> emit,
  ) {
    if (!state.isCurrentStepValid) {
      emit(state.copyWith(
        errorMessage: 'Please complete the current step before proceeding',
      ));
      return;
    }

    final currentStepIndex = ProfileSetupStep.values.indexOf(state.currentStep);
    final nextStepIndex = currentStepIndex + 1;
    
    if (nextStepIndex < ProfileSetupStep.values.length) {
      final nextStep = ProfileSetupStep.values[nextStepIndex];
      emit(state.copyWith(
        currentStep: nextStep,
        errorMessage: null,
      ));
      
      
      // Auto-save progress when moving to next step
      add(const ProfileSaved());
      
      // If we've reached the completed step, mark profile setup as complete
      if (nextStep == ProfileSetupStep.completed) {
        add(const ProfileSetupCompleted());
      }
    }
  }

  /// Handle previous step requested event
  void _onPreviousStepRequested(
    PreviousStepRequested event,
    Emitter<ProfileState> emit,
  ) {
    final currentStepIndex = ProfileSetupStep.values.indexOf(state.currentStep);
    final previousStepIndex = currentStepIndex - 1;
    
    if (previousStepIndex >= 0) {
      final previousStep = ProfileSetupStep.values[previousStepIndex];
      emit(state.copyWith(
        currentStep: previousStep,
        errorMessage: null,
      ));
      
    }
  }

  /// Handle step skipped event
  void _onStepSkipped(
    StepSkipped event,
    Emitter<ProfileState> emit,
  ) {
    final currentStepIndex = ProfileSetupStep.values.indexOf(state.currentStep);
    final nextStepIndex = currentStepIndex + 1;
    
    if (nextStepIndex < ProfileSetupStep.values.length) {
      final nextStep = ProfileSetupStep.values[nextStepIndex];
      emit(state.copyWith(
        currentStep: nextStep,
        errorMessage: null,
      ));
      
    }
  }

  /// Handle profile saved event
  void _onProfileSaved(
    ProfileSaved event,
    Emitter<ProfileState> emit,
  ) async {
    
    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      await _saveProfileUseCase(state.profile);
      emit(state.copyWith(isSubmitting: false));
      
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to save profile: $e',
      ));
      _logger.error('ProfileBloc', 'Error saving profile: $e');
    }
  }

  /// Handle profile setup completed event
  void _onProfileSetupCompleted(
    ProfileSetupCompleted event,
    Emitter<ProfileState> emit,
  ) async {
    
    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      // Save the final profile
      await _saveProfileUseCase(state.profile);
      
      // Update privacy settings
      final visibility = state.profile.isPrivate ? VisibilityType.private : VisibilityType.public;
      await _updatePrivacySettingsUseCase(visibility: visibility);
      
      emit(state.copyWith(
        isSubmitting: false,
        currentStep: ProfileSetupStep.completed,
      ));
      
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to complete profile setup: $e',
      ));
      _logger.error('ProfileBloc', 'Error completing profile setup: $e');
    }
  }
}
