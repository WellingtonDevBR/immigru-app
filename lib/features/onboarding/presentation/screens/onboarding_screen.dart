import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/onboarding/domain/entities/migration_step.dart';
import 'package:immigru/features/onboarding/presentation/widgets/profession/profession_step_widget_new.dart';
import 'package:immigru/core/country/domain/entities/country.dart';
import 'package:immigru/features/onboarding/presentation/bloc/onboarding/onboarding_bloc.dart';
import 'package:immigru/features/onboarding/presentation/bloc/onboarding/onboarding_event.dart';
import 'package:immigru/features/onboarding/presentation/bloc/onboarding/onboarding_state.dart';
import 'package:immigru/features/onboarding/presentation/bloc/onboarding/immi_grove_events.dart';
import 'package:immigru/features/onboarding/presentation/bloc/immi_grove/immi_grove_bloc.dart';
import 'package:immigru/features/onboarding/presentation/bloc/interest/interest_bloc.dart';
import 'package:immigru/features/auth/presentation/widgets/auth_wrapper.dart';
// Import removed: immi_grove_event.dart
import 'package:immigru/features/onboarding/presentation/widgets/birth_country/birth_country_step_widget.dart';
import 'package:immigru/features/onboarding/presentation/widgets/current_status/current_status_step_widget.dart';
import 'package:immigru/features/onboarding/presentation/widgets/migration_journey/migration_journey_step_widget.dart';
import 'package:immigru/features/onboarding/presentation/steps/language/language_step.dart';
import 'package:immigru/features/onboarding/presentation/steps/interest/interest_step.dart';
import 'package:immigru/features/onboarding/presentation/steps/immi_grove/immi_grove_step.dart';
import 'package:get_it/get_it.dart';
import 'package:immigru/core/di/service_locator.dart';
import 'package:immigru/core/logging/logger_interface.dart';
import 'package:immigru/shared/theme/app_colors.dart';

/// Main onboarding screen for the feature-first architecture
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The OnboardingBloc is now provided by the OnboardingFeature in app_new.dart
    // But we need to provide the ImmiGroveBloc for the ImmiGrove step
    return BlocProvider<ImmiGroveBloc>(
      create: (_) => GetIt.instance<ImmiGroveBloc>(),
      child: const OnboardingView(),
    );
  }
}

