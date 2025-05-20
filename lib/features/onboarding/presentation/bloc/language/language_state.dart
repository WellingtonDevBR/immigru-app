import 'package:equatable/equatable.dart';
import '../../../domain/entities/language.dart';

/// State for the language selection step
class LanguageState extends Equatable {
  final List<Language> availableLanguages;
  final List<String> selectedLanguageCodes;
  final Map<String, int> languageIdMap;
  final bool isLoading;
  final bool isSaving;
  final bool saveSuccess;
  final String? errorMessage;
  final String searchQuery;
  
  const LanguageState({
    this.availableLanguages = const [],
    this.selectedLanguageCodes = const [],
    this.languageIdMap = const {},
    this.isLoading = false,
    this.isSaving = false,
    this.saveSuccess = false,
    this.errorMessage,
    this.searchQuery = '',
  });
  
  /// Create a copy of this state with the given fields replaced with new values
  LanguageState copyWith({
    List<Language>? availableLanguages,
    List<String>? selectedLanguageCodes,
    Map<String, int>? languageIdMap,
    bool? isLoading,
    bool? isSaving,
    bool? saveSuccess,
    String? errorMessage,
    String? searchQuery,
  }) {
    return LanguageState(
      availableLanguages: availableLanguages ?? this.availableLanguages,
      selectedLanguageCodes: selectedLanguageCodes ?? this.selectedLanguageCodes,
      languageIdMap: languageIdMap ?? this.languageIdMap,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
  
  /// Get filtered languages based on search query
  List<Language> get filteredLanguages => searchQuery.isEmpty
      ? availableLanguages
      : availableLanguages
          .where((language) => language.name
              .toLowerCase()
              .contains(searchQuery.toLowerCase()))
          .toList();
  
  @override
  List<Object?> get props => [
    availableLanguages,
    selectedLanguageCodes,
    languageIdMap,
    isLoading,
    isSaving,
    saveSuccess,
    errorMessage,
    searchQuery,
  ];
}
