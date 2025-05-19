import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/core/services/logger_service.dart';
import 'package:immigru/domain/entities/onboarding_data.dart';
import 'package:immigru/domain/entities/user.dart';
import 'package:immigru/domain/usecases/onboarding_usecases.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_event.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_state.dart';

/// BLoC for managing onboarding flow state
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final GetOnboardingDataUseCase _getOnboardingDataUseCase;
  final SaveOnboardingDataUseCase _saveOnboardingDataUseCase;
  final CompleteOnboardingUseCase _completeOnboardingUseCase;
  final CheckOnboardingStatusUseCase _checkOnboardingStatusUseCase;
  final LoggerService _logger;
  final User? user;

  OnboardingBloc({
    required GetOnboardingDataUseCase getOnboardingDataUseCase,
    required SaveOnboardingDataUseCase saveOnboardingDataUseCase,
    required CompleteOnboardingUseCase completeOnboardingUseCase,
    required CheckOnboardingStatusUseCase checkOnboardingStatusUseCase,
    required LoggerService logger,
    this.user,
  })  : _getOnboardingDataUseCase = getOnboardingDataUseCase,
        _saveOnboardingDataUseCase = saveOnboardingDataUseCase,
        _completeOnboardingUseCase = completeOnboardingUseCase,
        _checkOnboardingStatusUseCase = checkOnboardingStatusUseCase,
        _logger = logger,
        super(OnboardingState.initial()) {
    on<OnboardingInitialized>(_onInitialized);
    on<BirthCountryUpdated>(_onBirthCountryUpdated);
    on<CurrentStatusUpdated>(_onCurrentStatusUpdated);
    on<MigrationStepAdded>(_onMigrationStepAdded);
    on<MigrationStepUpdated>(_onMigrationStepUpdated);
    on<MigrationStepRemoved>(_onMigrationStepRemoved);
    on<ProfessionUpdated>(_onProfessionUpdated);
    on<LanguagesUpdated>(_onLanguagesUpdated);
    on<InterestsUpdated>(_onInterestsUpdated);
    on<ProfileBasicInfoUpdated>(_onProfileBasicInfoUpdated);
    on<ProfileDisplayNameUpdated>(_onProfileDisplayNameUpdated);
    on<ProfileBioUpdated>(_onProfileBioUpdated);
    on<ProfileLocationUpdated>(_onProfileLocationUpdated);
    on<ProfilePhotoUpdated>(_onProfilePhotoUpdated);
    on<ProfilePrivacyUpdated>(_onProfilePrivacyUpdated);
    on<ImmiGrovesUpdated>(_onImmiGrovesUpdated);
    on<NextStepRequested>(_onNextStepRequested);
    on<PreviousStepRequested>(_onPreviousStepRequested);
    on<StepSkipped>(_onStepSkipped);
    on<OnboardingCompleted>(_onOnboardingCompleted);
    on<OnboardingSaved>(_onOnboardingSaved);
    on<OnboardingDataChanged>(_onOnboardingDataChanged);
  }

  /// Handle initialization event
  Future<void> _onInitialized(
    OnboardingInitialized event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));
      
      // Check if onboarding is already completed
      final isCompleted = await _checkOnboardingStatusUseCase();
      if (isCompleted) {
        
        emit(state.copyWith(
          currentStep: OnboardingStep.completed,
          isLoading: false,
        ));
        return;
      }
      
      // Load existing onboarding data if any
      final onboardingData = await _getOnboardingDataUseCase();
      
      emit(state.copyWith(
        data: onboardingData,
        isLoading: false,
      ));
      
      
    } catch (e) {

      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load onboarding data',
      ));
    }
  }

  /// Handle birth country update event
  void _onBirthCountryUpdated(
    BirthCountryUpdated event,
    Emitter<OnboardingState> emit,
  ) {


    
    final updatedData = state.data.copyWith(birthCountry: event.country);
    emit(state.copyWith(data: updatedData));
    
    


  }

  /// Handle current status update event
  void _onCurrentStatusUpdated(
    CurrentStatusUpdated event,
    Emitter<OnboardingState> emit,
  ) {
    // Validate the status value
    final validStatuses = ['planning', 'preparing', 'moved', 'exploring', 'permanent'];
    if (!validStatuses.contains(event.status)) {

      emit(state.copyWith(errorMessage: 'Invalid status value: ${event.status}'));
      return;
    }
    
    
    
    final updatedData = state.data.copyWith(currentStatus: event.status);
    emit(state.copyWith(data: updatedData));
    
    
  }

  /// Handle migration step add event
  void _onMigrationStepAdded(
    MigrationStepAdded event,
    Emitter<OnboardingState> emit,
  ) {
    final updatedSteps = List<MigrationStep>.from(state.data.migrationSteps)
      ..add(event.step);
    final updatedData = state.data.copyWith(migrationSteps: updatedSteps);
    emit(state.copyWith(data: updatedData));
    
  }

  /// Handle migration step update event
  void _onMigrationStepUpdated(
    MigrationStepUpdated event,
    Emitter<OnboardingState> emit,
  ) {
    final updatedSteps = List<MigrationStep>.from(state.data.migrationSteps);
    if (event.index >= 0 && event.index < updatedSteps.length) {
      updatedSteps[event.index] = event.step;
      final updatedData = state.data.copyWith(migrationSteps: updatedSteps);
      emit(state.copyWith(data: updatedData));
      
    }
  }

  /// Handle migration step remove event
  void _onMigrationStepRemoved(
    MigrationStepRemoved event,
    Emitter<OnboardingState> emit,
  ) {
    final updatedSteps = List<MigrationStep>.from(state.data.migrationSteps);
    if (event.index >= 0 && event.index < updatedSteps.length) {
      updatedSteps.removeAt(event.index);
      final updatedData = state.data.copyWith(migrationSteps: updatedSteps);
      emit(state.copyWith(data: updatedData));
      
    }
  }

  /// Handle profession update event
  void _onProfessionUpdated(
    ProfessionUpdated event,
    Emitter<OnboardingState> emit,
  ) {


    
    final updatedData = state.data.copyWith(profession: event.profession);
    emit(state.copyWith(data: updatedData));
    
    


  }

  /// Handle languages update event
  void _onLanguagesUpdated(
    LanguagesUpdated event,
    Emitter<OnboardingState> emit,
  ) {
    
    emit(state.copyWith(
      data: state.data.copyWith(languages: event.languages),
    ));
  }

  /// Handle interests update event
  void _onInterestsUpdated(
    InterestsUpdated event,
    Emitter<OnboardingState> emit,
  ) {
    
    emit(state.copyWith(
      data: state.data.copyWith(interests: event.interests),
    ));
  }

  /// Handle profile basic info updated event
  void _onProfileBasicInfoUpdated(
    ProfileBasicInfoUpdated event,
    Emitter<OnboardingState> emit,
  ) {
    
    emit(state.copyWith(
      data: state.data.copyWith(
        fullName: event.fullName,
      ),
    ));
  }

  /// Handle profile display name updated event
  void _onProfileDisplayNameUpdated(
    ProfileDisplayNameUpdated event,
    Emitter<OnboardingState> emit,
  ) {
    // Only update state if the display name has actually changed
    if (state.data.displayName != event.displayName) {
      // Minimal logging for performance
      
      
      emit(state.copyWith(
        data: state.data.copyWith(
          displayName: event.displayName,
        ),
      ));
    }
  }

  /// Handle profile bio updated event
  void _onProfileBioUpdated(
    ProfileBioUpdated event,
    Emitter<OnboardingState> emit,
  ) {
    
    
    
    
    // Check if the bio has actually changed
    final hasChanged = state.data.bio != event.bio;
    
    
    // For privacy reasons, don't log the full bio content, just the first few words
    final bioPreview = event.bio.isNotEmpty 
        ? '${event.bio.split(' ').take(5).join(' ')}${event.bio.split(' ').length > 5 ? '...' : ''}'
        : '(empty)';
    
    
    emit(state.copyWith(
      data: state.data.copyWith(
        bio: event.bio,
      ),
    ));
    
    
    
  }

  /// Handle profile location updated event
  void _onProfileLocationUpdated(
    ProfileLocationUpdated event,
    Emitter<OnboardingState> emit,
  ) {
    
    emit(state.copyWith(
      data: state.data.copyWith(
        currentLocation: event.currentLocation,
        destinationCity: event.destinationCity,
      ),
    ));
  }

  /// Handle profile photo updated event
  void _onProfilePhotoUpdated(
    ProfilePhotoUpdated event,
    Emitter<OnboardingState> emit,
  ) {
    
    emit(state.copyWith(
      data: state.data.copyWith(
        profilePhotoUrl: event.photoUrl,
      ),
    ));
  }

  /// Handle profile privacy updated event
  void _onProfilePrivacyUpdated(
    ProfilePrivacyUpdated event,
    Emitter<OnboardingState> emit,
  ) {
    
    emit(state.copyWith(
      data: state.data.copyWith(
        isPrivate: event.isPrivate,
      ),
    ));
  }

  /// Handle ImmiGroves selection update
  void _onImmiGrovesUpdated(
    ImmiGrovesUpdated event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(
      data: state.data.copyWith(
        selectedImmiGroves: event.selectedImmiGroves,
      ),
    ));
    
    // Save the ImmiGroves selection to the backend
    add(const OnboardingSaved());
  }

  // Track the last saved step to prevent redundant saves during navigation
  static OnboardingStep? _lastSavedStep;
  
  /// Handle next step request event
  void _onNextStepRequested(
    NextStepRequested event,
    Emitter<OnboardingState> emit,
  ) {
    if (!state.isCurrentStepValid) {
      emit(state.copyWith(
        errorMessage: 'Please complete the current step before proceeding',
      ));
      return;
    }

    final currentStep = state.currentStep;
    final currentStepIndex = OnboardingStep.values.indexOf(currentStep);
    final nextStepIndex = currentStepIndex + 1;
    
    // Determine if we need to save the current step data
    bool shouldSaveCurrentStep = _lastSavedStep != currentStep;
    
    // These steps always need to save data when completed
    final criticalSteps = [
      OnboardingStep.birthCountry,
      OnboardingStep.currentStatus,
      OnboardingStep.profileBasicInfo,
      OnboardingStep.profileDisplayName,
      OnboardingStep.profileBio,
      OnboardingStep.interests,
      OnboardingStep.languages,
    ];
    
    if (criticalSteps.contains(currentStep)) {
      
      shouldSaveCurrentStep = true;
    }
    
    // Save current step data if needed
    if (shouldSaveCurrentStep) {
      
      _saveOnboardingDataUseCase(state.data).then((_) {
        
        // Update the last saved step
        _lastSavedStep = currentStep;
      }).catchError((error) {

      });
    } else {
      
    }
    
    if (nextStepIndex < OnboardingStep.values.length) {
      final nextStep = OnboardingStep.values[nextStepIndex];
      emit(state.copyWith(
        currentStep: nextStep,
        errorMessage: null,
      ));
      
      
      // If we've reached the completed step, mark onboarding as complete
      if (nextStep == OnboardingStep.completed) {
        add(const OnboardingCompleted());
      }
    }
  }

  /// Handle previous step request event
  void _onPreviousStepRequested(
    PreviousStepRequested event,
    Emitter<OnboardingState> emit,
  ) {
    final currentStepIndex = OnboardingStep.values.indexOf(state.currentStep);
    final previousStepIndex = currentStepIndex - 1;
    
    // No need to save data when going back to previous step
    
    
    if (previousStepIndex >= 0) {
      final previousStep = OnboardingStep.values[previousStepIndex];
      emit(state.copyWith(
        currentStep: previousStep,
        errorMessage: null,
      ));
      
    }
  }

  /// Handle step skip event
  void _onStepSkipped(
    StepSkipped event,
    Emitter<OnboardingState> emit,
  ) {
    // Only allow skipping certain steps
    if (state.currentStep == OnboardingStep.migrationJourney ||
        state.currentStep == OnboardingStep.profession) {
      final currentStep = state.currentStep;
      final currentStepIndex = OnboardingStep.values.indexOf(currentStep);
      final nextStepIndex = currentStepIndex + 1;
      
      // Check if we need to save data for the current step before skipping
      bool shouldSaveCurrentStep = _lastSavedStep != currentStep;
      
      if (shouldSaveCurrentStep) {
        
        _saveOnboardingDataUseCase(state.data).then((_) {
          
          // Update the last saved step
          _lastSavedStep = currentStep;
        }).catchError((error) {

        });
      } else {
        
      }
      
      if (nextStepIndex < OnboardingStep.values.length) {
        final nextStep = OnboardingStep.values[nextStepIndex];
        emit(state.copyWith(
          currentStep: nextStep,
          errorMessage: null,
        ));
        
        
        // If we've reached the completed step, mark onboarding as complete
        if (nextStep == OnboardingStep.completed) {
          add(const OnboardingCompleted());
        }
      }
    } else {
      emit(state.copyWith(
        errorMessage: 'This step cannot be skipped',
      ));
    }
  }

  /// Handle onboarding complete event
  Future<void> _onOnboardingCompleted(
    OnboardingCompleted event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));
      
      // Mark data as completed
      final completedData = state.data.copyWith(isCompleted: true);
      await _saveOnboardingDataUseCase(completedData);
      await _completeOnboardingUseCase();
      
      emit(state.copyWith(
        data: completedData,
        currentStep: OnboardingStep.completed,
        isLoading: false,
      ));
      
      
    } catch (e) {

      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to complete onboarding',
      ));
    }
  }

  // Track the last saved state to prevent redundant API calls
  static OnboardingData? _lastSavedData;
  static DateTime _lastSaveTime = DateTime(2000); // Initialize with old date
  
  /// Handle save onboarding data event
  Future<void> _onOnboardingSaved(
    OnboardingSaved event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      // Prevent rapid consecutive saves (throttle to once per second)
      final now = DateTime.now();
      if (now.difference(_lastSaveTime).inMilliseconds < 1000) {
        
        return;
      }
      
      // Check if data has actually changed from last save
      if (_lastSavedData != null && _lastSavedData == state.data) {
        
        return;
      }
      
      // Update last save time before starting the save operation
      _lastSaveTime = now;
      
      // Only log the start of the save operation, not all the details
      
      emit(state.copyWith(isLoading: true));
      
      // Save the data without excessive logging
      await _saveOnboardingDataUseCase(state.data);
      
      // Update the last saved data after successful save
      _lastSavedData = state.data;
      
      emit(state.copyWith(isLoading: false));
      
      // Log success with minimal information
      
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to save progress',
      ));
    }
  }

  /// Handle onboarding data changed event
  Future<void> _onOnboardingDataChanged(
    OnboardingDataChanged event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      emit(state.copyWith(
        data: event.data,
        isLoading: false,
      ));
    } catch (e, stackTrace) {
      _logger.error('OnboardingBloc', 'Error updating onboarding data', error: e, stackTrace: stackTrace);
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update onboarding data',
      ));
    }
  }
}
