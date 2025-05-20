import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/onboarding/presentation/bloc/language/language_bloc.dart';
import 'package:immigru/features/onboarding/presentation/bloc/language/language_event.dart';
import 'package:immigru/features/onboarding/presentation/bloc/language/language_state.dart';
import 'package:immigru/shared/theme/app_colors.dart';

/// Widget for the language selection step in onboarding
class LanguageStepWidget extends StatefulWidget {
  final VoidCallback? onContinue;
  
  const LanguageStepWidget({super.key, this.onContinue});

  @override
  State<LanguageStepWidget> createState() => _LanguageStepWidgetState();
}

class _LanguageStepWidgetState extends State<LanguageStepWidget> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        final theme = Theme.of(context);
        final isDarkMode = theme.brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Header with gradient background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor,
                      AppColors.primaryColor.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.language,
                        color: Colors.white,
                        size: 28,
                      ),
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
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Select all languages you speak or are learning",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Search bar with modern design
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    context.read<LanguageBloc>().updateSearchQuery(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search languages',
                    prefixIcon:
                        const Icon(Icons.search, color: AppColors.primaryColor),
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
                "${state.selectedLanguageCodes.length} ${state.selectedLanguageCodes.length == 1 ? 'language' : 'languages'} selected",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),

              const SizedBox(height: 16),

              // Language list
              Expanded(
                child: state.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      )
                    : state.errorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  state.errorMessage!,
                                  style: TextStyle(
                                    color: theme.colorScheme.error,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () =>
                                      context.read<LanguageBloc>().add(
                                            const LanguagesLoaded(),
                                          ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : state.filteredLanguages.isEmpty
                            ? Center(
                                child: Text(
                                  'No languages found matching "${state.searchQuery}"',
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: ListView.builder(
                                  key: ValueKey<int>(
                                      state.filteredLanguages.length),
                                  itemCount: state.filteredLanguages.length,
                                  itemBuilder: (context, index) {
                                    final language =
                                        state.filteredLanguages[index];
                                    final lowerIsoCode =
                                        language.isoCode.toLowerCase();
                                    final isSelected = state
                                        .selectedLanguageCodes
                                        .contains(lowerIsoCode);

                                    return AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.primaryColor
                                                .withOpacity(0.1)
                                            : isDarkMode
                                                ? Colors.grey[800]
                                                : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.primaryColor
                                              : isDarkMode
                                                  ? Colors.grey[700]!
                                                  : Colors.grey[300]!,
                                          width: isSelected ? 2 : 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.03),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            // Toggle language selection
                                            context.read<LanguageBloc>().add(
                                                  LanguageToggled(
                                                      language.isoCode),
                                                );

                                            // Don't save immediately after toggling - we'll save when user clicks Next

                                            // Don't automatically navigate when selecting a language
                                          },
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        language.name,
                                                        style: TextStyle(
                                                          fontWeight: isSelected
                                                              ? FontWeight.bold
                                                              : FontWeight
                                                                  .normal,
                                                          color: isDarkMode
                                                              ? Colors.white
                                                              : Colors.black87,
                                                        ),
                                                      ),
                                                      if (language.nativeName !=
                                                              null &&
                                                          language.nativeName !=
                                                              language.name)
                                                        Text(
                                                          language.nativeName!,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: isDarkMode
                                                                ? Colors.white70
                                                                : Colors
                                                                    .black54,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                Checkbox(
                                                  value: isSelected,
                                                  onChanged: (_) {
                                                    // Toggle language selection without saving
                                                    context
                                                        .read<LanguageBloc>()
                                                        .add(
                                                          LanguageToggled(
                                                              language.isoCode),
                                                        );
                                                    // Don't save immediately - we'll save when user clicks Next
                                                  },
                                                  activeColor: AppColors.primaryColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
              ),

              // Display selected languages count at the bottom
              const SizedBox(height: 16),
              if (state.selectedLanguageCodes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    '${state.selectedLanguageCodes.length} ${state.selectedLanguageCodes.length == 1 ? 'language' : 'languages'} selected',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              // Show saving indicator if needed
              if (state.isSaving)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Center(
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
              
              // Removed the wider Next button as requested
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
