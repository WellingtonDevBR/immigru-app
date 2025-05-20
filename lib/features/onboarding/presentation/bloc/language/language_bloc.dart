import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/new_core/logging/logger_interface.dart';
import '../../../domain/usecases/get_languages_usecase.dart';
import '../../../domain/usecases/get_user_languages_usecase.dart';
import '../../../domain/usecases/save_user_languages_usecase.dart';
import 'language_event.dart';
import 'language_state.dart';

/// BLoC for managing language selection
class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  final GetLanguagesUseCase _getLanguagesUseCase;
  final GetUserLanguagesUseCase _getUserLanguagesUseCase;
  final SaveUserLanguagesUseCase _saveUserLanguagesUseCase;
  final LoggerInterface _logger;
  
  LanguageBloc({
    required GetLanguagesUseCase getLanguagesUseCase,
    required GetUserLanguagesUseCase getUserLanguagesUseCase,
    required SaveUserLanguagesUseCase saveUserLanguagesUseCase,
    required LoggerInterface logger,
  }) : _getLanguagesUseCase = getLanguagesUseCase,
       _getUserLanguagesUseCase = getUserLanguagesUseCase,
       _saveUserLanguagesUseCase = saveUserLanguagesUseCase,
       _logger = logger,
       super(const LanguageState(isLoading: true)) {
    on<LanguagesLoaded>(_onLanguagesLoaded);
    on<UserLanguagesLoaded>(_onUserLanguagesLoaded);
    on<LanguageToggled>(_onLanguageToggled);
    on<LanguagesSaved>(_onLanguagesSaved);
    on<LanguageSearchUpdated>(_onSearchUpdated);
  }
  
  /// Handle loading all available languages
  Future<void> _onLanguagesLoaded(
    LanguagesLoaded event,
    Emitter<LanguageState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    
    try {
      _logger.i('LanguageBloc: Loading all languages');
      final languages = await _getLanguagesUseCase();
      
      // Build a map of ISO codes to language IDs for easier lookup
      final Map<String, int> idMap = {};
      
      for (var language in languages) {
        final lowerIsoCode = language.isoCode.toLowerCase();
        idMap[lowerIsoCode] = language.id;
      }
      
      emit(state.copyWith(
        availableLanguages: languages,
        languageIdMap: idMap,
        isLoading: false,
      ));
    } catch (e) {
      _logger.e('LanguageBloc: Failed to load languages', error: e);
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load languages. Please try again.',
      ));
    }
  }
  
  /// Handle loading user's selected languages
  Future<void> _onUserLanguagesLoaded(
    UserLanguagesLoaded event,
    Emitter<LanguageState> emit,
  ) async {
    try {
      _logger.i('LanguageBloc: Loading user languages');
      final userLanguages = await _getUserLanguagesUseCase();
      
      if (userLanguages.isNotEmpty) {
        final selectedLanguageCodes = userLanguages
            .map((lang) => lang.isoCode.toLowerCase())
            .toList();
        
        _logger.i('LanguageBloc: User has ${selectedLanguageCodes.length} languages selected');
        
        emit(state.copyWith(
          selectedLanguageCodes: selectedLanguageCodes,
        ));
      }
    } catch (e) {
      _logger.e('LanguageBloc: Failed to load user languages', error: e);
      // Silently handle error, user can still select languages
    }
  }
  
  /// Handle toggling selection of a language
  void _onLanguageToggled(
    LanguageToggled event,
    Emitter<LanguageState> emit,
  ) {
    final normalizedCode = event.isoCode.toLowerCase();
    final currentSelected = List<String>.from(state.selectedLanguageCodes);
    
    if (currentSelected.contains(normalizedCode)) {
      _logger.i('LanguageBloc: Removing language: $normalizedCode');
      currentSelected.remove(normalizedCode);
    } else {
      _logger.i('LanguageBloc: Adding language: $normalizedCode');
      currentSelected.add(normalizedCode);
    }
    
    emit(state.copyWith(
      selectedLanguageCodes: currentSelected,
      // Reset saveSuccess when selection changes
      saveSuccess: false,
    ));
  }
  
  /// Handle saving user's selected languages
  Future<void> _onLanguagesSaved(
    LanguagesSaved event,
    Emitter<LanguageState> emit,
  ) async {
    try {
      // Validate that we have language IDs to save
      if (event.languageIds.isEmpty) {
        _logger.w('LanguageBloc: Attempted to save empty language array, ignoring request');
        emit(state.copyWith(
          isSaving: false,
          saveSuccess: false,
          errorMessage: 'No languages selected to save',
        ));
        return;
      }
      
      _logger.i('LanguageBloc: Saving languages: ${event.languageIds}');
      print('LanguageBloc: SAVING LANGUAGES: ${event.languageIds}');
      emit(state.copyWith(isSaving: true, saveSuccess: false, errorMessage: null));
      
      // Add more detailed logging
      _logger.i('LanguageBloc: Current state before saving: selectedLanguageCodes=${state.selectedLanguageCodes}');
      print('LanguageBloc: Current state before saving: selectedLanguageCodes=${state.selectedLanguageCodes}');
      
      // Call the save use case directly without delay - the data source will handle retries if needed
      print('LanguageBloc: Calling saveUserLanguagesUseCase with language IDs: ${event.languageIds}');
      final success = await _saveUserLanguagesUseCase(event.languageIds);
      
      // Log the result
      if (success) {
        print('LanguageBloc: Language saving SUCCESSFUL');
        _logger.i('LanguageBloc: Successfully saved languages: ${event.languageIds}');
      } else {
        print('LanguageBloc: Language saving FAILED');
        _logger.e('LanguageBloc: Failed to save languages: ${event.languageIds}');
      }
      
      if (success) {
        emit(state.copyWith(
          isSaving: false,
          saveSuccess: true,
          errorMessage: null,
        ));
        _logger.i('LanguageBloc: Successfully saved languages: ${event.languageIds}');
      } else {
        emit(state.copyWith(
          isSaving: false,
          saveSuccess: false,
          errorMessage: 'Failed to save languages',
        ));
        _logger.e('LanguageBloc: Failed to save languages');
      }
    } catch (e) {
      _logger.e('LanguageBloc: Exception while saving languages', error: e);
      print('LanguageBloc: EXCEPTION while saving languages: $e');
      emit(state.copyWith(
        isSaving: false,
        saveSuccess: false,
        errorMessage: e.toString(),
      ));
    }
  }
  
  /// Update search query
  void updateSearchQuery(String query) {
    // Use add event pattern instead of direct emit
    add(LanguageSearchUpdated(query));
  }
  
  /// Handle search query update
  void _onSearchUpdated(LanguageSearchUpdated event, Emitter<LanguageState> emit) {
    emit(state.copyWith(searchQuery: event.query));
  }
}