/// Main view for the onboarding screen
class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Add listener to PageController to handle manual page changes
    _pageController.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    // Only handle completed animations to avoid conflicts
    if (!_pageController.position.isScrollingNotifier.value) {
      final currentPage = _pageController.page?.round() ?? 0;
      final currentState = context.read<OnboardingBloc>().state;

      // Sync the bloc state with the page controller if they're out of sync
      if (currentPage != currentState.currentStepIndex) {
        // Special case for language step (index 4) going back to profession step (index 3)
        if (currentState.currentStepIndex == 4 && currentPage == 2) {
          // Force navigation to profession step (index 3) instead of migration journey (index 2)
          _pageController.jumpToPage(3);
          return;
        }

        if (currentPage < currentState.currentStepIndex) {
          // Going back
          context.read<OnboardingBloc>().add(const PreviousStepRequested());
        } else {
          // Going forward
          context.read<OnboardingBloc>().add(const NextStepRequested());
        }
      }
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  /// Navigate to the root screen after a delay
  /// This method avoids using BuildContext across async gaps
  void _navigateToRootAfterDelay(BuildContext inputContext) {
    // Use a longer delay to ensure the onboarding completion is processed
    // and the AuthBloc has time to refresh the user data
    Future.delayed(const Duration(milliseconds: 800), () {
      // Check if widget is still mounted before accessing context
      if (mounted) {
        // Use the current context directly after mounted check
        AuthWrapper.navigateToRoot(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<OnboardingBloc, OnboardingState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
            }

            // Navigate to home page when onboarding is completed
            if (state.isOnboardingCompleted) {
              // Log that we're navigating to home
              GetIt.instance<LoggerInterface>().i(
                'Onboarding completed, navigating to home screen',
                tag: 'OnboardingScreen',
              );

              // Use a separate method to handle navigation after a delay
              // This avoids using BuildContext across async gaps
              _navigateToRootAfterDelay(context);
            }

            // Handle navigation between steps
            final currentPage = _pageController.page?.round() ?? 0;
            if (state.currentStepIndex != currentPage) {
              // Use jumpToPage for immediate sync to avoid animation conflicts
              _pageController.jumpToPage(state.currentStepIndex);
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                // Progress indicator
                LinearProgressIndicator(
                  value: (state.currentStepIndex + 1) / state.totalSteps,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryColor,
                  ),
                ),

                // Main content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      // Birth country step
                      BirthCountryStepWidget(
                        onCountrySelected: (Country country) {
                          context.read<OnboardingBloc>().add(
                                BirthCountryUpdated(country),
                              );
                          // Automatically move to next step after country selection
                          context.read<OnboardingBloc>().add(
                                const NextStepRequested(),
                              );
                        },
                        selectedCountryId: state.birthCountryId,
                      ),

                      // Current status step
                      CurrentStatusStepWidget(
                        selectedStatusId: state.currentStatus,
                        onStatusSelected: (String statusId) {
                          context.read<OnboardingBloc>().add(
                                CurrentStatusUpdated(statusId),
                              );
                          // Automatically move to next step after status selection
                          context.read<OnboardingBloc>().add(
                                const NextStepRequested(),
                              );
                        },
                      ),

                      // Migration journey step
                      MigrationJourneyStepWidget(
                        birthCountryId: state.birthCountryId ?? '',
                        birthCountryName: state.birthCountryName ?? '',
                        onMigrationJourneyCompleted:
                            (List<MigrationStep> steps) {
                          // Update the onboarding state with the migration steps
                          context.read<OnboardingBloc>().add(
                                MigrationJourneyUpdated(steps),
                              );

                          // Force canMoveToNextStep to true
                          if (steps.isNotEmpty) {
                            // Store bloc reference before async gap
                            final onboardingBloc = context.read<OnboardingBloc>();
                            
                            // Longer delay to ensure the state is fully updated
                            Future.delayed(const Duration(milliseconds: 500),
                                () {
                              if (mounted) {
                                // Move to the next step
                                onboardingBloc.add(
                                      const NextStepRequested(),
                                    );
                              }
                            });
                          }
                        },
                      ),

                      // Profession step
                      ProfessionStepWidget(
                        selectedProfession: state.profession,
                        onProfessionSelected: (String profession) {
                          // Update the profession in the onboarding bloc
                          context.read<OnboardingBloc>().add(
                                ProfessionUpdated(
                                  profession,
                                  industry: state.industry,
                                ),
                              );

                          // Store bloc reference before async gap
                          final onboardingBloc = context.read<OnboardingBloc>();
                          
                          // Small delay to ensure state is updated before navigating
                          Future.delayed(const Duration(milliseconds: 300), () {
                            if (mounted) {
                              // Move to the next step
                              onboardingBloc.add(
                                    const NextStepRequested(),
                                  );
                            }
                          });
                        },
                      ),

                      // Language step
                      LanguageStep(
                        logger: ServiceLocator.instance<LoggerInterface>(),
                        selectedLanguages: state.languages,
                        onLanguagesSelected: (List<String> languages) {
                          // Only navigate when Next button is clicked
                          // No automatic navigation here
                        },
                      ),

                      // Interest step
                      BlocProvider(
                        create: (context) => GetIt.instance<InterestBloc>(),
                        child: InterestStep(
                          logger: ServiceLocator.instance<LoggerInterface>(),
                          selectedInterests: state.interests,
                          onInterestsSelected: (List<String> interests) {
                            // Update the interests in the onboarding bloc
                            context.read<OnboardingBloc>().add(
                                  InterestsUpdated(interests),
                                );
                            // Do not automatically navigate to next step
                            // Let the user control navigation with the Next button
                          },
                        ),
                      ),

                      // ImmiGrove step
                      ImmiGroveStep(
                        logger: ServiceLocator.instance<LoggerInterface>(),
                        selectedImmiGroveIds: state.immiGroveIds,
                        onImmiGrovesSelected: (List<String> immiGroveIds) {
                          // Update the onboarding state with the selected ImmiGroves
                          context.read<OnboardingBloc>().add(
                                ImmiGrovesUpdated(immiGroveIds),
                              );

                          // Mark onboarding as complete
                          context.read<OnboardingBloc>().add(
                                const OnboardingCompleted(),
                              );
                        },
                      ),
                    ],
                  ),
                ),

                // Navigation buttons - hidden for first and second steps
                if (state.currentStepIndex >
                    1) // Hide for first and second steps
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Back button - smaller width
                        if (state.currentStepIndex > 0)
                          Expanded(
                            flex: 2, // Smaller flex for back button
                            child: ElevatedButton(
                              onPressed: () {
                                // Special handling for specific steps
                                if (state.currentStepIndex == 4) {
                                  // First update the state in the bloc
                                  context.read<OnboardingBloc>().add(
                                        const PreviousStepRequested(),
                                      );

                                  // Force immediate navigation to profession step (index 3)
                                  // Use a small delay to ensure the state update happens first
                                  Future.delayed(
                                      const Duration(milliseconds: 50), () {
                                    _pageController.jumpToPage(3);
                                  });
                                } else if (state.currentStepIndex == 6) {
                                  // First update the state in the bloc
                                  context.read<OnboardingBloc>().add(
                                        const PreviousStepRequested(),
                                      );

                                  // Force immediate navigation to Interest step (index 5)
                                  // Use a small delay to ensure the state update happens first
                                  Future.delayed(
                                      const Duration(milliseconds: 50), () {
                                    _pageController.jumpToPage(5);
                                  });
                                } else {
                                  // For other steps, use normal animation
                                  // First update the state in the bloc
                                  context.read<OnboardingBloc>().add(
                                        const PreviousStepRequested(),
                                      );

                                  // Then manually navigate to the previous page with animation
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[200],
                                foregroundColor: Colors.black87,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Back'),
                            ),
                          )
                        else
                          const SizedBox.shrink(),

                        // Add spacing between buttons
                        if (state.currentStepIndex > 0)
                          const SizedBox(width: 16),

                        // Next/Finish button - larger width
                        Expanded(
                          flex: 3, // Larger flex for next button
                          child: ElevatedButton(
                            onPressed: (state.canMoveToNextStep ||
                                    state.currentStepIndex == 2 ||
                                    state.currentStepIndex == 3 ||
                                    state.currentStepIndex ==
                                        4) // Also enable for language step
                                ? () {
                                    // Special handling for language step (index 4)
                                    if (state.currentStepIndex == 4) {
                                      // For language step, trigger language saving in the LanguageBloc

                                      try {
                                        // Find the LanguageBloc from the current PageView child
                                        // This is safer than trying to access it directly
                                        final languageStep =
                                            _pageController.page?.round() == 4
                                                ? _pageController.page?.round()
                                                : null;

                                        if (languageStep != null) {
                                          // Update the onboarding bloc with selected languages
                                          final selectedLanguages =
                                              state.languages;

                                          if (selectedLanguages.isNotEmpty) {
                                            // Convert language codes to IDs using the onboarding repository

                                            // Use a simpler approach - save languages through the onboarding bloc
                                            // This will ensure proper coordination with the language repository
                                            context.read<OnboardingBloc>().add(
                                                  LanguagesSaveRequested(
                                                      selectedLanguages),
                                                );

                                            // Store bloc reference before async gap
                                            final onboardingBloc = context.read<OnboardingBloc>();
                                            
                                            // Then proceed to next step after a small delay
                                            Future.delayed(
                                                const Duration(
                                                    milliseconds: 800), () {
                                              if (mounted) {
                                                onboardingBloc.add(
                                                  const NextStepRequested(),
                                                );
                                              }
                                            });
                                          } else {
                                            // If no languages selected, just proceed
                                            context.read<OnboardingBloc>().add(
                                                  const NextStepRequested(),
                                                );
                                          }
                                        } else {
                                          context.read<OnboardingBloc>().add(
                                                const NextStepRequested(),
                                              );
                                        }
                                      } catch (e) {
                                        // Fallback to just navigating if there's an error
                                        context.read<OnboardingBloc>().add(
                                              const NextStepRequested(),
                                            );
                                      }
                                    } else {
                                      // Special handling for profession step (index 3) to language step (index 4)
                                      if (state.currentStepIndex == 3) {
                                        // Force navigation from profession to language
                                        context.read<OnboardingBloc>().add(
                                              const NextStepRequested(
                                                  forceNavigation: true),
                                            );
                                      } else {
                                        // For other steps, just proceed to next step
                                        context.read<OnboardingBloc>().add(
                                              const NextStepRequested(),
                                            );
                                      }
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              state.isLastStep ? 'Finish' : 'Next',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
