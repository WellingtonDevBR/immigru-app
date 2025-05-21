import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/onboarding/domain/repositories/immi_grove_repository.dart';
import 'package:immigru/features/onboarding/domain/repositories/language_repository.dart';
import 'package:immigru/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:immigru/features/onboarding/presentation/bloc/onboarding/immi_grove_events.dart';
import 'package:immigru/features/onboarding/presentation/bloc/onboarding/onboarding_event.dart';
import 'package:immigru/features/onboarding/presentation/bloc/onboarding/onboarding_state.dart';
import 'package:immigru/core/logging/logger_interface.dart';

/// BLoC for managing the overall onboarding flow
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final OnboardingRepository _repository;
  final LanguageRepository _languageRepository;
  final ImmiGroveRepository _immiGroveRepository;
  final LoggerInterface _logger;

  OnboardingBloc({
    required OnboardingRepository repository,
    required LanguageRepository languageRepository,
    required ImmiGroveRepository immiGroveRepository,
    required LoggerInterface logger,
  })  : _repository = repository,
        _languageRepository = languageRepository,
        _immiGroveRepository = immiGroveRepository,
        _logger = logger,
        super(OnboardingState.initial()) {
    on<OnboardingInitialized>(_onInitialized);
    on<BirthCountryUpdated>(_onBirthCountryUpdated);
    on<CurrentStatusUpdated>(_onCurrentStatusUpdated);
    on<MigrationJourneyUpdated>(_onMigrationJourneyUpdated);
    on<ProfessionUpdated>(_onProfessionUpdated);
    on<LanguagesUpdated>(_onLanguagesUpdated);
    on<InterestsUpdated>(_onInterestsUpdated);
    on<NextStepRequested>(_onNextStepRequested);
    on<PreviousStepRequested>(_onPreviousStepRequested);
    on<StepSkipped>(_onStepSkipped);
    on<OnboardingCompleted>(_onOnboardingCompleted);
    on<OnboardingSaved>(_onOnboardingSaved);
    on<LanguagesSaveRequested>(_onLanguagesSaveRequested);
    on<ImmiGrovesUpdated>(_onImmiGrovesUpdated);
    on<ImmiGrovesSaveRequested>(_onImmiGrovesSaveRequested);
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
          birthCountryId: birthCountry?.toString(),
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
        'currentStatus': event.statusId,
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
        isLoading: true,
      ));

      _logger.i(
        'Migration journey updated with ${event.steps.length} steps',
        tag: 'Onboarding',
      );

      // Save migration steps to the backend
      await _repository.saveStepData('migrationJourney', {
        'migrationSteps': event.steps
            .map((step) => {
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
                })
            .toList(),
      });

      emit(state.copyWith(isLoading: false));
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

  /// Handle profession update event
  Future<void> _onProfessionUpdated(
    ProfessionUpdated event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      emit(state.copyWith(
        profession: event.profession,
        industry: event.industry,
        canMoveToNextStep: event.profession.isNotEmpty,
        isLoading: true,
      ));

      _logger.i(
        'Profession updated: ${event.profession}, Industry: ${event.industry}',
        tag: 'Onboarding',
      );

      // Save the profession data immediately to ensure it's persisted
      await _repository.saveStepData('profession', {
        'profession': event.profession,
        'industry': event.industry,
      });

      _logger.i(
        'Profession data saved successfully',
        tag: 'Onboarding',
      );

      emit(state.copyWith(isLoading: false));
    } catch (e, stackTrace) {
      _logger.e(
        'Error updating profession',
        tag: 'Onboarding',
        error: e,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(
        errorMessage: 'Failed to update profession. Please try again.',
        isLoading: false,
      ));
    }
  }

  /// Handle languages updated event
  Future<void> _onLanguagesUpdated(
    LanguagesUpdated event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      emit(state.copyWith(
        languages: event.languages,
        canMoveToNextStep: event.languages.isNotEmpty,
        isLoading: true,
      ));

      _logger.i(
        'Languages updated: ${event.languages.join(", ")}',
        tag: 'Onboarding',
      );

      // Only save to the general repository for consistency
      // We no longer save to the user-language endpoint here to avoid conflicts
      // with the LanguageBloc's save operation
      _logger.i(
        'Skipping direct language save in OnboardingBloc to avoid conflicts',
        tag: 'Onboarding',
      );

      // Also save to the general repository for consistency
      await _repository.saveStepData('languages', {
        'languages': event.languages,
      });

      _logger.i(
        'Languages data saved successfully',
        tag: 'Onboarding',
      );

      emit(state.copyWith(isLoading: false));
    } catch (e, stackTrace) {
      _logger.e(
        'Error updating languages',
        tag: 'Onboarding',
        error: e,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(
        errorMessage: 'Failed to update languages. Please try again.',
        isLoading: false,
      ));
    }
  }

  /// Handle interests updated event
  Future<void> _onInterestsUpdated(
    InterestsUpdated event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      emit(state.copyWith(
        interests: event.interests,
        isLoading: true,
      ));

      _logger.i(
        'Interests updated: ${event.interests.join(", ")}',
        tag: 'Onboarding',
      );

      // First attempt to save interests
      try {
        await _repository.saveStepData('interests', {
          'interests': event.interests,
        });

        _logger.i(
          'Interests data saved successfully',
          tag: 'Onboarding',
        );
      } catch (firstError) {
        // If we get a duplicate key error, wait a moment and try again
        if (firstError.toString().contains('duplicate key value')) {
          _logger.w(
            'Duplicate key detected, retrying after delay',
            tag: 'Onboarding',
          );

          // Add a small delay before retrying
          await Future.delayed(const Duration(milliseconds: 500));

          // Try again with the same data
          await _repository.saveStepData('interests', {
            'interests': event.interests,
          });

          _logger.i(
            'Interests data saved successfully on retry',
            tag: 'Onboarding',
          );
        } else {
          // If it's not a duplicate key error, rethrow
          rethrow;
        }
      }

      emit(state.copyWith(isLoading: false));
    } catch (e, stackTrace) {
      _logger.e(
        'Error updating interests',
        tag: 'Onboarding',
        error: e,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(
        errorMessage: 'Failed to update interests. Please try again.',
        isLoading: false,
      ));
    }
  }

  /// Handle next step request event
  void _onNextStepRequested(
    NextStepRequested event,
    Emitter<OnboardingState> emit,
  ) {
    // Check if auto-navigation should be prevented
    if (state.preventAutoNavigation) {
      _logger.i('Auto-navigation prevented by preventAutoNavigation flag',
          tag: 'Onboarding');

      // Reset the flag but don't navigate
      emit(state.copyWith(preventAutoNavigation: false));
      return;
    }

    // Get forceNavigation from the event
    bool forceNavigation = event.forceNavigation;
    // Special case: Always allow navigation from migration journey (step 2) to profession (step 3)
    if (state.currentStepIndex == 2) {
      forceNavigation = true;
      _logger.i('Forcing navigation from migration journey to profession step',
          tag: 'Onboarding');
    }

    // For debugging: Log the current state and navigation conditions
    _logger.i(
        'Current step: ${state.currentStepIndex}, canMoveToNextStep: ${state.canMoveToNextStep}, forceNavigation: $forceNavigation',
        tag: 'Onboarding');

    if (state.canMoveToNextStep || forceNavigation) {
      final nextStepIndex = state.currentStepIndex + 1;

      if (nextStepIndex < state.totalSteps) {
        // Only set isLastStep to true when we're on the ImmiGrove step (index 6)
        final isLastStep = nextStepIndex >= state.totalSteps - 1;

        emit(state.copyWith(
            currentStepIndex: nextStepIndex,
            isLastStep: isLastStep,
            canMoveToNextStep: (nextStepIndex == 1 &&
                    state.currentStatus !=
                        null) || // Allow moving to next step if current status is selected
                (nextStepIndex == 2 &&
                    state.migrationSteps
                        .isNotEmpty) || // Allow moving to next step if migration steps are added
                (nextStepIndex ==
                    3) || // Always allow moving to profession step
                (nextStepIndex == 4) || // Always allow moving to language step
                (nextStepIndex == 5) || // Always allow moving to interest step
                (nextStepIndex == 6) // Always allow moving to immi grove step
            ));

        // Log navigation for debugging
        _logger.i('Navigated to step $nextStepIndex', tag: 'Onboarding');
      } else {
        // Complete onboarding if we've reached the end
        add(const OnboardingCompleted());
      }
    } else {
      _logger.w(
          'Cannot move to next step: canMoveToNextStep=${state.canMoveToNextStep}',
          tag: 'Onboarding');
    }
  }

  /// Handle previous step request event
  void _onPreviousStepRequested(
    PreviousStepRequested event,
    Emitter<OnboardingState> emit,
  ) {
    if (state.currentStepIndex > 0) {
      // Calculate previous step index
      int prevIndex = state.currentStepIndex - 1;

      // Special case handling for specific steps
      bool preventAutoNavigation = false;

      // Special case: ensure language step (4) goes back to profession step (3)
      if (state.currentStepIndex == 4) {
        prevIndex = 3;
        preventAutoNavigation = true;
        _logger.i(
            'Special case: Going back from language step to profession step',
            tag: 'Onboarding');
      }

      // Special case: ensure ImmiGrove step (6) goes back to Interest step (5)
      else if (state.currentStepIndex == 6) {
        prevIndex = 5;
        _logger.i(
            'Special case: Going back from ImmiGrove step to Interest step',
            tag: 'Onboarding');
      }

      // Log the navigation for debugging
      _logger.i(
          'Navigating back from step ${state.currentStepIndex} to step $prevIndex',
          tag: 'Onboarding');

      emit(state.copyWith(
        currentStepIndex: prevIndex,
        isLastStep: false,
        // Add a flag to prevent auto-navigation after saving data
        preventAutoNavigation: preventAutoNavigation,
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

      // Set the onboarding completed flag
      emit(state.copyWith(
        isLoading: false,
        isOnboardingCompleted: true,
      ));

      _logger.i(
        'Onboarding completed successfully, navigating to home page',
        tag: 'Onboarding',
      );
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
        _logger.i('Saving birth country: ${state.birthCountryId}',
            tag: 'Onboarding');
        await _repository.saveStepData('birthCountry', {
          'countryId': state.birthCountryId,
          'countryName': state.birthCountryName,
        });
      }

      // Save current status (migrationStage) data
      if (state.currentStatus != null && state.currentStatus!.isNotEmpty) {
        _logger.i('Saving current status: ${state.currentStatus}',
            tag: 'Onboarding');
        await _repository.saveStepData('currentStatus', {
          'statusId': state.currentStatus,
        });
      }

      // Save migration steps if available
      if (state.migrationSteps.isNotEmpty) {
        _logger.i('Saving ${state.migrationSteps.length} migration steps',
            tag: 'Onboarding');
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

  /// Handle languages save request event
  Future<void> _onLanguagesSaveRequested(
    LanguagesSaveRequested event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      _logger.i(
          'Saving languages directly from OnboardingBloc: ${event.languageCodes}',
          tag: 'Onboarding');

      // First, get all languages to map codes to IDs
      final allLanguages = await _languageRepository.getLanguages();

      // Create a map of language codes to IDs
      final Map<String, int> codeToIdMap = {};
      for (final language in allLanguages) {
        codeToIdMap[language.isoCode.toLowerCase()] = language.id;
      }

      // Convert language codes to IDs
      final List<int> languageIds = [];
      for (final code in event.languageCodes) {
        final id = codeToIdMap[code.toLowerCase()];
        if (id != null) {
          languageIds.add(id);
        }
      }

      if (languageIds.isEmpty) {
        _logger.w(
            'No valid language IDs found from codes: ${event.languageCodes}',
            tag: 'Onboarding');
        return;
      }

      _logger.i('OnboardingBloc: Converted language codes to IDs: $languageIds',
          tag: 'Onboarding');

      // Save the language IDs using the repository
      final success = await _languageRepository.saveUserLanguages(languageIds);

      if (success) {
        _logger.i('Languages saved successfully: $languageIds',
            tag: 'Onboarding');
      } else {
        _logger.w('Failed to save languages: $languageIds', tag: 'Onboarding');
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Error saving languages',
        tag: 'Onboarding',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Handle ImmiGroves updated event
  Future<void> _onImmiGrovesUpdated(
    ImmiGrovesUpdated event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      _logger.i('Updating selected ImmiGroves: ${event.immiGroveIds}',
          tag: 'Onboarding');

      // Update the state with the selected ImmiGrove IDs
      emit(state.copyWith(
        immiGroveIds: event.immiGroveIds,
      ));

      _logger.i('ImmiGroves updated in state: ${state.immiGroveIds}',
          tag: 'Onboarding');
    } catch (e, stackTrace) {
      _logger.e(
        'Error updating ImmiGroves',
        tag: 'Onboarding',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Handle ImmiGroves save request event
  Future<void> _onImmiGrovesSaveRequested(
    ImmiGrovesSaveRequested event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      _logger.i('Saving ImmiGroves: ${event.immiGroveIds}', tag: 'Onboarding');

      // Save the ImmiGrove IDs using the repository
      await _immiGroveRepository.saveSelectedImmiGroves(event.immiGroveIds);

      _logger.i('ImmiGroves saved successfully', tag: 'Onboarding');
    } catch (e, stackTrace) {
      _logger.e(
        'Error saving ImmiGroves',
        tag: 'Onboarding',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
