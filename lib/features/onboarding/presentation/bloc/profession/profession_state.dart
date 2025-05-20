import 'package:equatable/equatable.dart';
import 'package:immigru/features/onboarding/domain/entities/profession.dart';

/// Status of the profession selection process
enum ProfessionStatus {
  /// Initial state
  initial,
  
  /// Loading professions
  loading,
  
  /// Professions loaded
  loaded,
  
  /// Saving selected profession
  saving,
  
  /// Profession saved
  saved,
  
  /// Error occurred
  error,
}

/// Source of the profession selection
enum SelectionSource {
  /// Selected by the user
  userAction,
  
  /// Selected programmatically (e.g., when restoring state)
  system,
  
  /// Default selection
  initial,
}

/// State for the profession selection process
class ProfessionState extends Equatable {
  /// Current status of the profession selection
  final ProfessionStatus status;
  
  /// Selected profession
  final Profession? selectedProfession;
  
  /// List of available professions
  final List<Profession> availableProfessions;
  
  /// List of filtered professions based on search query
  final List<Profession> filteredProfessions;
  
  /// Current search query
  final String searchQuery;
  
  /// Whether to show the custom profession input
  final bool showCustomInput;
  
  /// Error message if an error occurred
  final String? errorMessage;
  
  /// Source of the profession selection
  final SelectionSource selectionSource;

  /// Creates a new instance of [ProfessionState]
  const ProfessionState({
    required this.status,
    this.selectedProfession,
    this.selectionSource = SelectionSource.initial,
    required this.availableProfessions,
    required this.filteredProfessions,
    required this.searchQuery,
    required this.showCustomInput,
    this.errorMessage,
  });

  /// Creates the initial state
  const ProfessionState.initial()
      : status = ProfessionStatus.initial,
        selectedProfession = null,
        selectionSource = SelectionSource.initial,
        availableProfessions = const [],
        filteredProfessions = const [],
        searchQuery = '',
        showCustomInput = false,
        errorMessage = null;

  /// Creates a copy of this state with the given fields replaced with new values
  ProfessionState copyWith({
    ProfessionStatus? status,
    Profession? selectedProfession,
    SelectionSource? selectionSource,
    List<Profession>? availableProfessions,
    List<Profession>? filteredProfessions,
    String? searchQuery,
    bool? showCustomInput,
    String? errorMessage,
  }) {
    return ProfessionState(
      status: status ?? this.status,
      selectedProfession: selectedProfession ?? this.selectedProfession,
      selectionSource: selectionSource ?? this.selectionSource,
      availableProfessions: availableProfessions ?? this.availableProfessions,
      filteredProfessions: filteredProfessions ?? this.filteredProfessions,
      searchQuery: searchQuery ?? this.searchQuery,
      showCustomInput: showCustomInput ?? this.showCustomInput,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedProfession,
        availableProfessions,
        filteredProfessions,
        searchQuery,
        showCustomInput,
        errorMessage,
      ];
}
