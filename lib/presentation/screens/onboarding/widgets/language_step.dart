import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/core/di/injection_container.dart' as di;
import 'package:immigru/core/services/logger_service.dart';
import 'package:immigru/domain/entities/language.dart';
import 'package:immigru/domain/usecases/language_usecases.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_bloc.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_event.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

/// Widget for the language selection step in onboarding
class LanguageStep extends StatefulWidget {
  final List<String> selectedLanguages;
  final Function(List<String>) onLanguagesSelected;

  const LanguageStep({
    super.key,
    required this.selectedLanguages,
    required this.onLanguagesSelected,
  });

  @override
  State<LanguageStep> createState() => _LanguageStepState();
}

class _LanguageStepState extends State<LanguageStep> {
  // Language data
  final GetLanguagesUseCase _languagesUseCase = di.sl<GetLanguagesUseCase>();
  final SaveUserLanguagesUseCase _saveUserLanguagesUseCase = di.sl<SaveUserLanguagesUseCase>();
  final GetUserLanguagesUseCase _getUserLanguagesUseCase = di.sl<GetUserLanguagesUseCase>(); // Added use case
  final LoggerService _logger = di.sl<LoggerService>();
  List<Language> _languages = [];
  List<String> _selectedLanguages = [];
  Map<String, int> _languageIdMap = {}; // Maps ISO codes to language IDs
  bool _isLoading = true;
  String? _errorMessage;
  bool _isSaving = false;
  bool _isLoadingUserLanguages = false; // Track loading state for user languages

  // Search controller
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _logger.debug('LanguageStep', '========== INITIALIZING LANGUAGE STEP ==========');
    _logger.debug('LanguageStep', 'Initial selectedLanguages from widget: ${widget.selectedLanguages}');
    
    // Initialize with any languages passed from the parent widget
    _selectedLanguages = List.from(widget.selectedLanguages);
    _logger.debug('LanguageStep', 'Initialized _selectedLanguages: $_selectedLanguages');
    
