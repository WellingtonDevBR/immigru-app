import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/onboarding/domain/entities/profession.dart';
import 'package:immigru/features/onboarding/presentation/bloc/profession/profession_event.dart';
import 'package:immigru/features/onboarding/presentation/bloc/profession/profession_state.dart';
import 'package:immigru/features/onboarding/presentation/bloc/onboarding/onboarding_bloc.dart';
import 'package:immigru/features/onboarding/presentation/bloc/onboarding/onboarding_event.dart';
import 'package:immigru/new_core/logging/logger_interface.dart';

/// BLoC for managing profession selection in the onboarding process
class ProfessionBloc extends Bloc<ProfessionEvent, ProfessionState> {
  final OnboardingBloc _onboardingBloc;
  final LoggerInterface _logger;

  // List of common professions
  final List<Profession> _commonProfessions = [
    const Profession(name: 'Healthcare Professional'),
    const Profession(name: 'Engineer'),
    const Profession(name: 'IT Professional'),
    const Profession(name: 'Teacher/Educator'),
    const Profession(name: 'Business/Management'),
    const Profession(name: 'Finance Professional'),
    const Profession(name: 'Skilled Trade'),
    const Profession(name: 'Student'),
    const Profession(name: 'Researcher/Academic'),
    const Profession(name: 'Legal Professional'),
    const Profession(name: 'Arts/Creative'),
    const Profession(name: 'Hospitality'),
    const Profession(name: 'Agriculture'),
    const Profession(name: 'Retired'),
    const Profession(name: 'Other'),
  ];

  /// Creates a new instance of [ProfessionBloc]
  ProfessionBloc({
    required OnboardingBloc onboardingBloc,
    required LoggerInterface logger,
  })  : _onboardingBloc = onboardingBloc,
        _logger = logger,
        super(const ProfessionState.initial()) {
    on<ProfessionInitialized>(_onProfessionInitialized);
    on<ProfessionSelected>(_onProfessionSelected);
    on<CustomProfessionEntered>(_onCustomProfessionEntered);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<ShowCustomInputToggled>(_onShowCustomInputToggled);
  }

  /// Handles the [ProfessionInitialized] event
  void _onProfessionInitialized(
    ProfessionInitialized event,
    Emitter<ProfessionState> emit,
  ) {
    _logger.i('ProfessionBloc: Initializing profession step');
    
    // Get the selected profession from the onboarding bloc if available
    final onboardingState = _onboardingBloc.state;
    final selectedProfession = onboardingState.profession != null
        ? Profession(name: onboardingState.profession!, industry: onboardingState.industry)
        : null;
    
    emit(state.copyWith(
      status: ProfessionStatus.loaded,
      selectedProfession: selectedProfession,
      // Use system source when initializing with existing data
      selectionSource: selectedProfession != null ? SelectionSource.system : SelectionSource.initial,
      availableProfessions: _commonProfessions,
      filteredProfessions: _commonProfessions,
    ));
  }

  /// Handles the [ProfessionSelected] event
  void _onProfessionSelected(
    ProfessionSelected event,
    Emitter<ProfessionState> emit,
  ) {
    _logger.i('ProfessionBloc: Profession selected: ${event.profession.name}');
    
    emit(state.copyWith(
      selectedProfession: event.profession,
      status: ProfessionStatus.saving,
      // Mark this as a user action (manual selection)
      selectionSource: SelectionSource.userAction,
    ));
    
    // Update the onboarding bloc with the selected profession
    _onboardingBloc.add(ProfessionUpdated(
      event.profession.name,
      industry: event.profession.industry,
    ));
    
    emit(state.copyWith(
      status: ProfessionStatus.saved,
      // Keep the userAction source
      selectionSource: SelectionSource.userAction,
    ));
  }

  /// Handles the [CustomProfessionEntered] event
  void _onCustomProfessionEntered(
    CustomProfessionEntered event,
    Emitter<ProfessionState> emit,
  ) {
    _logger.i('ProfessionBloc: Custom profession entered: ${event.profession}');
    
    if (event.profession.trim().isEmpty) {
      emit(state.copyWith(
        status: ProfessionStatus.error,
        errorMessage: 'Please enter a profession',
      ));
      return;
    }
    
    final customProfession = Profession(
      name: event.profession.trim(),
      industry: event.industry?.trim(),
      isCustom: true,
    );
    
    add(ProfessionSelected(customProfession));
  }

  /// Handles the [SearchQueryChanged] event
  void _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<ProfessionState> emit,
  ) {
    _logger.i('ProfessionBloc: Search query changed: ${event.query}');
    
    if (event.query.isEmpty) {
      emit(state.copyWith(
        searchQuery: '',
        filteredProfessions: state.availableProfessions,
      ));
      return;
    }

    final query = event.query.toLowerCase();
    final filteredProfessions = state.availableProfessions
        .where((profession) => profession.name.toLowerCase().contains(query))
        .toList();

    emit(state.copyWith(
      searchQuery: event.query,
      filteredProfessions: filteredProfessions,
    ));
  }

  /// Handles the [ShowCustomInputToggled] event
  void _onShowCustomInputToggled(
    ShowCustomInputToggled event,
    Emitter<ProfessionState> emit,
  ) {
    _logger.i('ProfessionBloc: Show custom input toggled: ${event.show}');
    
    emit(state.copyWith(
      showCustomInput: event.show,
    ));
  }
}
