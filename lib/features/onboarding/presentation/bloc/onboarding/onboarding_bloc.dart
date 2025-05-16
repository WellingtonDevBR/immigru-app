import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:immigru/features/onboarding/presentation/bloc/onboarding/onboarding_event.dart';
import 'package:immigru/features/onboarding/presentation/bloc/onboarding/onboarding_state.dart';
import 'package:immigru/shared/interfaces/logger_interface.dart';

/// BLoC for managing the overall onboarding flow
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final OnboardingFeatureRepository _repository;
  final LoggerInterface _logger;

  OnboardingBloc({
    required OnboardingFeatureRepository repository,
    required LoggerInterface logger,
  })  : _repository = repository,
        _logger = logger,
        super(OnboardingState.initial()) {
    on<OnboardingInitialized>(_onInitialized);
    on<BirthCountryUpdated>(_onBirthCountryUpdated);
    on<CurrentStatusUpdated>(_onCurrentStatusUpdated);
    on<MigrationJourneyUpdated>(_onMigrationJourneyUpdated);
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
      emit(state.copyWith(
        isLoading: true,
        errorMessage: null,
      ));

      // Load existing onboarding data if available
      final onboardingData = await _repository.getOnboardingData();

      if (onboardingData != null) {
        // Extract birth country information from the onboarding data
        final birthCountry = onboardingData.birthCountry;
        
        emit(state.copyWith(
          birthCountryId: birthCountry,
          birthCountryName: null, // Will be updated when country is selected
          canMoveToNextStep: birthCountry != null,
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
        ));
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Error initializing onboarding',
        tag: 'Onboarding',
        error: e,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(
        errorMessage: 'Failed to load onboarding data. Please try again.',
        isLoading: false,
      ));
    }
  }

  /// Handle birth country update event
  Future<void> _onBirthCountryUpdated(
    BirthCountryUpdated event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      emit(state.copyWith(
        birthCountryId: event.country.isoCode,
        birthCountryName: event.country.name,
        canMoveToNextStep: true,
        isLoading: true,
      ));

      // Save birth country data
      await _repository.saveStepData('birthCountry', {
        'countryId': event.country.isoCode,
        'countryName': event.country.name,
      });

      emit(state.copyWith(
        isLoading: false,
      ));
    } catch (e, stackTrace) {
      _logger.e(
        'Error updating birth country',
        tag: 'Onboarding',
        error: e,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(
        errorMessage: 'Failed to save birth country. Please try again.',
        isLoading: false,
      ));
    }
  }
  
  /// Handle current status update event
  Future<void> _onCurrentStatusUpdated(
    CurrentStatusUpdated event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      emit(state.copyWith(
        currentStatus: event.statusId,
        canMoveToNextStep: true,
        isLoading: true, // Show loading while saving
      ));

      _logger.i(
        'Current status updated: ${event.statusId}',
        tag: 'Onboarding',
      );
      
      // Save the current status immediately to ensure it's persisted
      await _repository.saveStepData('currentStatus', {
        'statusId': event.statusId,
      });
      
      _logger.i(
        'Current status saved successfully',
        tag: 'Onboarding',
      );
      
      emit(state.copyWith(isLoading: false));
    } catch (e, stackTrace) {
      _logger.e(
        'Error updating current status',
        tag: 'Onboarding',
        error: e,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(
        errorMessage: 'Failed to update current status. Please try again.',
        isLoading: false,
      ));
    }
  }
  
  /// Handle migration journey update event
  Future<void> _onMigrationJourneyUpdated(
    MigrationJourneyUpdated event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      emit(state.copyWith(
        migrationSteps: event.steps,
        canMoveToNextStep: event.steps.isNotEmpty,
        isLoading: false,
      ));

      _logger.i(
        'Migration journey updated with ${event.steps.length} steps',
        tag: 'Onboarding',
      );
      
      // Save migration steps to the backend
      await _repository.saveStepData('migrationJourney', {
        'migrationSteps': event.steps.map((step) => {
          'id': step.id,
          'countryId': step.countryId,
          'countryCode': step.countryCode,
          'countryName': step.countryName,
          'visaTypeId': step.visaTypeId,
          'visaTypeName': step.visaTypeName,
          'startDate': step.startDate?.toIso8601String(),
          'endDate': step.endDate?.toIso8601String(),
          'isCurrentLocation': step.isCurrentLocation,
          'order': step.order,
        }).toList(),
      });
    } catch (e, stackTrace) {
      _logger.e(
        'Error updating migration journey',
        tag: 'Onboarding',
        error: e,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(
        errorMessage: 'Failed to update migration journey. Please try again.',
        isLoading: false,
      ));
    }
  }

  /// Handle next step request event
  void _onNextStepRequested(
    NextStepRequested event,
    Emitter<OnboardingState> emit,
  ) {
    if (state.canMoveToNextStep) {
      final nextStepIndex = state.currentStepIndex + 1;
      
      if (nextStepIndex < state.totalSteps) {
        final isLastStep = nextStepIndex >= state.totalSteps - 1;
        
        emit(state.copyWith(
          currentStepIndex: nextStepIndex,
          isLastStep: isLastStep,
          canMoveToNextStep: (nextStepIndex == 1 && state.currentStatus != null) || // Allow moving to next step if current status is selected
                             (nextStepIndex == 2 && state.migrationSteps.isNotEmpty), // Allow moving to next step if migration steps are added
        ));
      } else {
        // Complete onboarding if we've reached the end
        this.add(const OnboardingCompleted());
      }
    }
  }

  /// Handle previous step request event
  void _onPreviousStepRequested(
    PreviousStepRequested event,
    Emitter<OnboardingState> emit,
  ) {
    if (state.currentStepIndex > 0) {
      final prevIndex = state.currentStepIndex - 1;
      emit(state.copyWith(
        currentStepIndex: prevIndex,
        isLastStep: false,
      ));
    }
  }

  /// Handle step skip event
  void _onStepSkipped(
    StepSkipped event,
    Emitter<OnboardingState> emit,
  ) {
    final nextIndex = state.currentStepIndex + 1;
    
    if (nextIndex < state.totalSteps) {
      emit(state.copyWith(
        currentStepIndex: nextIndex,
        isLastStep: nextIndex == state.totalSteps - 1,
      ));
    } else {
      // Complete onboarding if we've reached the end
      add(const OnboardingCompleted());
    }
  }

  /// Handle onboarding completion event
  Future<void> _onOnboardingCompleted(
    OnboardingCompleted event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      emit(state.copyWith(
        isLoading: true,
      ));

      // Save all onboarding data
      add(const OnboardingSaved());

      // Mark onboarding as complete
      await _repository.completeOnboarding();

      emit(state.copyWith(
        isLoading: false,
      ));
    } catch (e, stackTrace) {
      _logger.e(
        'Error completing onboarding',
        tag: 'Onboarding',
        error: e,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(
        errorMessage: 'Failed to complete onboarding. Please try again.',
        isLoading: false,
      ));
    }
  }

  /// Handle onboarding save event
  Future<void> _onOnboardingSaved(
    OnboardingSaved event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      _logger.i('Saving all onboarding data', tag: 'Onboarding');
      
      // Save birth country data
      if (state.birthCountryId != null && state.birthCountryId!.isNotEmpty) {
        _logger.i('Saving birth country: ${state.birthCountryId}', tag: 'Onboarding');
        await _repository.saveStepData('birthCountry', {
          'countryId': state.birthCountryId,
          'countryName': state.birthCountryName,
        });
      }
      
      // Save current status (migrationStage) data
      if (state.currentStatus != null && state.currentStatus!.isNotEmpty) {
        _logger.i('Saving current status: ${state.currentStatus}', tag: 'Onboarding');
        await _repository.saveStepData('currentStatus', {
          'statusId': state.currentStatus,
        });
      }
      
      // Save migration steps if available
      if (state.migrationSteps != null && state.migrationSteps.isNotEmpty) {
        _logger.i('Saving ${state.migrationSteps.length} migration steps', tag: 'Onboarding');
        // Migration steps are saved directly from the MigrationJourneyBloc
      }
      
      _logger.i('All onboarding data saved successfully', tag: 'Onboarding');
    } catch (e, stackTrace) {
      _logger.e(
        'Error saving onboarding data',
        tag: 'Onboarding',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