    // Fetch all available languages first
    _logger.debug('LanguageStep', 'Starting language fetch sequence');
    _fetchLanguages().then((_) {
      _logger.debug('LanguageStep', 'Languages fetched, now fetching user languages');
      // Then fetch user's previously selected languages after we have the language list
      _fetchUserLanguages();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Fetch all available languages from the repository
  Future<void> _fetchLanguages() async {
    _logger.debug('LanguageStep', '========== FETCHING ALL LANGUAGES ==========');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _logger.debug('LanguageStep', 'Set loading state to true');

    try {
      _logger.debug('LanguageStep', 'Calling _languagesUseCase()');
      final languages = await _languagesUseCase();
      _logger.debug('LanguageStep', 'Received ${languages.length} languages from use case');

      // Build a map of ISO codes to language IDs for easier lookup
      final Map<String, int> idMap = {};
      
      _logger.debug('LanguageStep', 'Building language ID map');
      
      for (var language in languages) {
        // Store lowercase ISO code for consistent comparison
        final lowerIsoCode = language.isoCode.toLowerCase();
        idMap[lowerIsoCode] = language.id;
        _logger.debug('LanguageStep', 'Mapped language: id=${language.id}, isoCode=${language.isoCode}, lowerIsoCode=$lowerIsoCode, name=${language.name}');
      }

      _logger.debug('LanguageStep', 'Updating state with fetched languages');
      setState(() {
        _languages = languages;
        _languageIdMap = idMap;
        _isLoading = false;
      });
      _logger.debug('LanguageStep', 'Language fetch complete, _languages.length: ${_languages.length}, _languageIdMap.length: ${_languageIdMap.length}');
    } catch (e) {
      _logger.error('LanguageStep', 'Error fetching languages: $e');
      setState(() {
        _errorMessage = 'Failed to load languages. Please try again.';
        _isLoading = false;
      });
      _logger.debug('LanguageStep', 'Set error state: $_errorMessage');
    }
  }

  /// Fetch user's previously selected languages
  Future<void> _fetchUserLanguages() async {
    _logger.debug('LanguageStep', '========== FETCHING USER LANGUAGES ==========');
    _logger.debug('LanguageStep', 'Current _languages.length: ${_languages.length}');
    _logger.debug('LanguageStep', 'Current _languageIdMap: $_languageIdMap');
    
    setState(() {
      _isLoadingUserLanguages = true;
    });
    _logger.debug('LanguageStep', 'Set _isLoadingUserLanguages to true');

    try {
      _logger.debug('LanguageStep', 'Calling _getUserLanguagesUseCase()');
      // Get user's selected languages
      final userLanguages = await _getUserLanguagesUseCase();
      
      _logger.debug('LanguageStep', 'Received ${userLanguages.length} user languages from database');
      
      // Log each language for debugging
      for (var lang in userLanguages) {
        _logger.debug('LanguageStep', 'User language from DB: id=${lang.id}, isoCode=${lang.isoCode}, name=${lang.name}');
      }
      
      if (userLanguages.isNotEmpty) {
        // Extract language IDs from the fetched user languages
        final selectedLanguageIds = userLanguages.map((lang) => lang.id).toList();
        
        _logger.debug('LanguageStep', 'Extracted language IDs from user languages: $selectedLanguageIds');
        
        // Find the corresponding ISO codes from our available languages
        final List<String> selectedIsoCodes = [];
        
        _logger.debug('LanguageStep', 'Matching language IDs with available languages...');
        // Match language IDs with the available languages to get ISO codes
        for (var language in _languages) {
          _logger.debug('LanguageStep', 'Checking language: id=${language.id}, isoCode=${language.isoCode}, name=${language.name}');
          _logger.debug('LanguageStep', 'Is this ID in selectedLanguageIds? ${selectedLanguageIds.contains(language.id)}');
          
          if (selectedLanguageIds.contains(language.id)) {
            final lowerIsoCode = language.isoCode.toLowerCase();
            selectedIsoCodes.add(lowerIsoCode);
            _logger.debug('LanguageStep', '✅ MATCHED: Adding $lowerIsoCode to selectedIsoCodes');
          }
        }
        
        _logger.debug('LanguageStep', 'Final matched ISO codes: $selectedIsoCodes');
        
        if (selectedIsoCodes.isNotEmpty) {
          _logger.debug('LanguageStep', 'Updating state with selected ISO codes');
          setState(() {
            // Update selected languages with the matched ISO codes
            _selectedLanguages = selectedIsoCodes;
            _logger.debug('LanguageStep', 'Set _selectedLanguages to: $_selectedLanguages');
            
            // Notify parent widget about pre-selected languages
            widget.onLanguagesSelected(_selectedLanguages);
            _logger.debug('LanguageStep', 'Notified parent widget with onLanguagesSelected');
            
            // Update the bloc with pre-selected languages
            if (context.mounted) {
              _logger.debug('LanguageStep', 'Updating OnboardingBloc with LanguagesUpdated event');
              BlocProvider.of<OnboardingBloc>(context).add(
                LanguagesUpdated(_selectedLanguages),
              );
            }
          });
          
          // Log the selected languages after state update
          _logger.debug('LanguageStep', 'State updated, _selectedLanguages is now: $_selectedLanguages');
        } else {
          _logger.debug('LanguageStep', '❌ No matching ISO codes found for the user\'s language IDs');
        }
      } else {
        _logger.debug('LanguageStep', 'User has no selected languages in the database');
      }
    } catch (e) {
      _logger.error('LanguageStep', '❌ Error fetching user languages: $e');
      // Don't show an error to the user, they can still select languages
    } finally {
      setState(() {
        _isLoadingUserLanguages = false;
      });
      _logger.debug('LanguageStep', 'Set _isLoadingUserLanguages to false');
    }
  }

  /// Toggle selection of a language
  void _toggleLanguageSelection(String languageCode) {
    // Normalize the language code to lowercase for consistent comparison
    final normalizedCode = languageCode.toLowerCase();
    
    setState(() {
      if (_selectedLanguages.contains(normalizedCode)) {
        _selectedLanguages.remove(normalizedCode);
      } else {
        _selectedLanguages.add(normalizedCode);
      }
      widget.onLanguagesSelected(_selectedLanguages);
      
      // Update the onboarding bloc with the selected languages
      if (context.mounted) {
        // Convert selected ISO codes to language IDs
        final List<int> selectedIds = _selectedLanguages
            .where((isoCode) => _languageIdMap.containsKey(isoCode))
            .map((isoCode) => _languageIdMap[isoCode]!)
            .toList();
        
        // Dispatch the languages updated event to the bloc
        BlocProvider.of<OnboardingBloc>(context).add(
          LanguagesUpdated(_selectedLanguages),
        );
        
        // Save languages to the database if at least one is selected
        if (selectedIds.isNotEmpty && !_isSaving) {
          _saveLanguages(selectedIds);
        }
      }
    });
  }
  
  /// Save selected languages to the database
  Future<void> _saveLanguages(List<int> languageIds) async {
    if (_isSaving) return;
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      // Save languages to the database
      final success = await _saveUserLanguagesUseCase(languageIds);
      
      if (success) {
        // If successful, trigger save in the onboarding bloc
        if (context.mounted) {
          BlocProvider.of<OnboardingBloc>(context).add(const OnboardingSaved());
        }
      }
    } catch (e) {
      // Handle error silently, user can still continue onboarding

    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Log the selected languages for debugging
    _logger.debug('LanguageStep', '========== BUILDING LANGUAGE STEP WIDGET ==========');
    _logger.debug('LanguageStep', 'Current _selectedLanguages: $_selectedLanguages');
    _logger.debug('LanguageStep', 'Current _languages.length: ${_languages.length}');
    _logger.debug('LanguageStep', 'Current _isLoading: $_isLoading');
    _logger.debug('LanguageStep', 'Current _isLoadingUserLanguages: $_isLoadingUserLanguages');
    _logger.debug('LanguageStep', 'Current _searchQuery: $_searchQuery');
    
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Filter languages based on search query
    final filteredLanguages = _searchQuery.isEmpty
        ? _languages
        : _languages.where((language) =>
            language.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Container(
      color: isDarkMode ? AppColors.darkBackground : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Header with brand colors
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.language,
                    color: AppColors.primaryColor,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "I speak...",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Select all languages you speak or are learning",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Search bar
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search languages',
                  prefixIcon: const Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Selected languages count
            Text(
              "${_selectedLanguages.length} ${_selectedLanguages.length == 1 ? 'language' : 'languages'} selected",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Language list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _fetchLanguages,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : filteredLanguages.isEmpty
                          ? Center(
                              child: Text(
                                'No languages found matching "$_searchQuery"',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white70 : Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredLanguages.length,
                              itemBuilder: (context, index) {
                                final language = filteredLanguages[index];
                                final lowerIsoCode = language.isoCode.toLowerCase();
                                // Use case-insensitive comparison
                                final isSelected = _selectedLanguages.contains(lowerIsoCode);
                                
                                // Debug log for each language item
                                _logger.debug('LanguageStep', '-------- LANGUAGE ITEM --------');
                                _logger.debug('LanguageStep', 'Rendering language: id=${language.id}, isoCode=${language.isoCode}, lowerIsoCode=$lowerIsoCode, name=${language.name}');
                                _logger.debug('LanguageStep', 'Checking if _selectedLanguages contains $lowerIsoCode: $isSelected');
                                _logger.debug('LanguageStep', 'Current _selectedLanguages: $_selectedLanguages');
                                
                                if (isSelected) {
                                  _logger.debug('LanguageStep', '✅ CHECKBOX SHOULD BE SELECTED for ${language.name}');
                                } else {
                                  _logger.debug('LanguageStep', '❌ CHECKBOX SHOULD NOT BE SELECTED for ${language.name}');
                                }
                                
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryColor.withValues(alpha:0.1)
                                        : isDarkMode
                                            ? AppColors.cardDark
                                            : AppColors.cardLight,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primaryColor
                                          : isDarkMode
                                              ? AppColors.borderDark
                                              : AppColors.borderLight,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: InkWell(
                                    onTap: () => _toggleLanguageSelection(language.isoCode),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  language.name,
                                                  style: TextStyle(
                                                    fontWeight: isSelected
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                    color: isDarkMode ? Colors.white : Colors.black87,
                                                  ),
                                                ),
                                                if (language.nativeName != null &&
                                                    language.nativeName != language.name)
                                                  Text(
                                                    language.nativeName!,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: isDarkMode
                                                          ? Colors.white70
                                                          : Colors.black54,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Checkbox(
                                            value: isSelected,
                                            onChanged: (_) => _toggleLanguageSelection(language.isoCode),
                                            activeColor: AppColors.primaryColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
