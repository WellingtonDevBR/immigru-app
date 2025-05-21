import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/core/logging/logger_interface.dart';
import '../../../domain/usecases/get_interests_usecase.dart';
import '../../../domain/usecases/get_user_interests_usecase.dart';
import '../../../domain/usecases/save_user_interests_usecase.dart';
import 'interest_event.dart';
import 'interest_state.dart';

/// BLoC for managing interest selection
class InterestBloc extends Bloc<InterestEvent, InterestState> {
  final GetInterestsUseCase _getInterestsUseCase;
  final GetUserInterestsUseCase _getUserInterestsUseCase;
  final SaveUserInterestsUseCase _saveUserInterestsUseCase;
  final LoggerInterface _logger;

  InterestBloc({
    required GetInterestsUseCase getInterestsUseCase,
    required GetUserInterestsUseCase getUserInterestsUseCase,
    required SaveUserInterestsUseCase saveUserInterestsUseCase,
    required LoggerInterface logger,
  })  : _getInterestsUseCase = getInterestsUseCase,
        _getUserInterestsUseCase = getUserInterestsUseCase,
        _saveUserInterestsUseCase = saveUserInterestsUseCase,
        _logger = logger,
        super(const InterestState(isLoading: true)) {
    on<InterestsLoaded>(_onInterestsLoaded);
    on<UserInterestsLoaded>(_onUserInterestsLoaded);
    on<InterestToggled>(_onInterestToggled);
    on<InterestsSaved>(_onInterestsSaved);
    on<InterestSearchUpdated>(_onSearchUpdated);
    on<InterestsPreselected>(_onInterestsPreselected);
  }

  /// Handle loading all available interests
  Future<void> _onInterestsLoaded(
    InterestsLoaded event,
    Emitter<InterestState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      _logger.i('InterestBloc: Loading all interests');
      final interests = await _getInterestsUseCase();

      emit(state.copyWith(
        availableInterests: interests,
        isLoading: false,
      ));

      // After loading all interests, load user's selected interests
      add(const UserInterestsLoaded());
    } catch (e) {
      _logger.e('InterestBloc: Failed to load interests', error: e);
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load interests',
      ));
    }
  }

  /// Handle loading user's selected interests
  Future<void> _onUserInterestsLoaded(
    UserInterestsLoaded event,
    Emitter<InterestState> emit,
  ) async {
    try {
      _logger.i('InterestBloc: Loading user interests');
      final userInterests = await _getUserInterestsUseCase();

      if (userInterests.isNotEmpty) {
        final selectedIds =
            userInterests.map((interest) => interest.id.toString()).toList();

        _logger.i(
            'InterestBloc: User has ${selectedIds.length} interests selected');

        emit(state.copyWith(
          selectedInterestIds: selectedIds,
        ));
      }
    } catch (e) {
      _logger.e('InterestBloc: Failed to load user interests', error: e);
      // Silently handle error, user can still select interests
    }
  }

  /// Handle toggling selection of an interest
  void _onInterestToggled(
    InterestToggled event,
    Emitter<InterestState> emit,
  ) {
    final interestId = event.interestId.toString();
    final currentSelected = List<String>.from(state.selectedInterestIds);

    if (currentSelected.contains(interestId)) {
      _logger.i('InterestBloc: Removing interest: $interestId');
      currentSelected.remove(interestId);
    } else {
      _logger.i('InterestBloc: Adding interest: $interestId');
      currentSelected.add(interestId);
    }

    emit(state.copyWith(
      selectedInterestIds: currentSelected,
      saveSuccess: false,
    ));
  }

  /// Handle saving selected interests
  Future<void> _onInterestsSaved(
    InterestsSaved event,
    Emitter<InterestState> emit,
  ) async {
    if (state.isSaving) return;

    emit(state.copyWith(isSaving: true, saveSuccess: false));

    try {
      _logger.i('InterestBloc: Saving interests: ${event.interestIds}');
      await _saveUserInterestsUseCase(event.interestIds);
      _logger.i('InterestBloc: Interests saved successfully');
      emit(state.copyWith(isSaving: false, saveSuccess: true));
    } catch (e) {
      _logger.e('InterestBloc: Failed to save interests', error: e);
      // Silently handle error, user can still continue onboarding
      emit(state.copyWith(isSaving: false, saveSuccess: false));
    }
  }

  /// Handle search query update
  void _onSearchUpdated(
      InterestSearchUpdated event, Emitter<InterestState> emit) {
    emit(state.copyWith(searchQuery: event.query));
  }

  /// Update search query
  void updateSearchQuery(String query) {
    // Use add event pattern instead of direct emit
    add(InterestSearchUpdated(query));
  }

  /// Handle preselected interests
  void _onInterestsPreselected(
    InterestsPreselected event,
    Emitter<InterestState> emit,
  ) {
    _logger.i('InterestBloc: Preselecting interests: ${event.interestIds}');

    emit(state.copyWith(
      selectedInterestIds: event.interestIds,
      saveSuccess: false,
    ));
  }
}
