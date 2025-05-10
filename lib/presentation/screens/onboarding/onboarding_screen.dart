import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/core/di/injection_container.dart';
import 'package:immigru/core/services/logger_service.dart';
import 'package:immigru/domain/entities/user.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_bloc.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_event.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_state.dart';
import 'package:immigru/presentation/screens/home/home_screen.dart';
import 'package:immigru/presentation/screens/onboarding/widgets/birth_country_step.dart';
import 'package:immigru/presentation/screens/onboarding/widgets/current_status_step.dart';
import 'package:immigru/presentation/screens/onboarding/widgets/migration_journey_step.dart';
import 'package:immigru/presentation/screens/onboarding/widgets/onboarding_progress_indicator.dart';
import 'package:immigru/presentation/screens/onboarding/widgets/profession_step.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

/// Screen that manages the onboarding flow for new users
class OnboardingScreen extends StatelessWidget {
  final User? user;

  const OnboardingScreen({
    Key? key,
    this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<OnboardingBloc>()
        ..add(const OnboardingInitialized()),
      child: const OnboardingView(),
    );
  }
}

/// Main view for the onboarding screen
class OnboardingView extends StatefulWidget {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final PageController _pageController;
  final LoggerService _logger = sl<LoggerService>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _pageController = PageController();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return BlocConsumer<OnboardingBloc, OnboardingState>(
      listenWhen: (previousState, currentState) => 
          previousState.currentStep != currentState.currentStep ||
          previousState.errorMessage != currentState.errorMessage,
      listener: (context, state) {
        // Handle page changes when step changes
        if (state.currentStep != OnboardingStep.birthCountry) {
          // Animate to the new page
          _animationController.forward(from: 0.0);
          
          // Only animate page if not on completed step
          if (state.currentStep != OnboardingStep.completed) {
            final pageIndex = OnboardingStep.values.indexOf(state.currentStep);
            _pageController.animateToPage(
              pageIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        }
        
        // Handle errors
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
        
        // Navigate to home screen when onboarding is completed
        if (state.currentStep == OnboardingStep.completed) {
          _logger.debug('OnboardingScreen', 'Onboarding completed, navigating to home');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Your Immigration Journey',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: state.currentStep != OnboardingStep.birthCountry
                ? IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    onPressed: () {
                      context.read<OnboardingBloc>().add(
                            const PreviousStepRequested(),
                          );
                    },
                  )
                : null,
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Progress indicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: OnboardingProgressIndicator(
                    progress: state.progressPercentage,
                  ),
                ),
                
                // Main content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(), // Disable swiping
                    children: [
                      // Birth country step
                      FadeTransition(
                        opacity: _animationController,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.1, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.easeOut,
                          )),
                          child: BirthCountryStep(
                            selectedCountry: state.data.birthCountry,
                            onCountrySelected: (country) {
                              context.read<OnboardingBloc>().add(
                                    BirthCountryUpdated(country),
                                  );
                            },
                          ),
                        ),
                      ),
                      
                      // Current status step
                      FadeTransition(
                        opacity: _animationController,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.1, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.easeOut,
                          )),
                          child: CurrentStatusStep(
                            selectedStatus: state.data.currentStatus,
                            onStatusSelected: (status) {
                              context.read<OnboardingBloc>().add(
                                    CurrentStatusUpdated(status),
                                  );
                            },
                          ),
                        ),
                      ),
                      
                      // Migration journey step
                      FadeTransition(
                        opacity: _animationController,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.1, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.easeOut,
                          )),
                          child: MigrationJourneyStep(
                            birthCountry: state.data.birthCountry ?? '',
                            migrationSteps: state.data.migrationSteps,
                            onAddStep: (step) {
                              context.read<OnboardingBloc>().add(
                                    MigrationStepAdded(step),
                                  );
                            },
                            onUpdateStep: (index, step) {
                              context.read<OnboardingBloc>().add(
                                    MigrationStepUpdated(index, step),
                                  );
                            },
                            onRemoveStep: (index) {
                              context.read<OnboardingBloc>().add(
                                    MigrationStepRemoved(index),
                                  );
                            },
                          ),
                        ),
                      ),
                      
                      // Profession step
                      FadeTransition(
                        opacity: _animationController,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.1, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.easeOut,
                          )),
                          child: ProfessionStep(
                            selectedProfession: state.data.profession,
                            onProfessionSelected: (profession) {
                              context.read<OnboardingBloc>().add(
                                    ProfessionUpdated(profession),
                                  );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Bottom buttons
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Skip button (only show for optional steps)
                      if (state.currentStep == OnboardingStep.migrationJourney ||
                          state.currentStep == OnboardingStep.profession)
                        TextButton(
                          onPressed: () {
                            context.read<OnboardingBloc>().add(
                                  const StepSkipped(),
                                );
                          },
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 80),
                      
                      // Next button
                      ElevatedButton(
                        onPressed: state.isCurrentStepValid
                            ? () {
                                context.read<OnboardingBloc>().add(
                                      const NextStepRequested(),
                                    );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32.0,
                            vertical: 12.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: const Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
