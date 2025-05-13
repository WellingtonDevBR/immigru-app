import 'package:flutter/material.dart';
import 'package:immigru/core/di/injection_container.dart' as di;
import 'package:immigru/domain/entities/language.dart';
import 'package:immigru/domain/usecases/language_usecases.dart';
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
  List<Language> _languages = [];
  List<String> _selectedLanguages = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Search controller
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedLanguages = List.from(widget.selectedLanguages);
    _fetchLanguages();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Fetch languages from the repository
  Future<void> _fetchLanguages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final languages = await _languagesUseCase();

      setState(() {
        _languages = languages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load languages. Please try again.';
        _isLoading = false;
      });
    }
  }

  /// Toggle selection of a language
  void _toggleLanguageSelection(String languageCode) {
    setState(() {
      if (_selectedLanguages.contains(languageCode)) {
        _selectedLanguages.remove(languageCode);
      } else {
        _selectedLanguages.add(languageCode);
      }
      widget.onLanguagesSelected(_selectedLanguages);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
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
                                final isSelected = _selectedLanguages.contains(language.isoCode);
                                
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryColor.withOpacity(0.1)
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
