import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/onboarding/presentation/bloc/interest/interest_bloc.dart';
import 'package:immigru/features/onboarding/presentation/bloc/interest/interest_event.dart';
import 'package:immigru/features/onboarding/presentation/bloc/interest/interest_state.dart';
import 'package:immigru/features/onboarding/presentation/common/onboarding_step_header.dart';
import 'package:immigru/shared/theme/app_colors.dart';

/// Widget for the interest selection step in onboarding
class InterestStepWidget extends StatefulWidget {
  final VoidCallback? onContinue;
  
  const InterestStepWidget({super.key, this.onContinue});

  @override
  State<InterestStepWidget> createState() => _InterestStepWidgetState();
}

class _InterestStepWidgetState extends State<InterestStepWidget> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InterestBloc, InterestState>(
      builder: (context, state) {
        final theme = Theme.of(context);
        final isDarkMode = theme.brightness == Brightness.dark;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              
              // Standard onboarding header
              OnboardingStepHeader(
                title: 'What are you interested in?',
                subtitle: 'Select interests to personalize your experience',
              ),
              
              const SizedBox(height: 24),
              
              // Selected interests count
              Text(
                'Selected: ${state.selectedInterestIds.length}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Search field
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  context.read<InterestBloc>().updateSearchQuery(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search interests...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primaryColor,
                    ),
                  ),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Loading indicator or error message
              if (state.isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else if (state.errorMessage != null)
                Center(
                  child: Text(
                    state.errorMessage!,
                    style: TextStyle(color: Colors.red[700]),
                  ),
                )
              else if (state.filteredInterests.isEmpty)
                Center(
                  child: Text(
                    'No interests found',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                )
              else
                // Interests grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: state.filteredInterests.length,
                    itemBuilder: (context, index) {
                      final interest = state.filteredInterests[index];
                      final isSelected = state.selectedInterestIds.contains(interest.id);
                      
                      return InkWell(
                        onTap: () {
                          context.read<InterestBloc>().add(
                            InterestToggled(interest.id),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : isDarkMode
                                      ? Colors.grey[700]!
                                      : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            color: isSelected
                                ? AppColors.primaryColor.withValues(alpha:0.1)
                                : isDarkMode
                                    ? Colors.grey[800]
                                    : Colors.white,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  interest.name,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? AppColors.primaryColor
                                        : isDarkMode
                                            ? Colors.white
                                            : Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                isSelected ? Icons.check_circle : Icons.circle_outlined,
                                color: isSelected
                                    ? AppColors.primaryColor
                                    : isDarkMode
                                        ? Colors.grey[600]
                                        : Colors.grey[400],
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              
              // Continue button at the bottom
              const SizedBox(height: 24),
              if (state.selectedInterestIds.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.isSaving
                        ? null
                        : widget.onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: state.isSaving
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
