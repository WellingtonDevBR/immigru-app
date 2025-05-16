import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/onboarding/domain/entities/migration_step.dart';
import 'package:immigru/new_core/country/domain/entities/country.dart';
import 'package:immigru/features/onboarding/presentation/bloc/onboarding/onboarding_bloc.dart';
import 'package:immigru/features/onboarding/presentation/bloc/onboarding/onboarding_event.dart';
import 'package:immigru/features/onboarding/presentation/bloc/onboarding/onboarding_state.dart';
import 'package:immigru/features/onboarding/presentation/widgets/birth_country/birth_country_step_widget.dart';
import 'package:immigru/features/onboarding/presentation/widgets/current_status/current_status_step_widget.dart';
import 'package:immigru/features/onboarding/presentation/widgets/migration_journey/migration_journey_step_widget.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

/// Main onboarding screen for the feature-first architecture
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The OnboardingBloc is now provided by the OnboardingFeature in app_new.dart
    // So we can just use the OnboardingView directly
    return const OnboardingView();
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
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<OnboardingBloc, OnboardingState>(
          listener: (context, state) {
            // Handle navigation between steps
            if (state.currentStepIndex != _pageController.page?.round()) {
              _pageController.animateToPage(
                state.currentStepIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
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
                        onMigrationJourneyCompleted: (List<MigrationStep> steps) {
                          // Update the onboarding state with the migration steps
                          context.read<OnboardingBloc>().add(
                                MigrationJourneyUpdated(steps),
                              );
                          // Move to the next step
                          context.read<OnboardingBloc>().add(
                                const NextStepRequested(),
                              );
                        },
                      ),
                    ],
                  ),
                ),
                
                // Navigation buttons - hidden for first and second steps
                if (state.currentStepIndex > 1) // Hide for first and second steps
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
                                context.read<OnboardingBloc>().add(
                                      const PreviousStepRequested(),
                                  );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[200],
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                            onPressed: state.canMoveToNextStep
                                ? () {
                                    context.read<OnboardingBloc>().add(
                                          const NextStepRequested(),
                                        );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
