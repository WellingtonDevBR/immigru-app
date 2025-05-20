import 'package:equatable/equatable.dart';
import '../../../domain/entities/interest.dart';

/// State for the interest selection step
class InterestState extends Equatable {
  final List<Interest> availableInterests;
  final List<String> selectedInterestIds;
  final bool isLoading;
  final bool isSaving;
  final bool saveSuccess;
  final String? errorMessage;
  final String searchQuery;
  
  const InterestState({
    this.availableInterests = const [],
    this.selectedInterestIds = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.saveSuccess = false,
    this.errorMessage,
    this.searchQuery = '',
  });
  
  /// Create a copy of this state with the given fields replaced with new values
  InterestState copyWith({
    List<Interest>? availableInterests,
    List<String>? selectedInterestIds,
    bool? isLoading,
    bool? isSaving,
    bool? saveSuccess,
    String? errorMessage,
    String? searchQuery,
  }) {
    return InterestState(
      availableInterests: availableInterests ?? this.availableInterests,
      selectedInterestIds: selectedInterestIds ?? this.selectedInterestIds,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
  
  /// Get filtered interests based on search query
  List<Interest> get filteredInterests => searchQuery.isEmpty
      ? availableInterests
      : availableInterests
          .where((interest) => interest.name
              .toLowerCase()
              .contains(searchQuery.toLowerCase()))
          .toList();
  
  /// Get selected interests
  List<Interest> get selectedInterests => availableInterests
      .where((interest) => selectedInterestIds.contains(interest.id.toString()))
      .toList();
  
  @override
  List<Object?> get props => [
    availableInterests,
    selectedInterestIds,
    isLoading,
    isSaving,
    saveSuccess,
    errorMessage,
    searchQuery,
  ];
}
