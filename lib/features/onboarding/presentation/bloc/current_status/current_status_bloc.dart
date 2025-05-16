import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/onboarding/domain/entities/migration_status.dart';
import 'package:immigru/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:immigru/features/onboarding/presentation/bloc/current_status/current_status_event.dart';
import 'package:immigru/features/onboarding/presentation/bloc/current_status/current_status_state.dart';
import 'package:immigru/shared/interfaces/logger_interface.dart';

/// BLoC for managing the current status step
class CurrentStatusBloc extends Bloc<CurrentStatusEvent, CurrentStatusState> {
  final OnboardingFeatureRepository _repository;
  final LoggerInterface _logger;

  CurrentStatusBloc({
    required OnboardingFeatureRepository repository,
    required LoggerInterface logger,
  })  : _repository = repository,
        _logger = logger,
        super(CurrentStatusState.initial()) {
    on<CurrentStatusInitialized>(_onInitialized);
    on<CurrentStatusSelected>(_onStatusSelected);
    on<CurrentStatusSaved>(_onStatusSaved);
  }

  /// Handle initialization event
  Future<void> _onInitialized(
    CurrentStatusInitialized event,
    Emitter<CurrentStatusState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      
      // Load existing onboarding data to check for previously selected status
      final onboardingData = await _repository.getOnboardingData();
      
      // Find the matching status in our available statuses
      MigrationStatus? selectedStatus;
      if (onboardingData != null && onboardingData.currentStatus != null && onboardingData.currentStatus!.isNotEmpty) {
        selectedStatus = state.availableStatuses.firstWhere(
          (status) => status.id == onboardingData.currentStatus,
          orElse: () => state.availableStatuses.first,
        );
      }
      
      _logger.i(
        'Initialized with status: ${selectedStatus?.id ?? 'none'}',
        tag: 'CurrentStatusBloc',
      );
      
      emit(state.copyWith(
        selectedStatus: selectedStatus,
        isLoading: false,
      ));
    } catch (e, stackTrace) {
      _logger.e(
        'Error initializing current status step',
        tag: 'CurrentStatusBloc',
        error: e,
        stackTrace: stackTrace,
      );
      
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load current status data',
      ));
    }
  }

  /// Handle status selection event
  Future<void> _onStatusSelected(
    CurrentStatusSelected event,
    Emitter<CurrentStatusState> emit,
  ) async {
    _logger.i(
      'Status selected: ${event.status.id}',
      tag: 'CurrentStatusBloc',
    );
    
    emit(state.copyWith(
      selectedStatus: event.status,
      errorMessage: null,
      isSaving: true,
    ));
    
    try {
      // Save the selected status to UserProfile.MigrationStage immediately
      await _repository.saveStepData('currentStatus', {
        'statusId': event.status.id,
      });
      
      _logger.i(
        'Successfully saved current status: ${event.status.id}',
        tag: 'CurrentStatusBloc',
      );
      
      emit(state.copyWith(isSaving: false));
    } catch (e, stackTrace) {
      _logger.e(
        'Error saving current status',
        tag: 'CurrentStatusBloc',
        error: e,
        stackTrace: stackTrace,
      );
      
      emit(state.copyWith(
        errorMessage: 'Failed to save current status. Please try again.',
        isSaving: false,
      ));
    }
  }

  /// Handle save event
  Future<void> _onStatusSaved(
    CurrentStatusSaved event,
    Emitter<CurrentStatusState> emit,
  ) async {
    // Only save if a status is selected
    if (state.selectedStatus == null) {
      _logger.w(
        'Attempted to save without selecting a status',
        tag: 'CurrentStatusBloc',
      );
      
      emit(state.copyWith(
        errorMessage: 'Please select your current status',
      ));
      return;
    }

    try {
      emit(state.copyWith(isSaving: true, errorMessage: null));
      
      // Save the selected status to onboarding data
      await _repository.saveStepData('currentStatus', {
        'statusId': state.selectedStatus!.id,
      });
      
      _logger.i(
        'Successfully saved current status: ${state.selectedStatus!.id}',
        tag: 'CurrentStatusBloc',
      );
      
      emit(state.copyWith(isSaving: false));
    } catch (e, stackTrace) {
      _logger.e(
        'Error saving current status',
        tag: 'CurrentStatusBloc',
        error: e,
        stackTrace: stackTrace,
      );
      
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to save your current status',
      ));
    }
  }
}
