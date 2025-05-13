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
    on<NextStepRequested>(_onNextStepRequested);
    on<PreviousStepRequested>(_onPreviousStepRequested);
    on<StepSkipped>(_onStepSkipped);
    on<OnboardingCompleted>(_onOnboardingCompleted);
    on<OnboardingSaved>(_onOnboardingSaved);
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
        _logger.debug('OnboardingBloc', 'Onboarding already completed, skipping to completed state');
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
      
      _logger.debug('OnboardingBloc', 'Initialized with existing data');
    } catch (e) {
      _logger.error('OnboardingBloc', 'Error initializing', error: e);
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
    
    _logger.debug('OnboardingBloc', 'Birth country updated: ${event.country}');


  }

  /// Handle current status update event
  void _onCurrentStatusUpdated(
    CurrentStatusUpdated event,
    Emitter<OnboardingState> emit,
  ) {
    // Validate the status value
    final validStatuses = ['planning', 'preparing', 'moved', 'exploring', 'permanent'];
    if (!validStatuses.contains(event.status)) {
      _logger.error('OnboardingBloc', 'Invalid status value: ${event.status}');
      emit(state.copyWith(errorMessage: 'Invalid status value: ${event.status}'));
      return;
    }
    
    _logger.debug('OnboardingBloc', 'Updating current status to: ${event.status}');
    
    final updatedData = state.data.copyWith(currentStatus: event.status);
    emit(state.copyWith(data: updatedData));
    
    _logger.debug('OnboardingBloc', 'Current status updated successfully: ${event.status}');
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
    _logger.debug('OnboardingBloc', 'Migration step added');
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
      _logger.debug('OnboardingBloc', 'Migration step updated at index: ${event.index}');
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
      _logger.debug('OnboardingBloc', 'Migration step removed at index: ${event.index}');
    }
  }

  /// Handle profession update event
  void _onProfessionUpdated(
    ProfessionUpdated event,
    Emitter<OnboardingState> emit,
  ) {


    
    final updatedData = state.data.copyWith(profession: event.profession);
    emit(state.copyWith(data: updatedData));
    
    _logger.debug('OnboardingBloc', 'Profession updated: ${event.profession}');


  }

  /// Handle languages update event
  void _onLanguagesUpdated(
    LanguagesUpdated event,
    Emitter<OnboardingState> emit,
  ) {
    _logger.debug('OnboardingBloc', 'Languages updated: ${event.languages}');
    emit(state.copyWith(
      data: state.data.copyWith(languages: event.languages),
    ));
  }

  /// Handle interests update event
  void _onInterestsUpdated(
    InterestsUpdated event,
    Emitter<OnboardingState> emit,
  ) {
    _logger.debug('OnboardingBloc', 'Interests updated: ${event.interests}');
    emit(state.copyWith(
      data: state.data.copyWith(interests: event.interests),
    ));
  }

  /// Handle profile basic info updated event
  void _onProfileBasicInfoUpdated(
    ProfileBasicInfoUpdated event,
    Emitter<OnboardingState> emit,
  ) {
    _logger.debug('OnboardingBloc', 'Profile basic info updated: ${event.firstName} ${event.lastName}');
    emit(state.copyWith(
      data: state.data.copyWith(
        firstName: event.firstName,
        lastName: event.lastName,
      ),
    ));
  }

  /// Handle profile display name updated event
  void _onProfileDisplayNameUpdated(
    ProfileDisplayNameUpdated event,
    Emitter<OnboardingState> emit,
  ) {
    _logger.debug('OnboardingBloc', 'Profile display name updated: ${event.displayName}');
    emit(state.copyWith(
      data: state.data.copyWith(
        displayName: event.displayName,
      ),
    ));
  }

  /// Handle profile bio updated event
  void _onProfileBioUpdated(
    ProfileBioUpdated event,
    Emitter<OnboardingState> emit,
  ) {
    _logger.debug('OnboardingBloc', 'Profile bio updated: ${event.bio}');
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
    _logger.debug('OnboardingBloc', 'Profile location updated: ${event.currentLocation} ${event.destinationCity}');
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
    _logger.debug('OnboardingBloc', 'Profile photo updated: ${event.photoUrl}');
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
    _logger.debug('OnboardingBloc', 'Profile privacy updated: ${event.isPrivate}');
    emit(state.copyWith(
      data: state.data.copyWith(
        isPrivate: event.isPrivate,
      ),
    ));
  }

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

    final currentStepIndex = OnboardingStep.values.indexOf(state.currentStep);
    final nextStepIndex = currentStepIndex + 1;
    
    if (nextStepIndex < OnboardingStep.values.length) {
      final nextStep = OnboardingStep.values[nextStepIndex];
      emit(state.copyWith(
        currentStep: nextStep,
        errorMessage: null,
      ));
      _logger.debug('OnboardingBloc', 'Moved to next step: $nextStep');
      
      // Auto-save progress when moving to next step
      add(const OnboardingSaved());
      
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
    
    if (previousStepIndex >= 0) {
      final previousStep = OnboardingStep.values[previousStepIndex];
      emit(state.copyWith(
        currentStep: previousStep,
        errorMessage: null,
      ));
      _logger.debug('OnboardingBloc', 'Moved to previous step: $previousStep');
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
      final currentStepIndex = OnboardingStep.values.indexOf(state.currentStep);
      final nextStepIndex = currentStepIndex + 1;
      
      if (nextStepIndex < OnboardingStep.values.length) {
        final nextStep = OnboardingStep.values[nextStepIndex];
        emit(state.copyWith(
          currentStep: nextStep,
          errorMessage: null,
        ));
        _logger.debug('OnboardingBloc', 'Skipped step: ${state.currentStep}');
        
        // Auto-save progress when skipping a step
        add(const OnboardingSaved());
        
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
      
      _logger.debug('OnboardingBloc', 'Onboarding completed');
    } catch (e) {
      _logger.error('OnboardingBloc', 'Error completing onboarding', error: e);
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to complete onboarding',
      ));
    }
  }

  /// Handle save onboarding data event
  Future<void> _onOnboardingSaved(
    OnboardingSaved event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));
      
      // Log what we're about to save
      _logger.debug('OnboardingBloc', 'Saving onboarding data...');
      
      // Log specific fields to help with debugging
      if (state.data.birthCountry != null && state.data.birthCountry!.isNotEmpty) {
        _logger.debug('OnboardingBloc', 'Birth country: ${state.data.birthCountry}');
      }
      
      if (state.data.currentStatus != null && state.data.currentStatus!.isNotEmpty) {
        _logger.debug('OnboardingBloc', 'Current status: ${state.data.currentStatus}');
      }
      
      if (state.data.migrationSteps.isNotEmpty) {
        _logger.debug('OnboardingBloc', 'Migration steps count: ${state.data.migrationSteps.length}');
      }
      
      // Save the data
      await _saveOnboardingDataUseCase(state.data);
      
      emit(state.copyWith(isLoading: false));
      
      _logger.debug('OnboardingBloc', 'Onboarding progress saved successfully');
    } catch (e, stackTrace) {
      _logger.error(
        'OnboardingBloc', 
        'Error saving onboarding data', 
        error: e,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to save progress',
      ));
    }
  }
}
