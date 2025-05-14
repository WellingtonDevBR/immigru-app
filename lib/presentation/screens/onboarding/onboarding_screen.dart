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
import 'package:immigru/presentation/screens/onboarding/widgets/interest_step.dart';
import 'package:immigru/presentation/screens/onboarding/widgets/language_step.dart';
import 'package:immigru/presentation/screens/onboarding/widgets/migration_journey/migration_journey_step_widget.dart';
import 'package:immigru/presentation/screens/onboarding/widgets/onboarding_progress_indicator.dart';
import 'package:immigru/presentation/screens/onboarding/widgets/profession_step.dart';
import 'package:immigru/presentation/screens/onboarding/widgets/profile/basic_info_step.dart';
import 'package:immigru/presentation/screens/onboarding/widgets/profile/bio_step.dart';
import 'package:immigru/presentation/screens/onboarding/widgets/profile/display_name_step.dart';
// Location step has been removed
// Photo step has been integrated into BasicInfoStep
// Privacy step has been removed
import 'package:immigru/presentation/screens/onboarding/widgets/immi_groves_step.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

/// Screen that manages the onboarding flow for new users
class OnboardingScreen extends StatelessWidget {
  final User? user;

  const OnboardingScreen({
    super.key,
    this.user,
  });

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
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> with TickerProviderStateMixin {
  // Animation controllers for different aspects of the UI
  late final AnimationController _pageTransitionController;
  late final AnimationController _contentAnimationController;
  late final PageController _pageController;
  final LoggerService _logger = sl<LoggerService>();
  
  // Animation for the page indicator
  late final Animation<double> _pageIndicatorAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Controller for page transitions
    _pageTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    // Controller for content animations (buttons, fields, etc.)
    _contentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    // Initialize page controller
    _pageController = PageController();
    
    // Start content animation immediately for the first screen
    _contentAnimationController.forward();
    
    // Animation for the progress indicator
    _pageIndicatorAnimation = CurvedAnimation(
      parent: _pageTransitionController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageTransitionController.dispose();
    _contentAnimationController.dispose();
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
        
        if (state.currentStep != OnboardingStep.completed) {
          // Only handle transitions between different steps
          // Prepare animations for page transition
          _contentAnimationController.reset();
          _pageTransitionController.reset();
          
          // Get the page index based on the current step
          final pageIndex = OnboardingStep.values.indexOf(state.currentStep);
          
          // Animate to the new page with a smooth transition
          _pageController.animateToPage(
            pageIndex,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
          );
          
          // Start animations in sequence for a polished effect
          _pageTransitionController.forward().then((_) {
            _contentAnimationController.forward();
          });
        } else if (state.currentStep == OnboardingStep.completed) {
          // Special handling for completion
          _pageTransitionController.forward();
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
              state.currentStep == OnboardingStep.migrationJourney ? 'Your International Journey' : 'Your Immigration Journey',
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress indicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: AnimatedBuilder(
                    animation: _pageIndicatorAnimation,
                    builder: (context, child) {
                      return OnboardingProgressIndicator(
                        progress: state.progressPercentage,
                      );
                    },
                  ),
                ),
                
                // Main content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(), // Disable swiping
                    onPageChanged: (index) {
                      // Animation will be handled by the listener
                    },
                    children: [
                      // Birth country step with animations
                      AnimatedBuilder(
                        animation: _contentAnimationController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _contentAnimationController,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.05, 0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: _contentAnimationController,
                                curve: Curves.easeOutCubic,
                              )),
                              child: child,
                            ),
                          );
                        },
                        child: BirthCountryStep(
                          selectedCountryId: state.data.birthCountry,
                          onCountrySelected: (country) {
                            context.read<OnboardingBloc>().add(
                                  BirthCountryUpdated(country.isoCode),
                                );
                          },
                        ),
                      ),

                      
                      // Current status step with animations
                      AnimatedBuilder(
                        animation: _contentAnimationController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _contentAnimationController,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.05, 0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: _contentAnimationController,
                                curve: Curves.easeOutCubic,
                              )),
                              child: child,
                            ),
                          );
                        },
                        child: CurrentStatusStep(
                          selectedStatus: state.data.currentStatus,
                          onStatusSelected: (status) {
                            context.read<OnboardingBloc>().add(
                                  CurrentStatusUpdated(status),
                                );
                          },
                        ),
                      ),
                      
                      // Migration journey step with animations
                      AnimatedBuilder(
                        animation: _contentAnimationController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _contentAnimationController,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.05, 0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: _contentAnimationController,
                                curve: Curves.easeOutCubic,
                              )),
                              child: child,
                            ),
                          );
                        },
                        child: MigrationJourneyStepWidget(
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
                      
                      // Profession step with animations
                      AnimatedBuilder(
                        animation: _contentAnimationController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _contentAnimationController,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.05, 0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: _contentAnimationController,
                                curve: Curves.easeOutCubic,
                              )),
                              child: child,
                            ),
                          );
                        },
                        child: ProfessionStep(
                          selectedProfession: state.data.profession,
                          onProfessionSelected: (profession) {
                            context.read<OnboardingBloc>().add(
                                  ProfessionUpdated(profession),
                                );
                          },
                        ),
                      ),
                      
                      // Language step with animations
                      AnimatedBuilder(
                        animation: _contentAnimationController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _contentAnimationController,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.05, 0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: _contentAnimationController,
                                curve: Curves.easeOutCubic,
                              )),
                              child: child,
                            ),
                          );
                        },
                        child: LanguageStep(
                          selectedLanguages: state.data.languages,
                          onLanguagesSelected: (languages) {
                            context.read<OnboardingBloc>().add(
                                  LanguagesUpdated(languages),
                                );
                          },
                        ),
                      ),
                      
                      // Interest step with animations
                      AnimatedBuilder(
                        animation: _contentAnimationController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _contentAnimationController,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.05, 0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: _contentAnimationController,
                                curve: Curves.easeOutCubic,
                              )),
                              child: child,
                            ),
                          );
                        },
                        child: InterestStep(
                          selectedInterests: state.data.interests,
                          onInterestsSelected: (interests) {
                            context.read<OnboardingBloc>().add(
                                  InterestsUpdated(interests),
                                );
                          },
                        ),
                      ),
                      
                      // Profile Basic Info step with animations
                      AnimatedBuilder(
                        animation: _contentAnimationController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _contentAnimationController,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.05, 0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: _contentAnimationController,
                                curve: Curves.easeOutCubic,
                              )),
                              child: child,
                            ),
                          );
                        },
                        child: BasicInfoStep(
                          fullName: state.data.fullName ?? '',
                          photoUrl: state.data.profilePhotoUrl ?? '',
                        ),
                      ),
                      
                      // Profile Display Name step with animations
                      AnimatedBuilder(
                        animation: _contentAnimationController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _contentAnimationController,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.05, 0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: _contentAnimationController,
                                curve: Curves.easeOutCubic,
                              )),
                              child: child,
                            ),
                          );
                        },
                        child: DisplayNameStep(
                          displayName: state.data.displayName ?? '',
                        ),
                      ),
                      
                      // Profile Bio step with animations
                      AnimatedBuilder(
                        animation: _contentAnimationController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _contentAnimationController,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.05, 0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: _contentAnimationController,
                                curve: Curves.easeOutCubic,
                              )),
                              child: child,
                            ),
                          );
                        },
                        child: BioStep(
                          bio: state.data.bio ?? '',
                        ),
                      ),
                      
                      // Profile Location step has been removed
                      
                      // Profile Photo step has been integrated into BasicInfoStep
                      
                      // Profile Privacy step has been removed
                      
                      // ImmiGroves step with animations
                      AnimatedBuilder(
                        animation: _contentAnimationController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _contentAnimationController,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.05, 0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: _contentAnimationController,
                                curve: Curves.easeOutCubic,
                              )),
                              child: child,
                            ),
                          );
                        },
                        child: const ImmiGrovesStep(),
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
                          state.currentStep == OnboardingStep.profession ||
                          state.currentStep == OnboardingStep.languages ||
                          state.currentStep == OnboardingStep.interests ||
                          state.currentStep == OnboardingStep.profileBasicInfo ||
                          state.currentStep == OnboardingStep.profileDisplayName ||
                          state.currentStep == OnboardingStep.profileBio ||
                          state.currentStep == OnboardingStep.immiGroves)
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
                      
                      // Next button - only show for steps other than birth country and current status
                      if (state.currentStep != OnboardingStep.birthCountry && 
                          state.currentStep != OnboardingStep.currentStatus)
                        ElevatedButton(
                          onPressed: state.isCurrentStepValid
                              ? () {
                                  // If we're on the display name step, save the data first
                                  if (state.currentStep == OnboardingStep.profileDisplayName) {
                                    // Save the display name data without logging
                                    
                                    // First explicitly save the data
                                    context.read<OnboardingBloc>().add(const OnboardingSaved());
                                    
                                    // Add a small delay to ensure the save completes before moving to next step
                                    Future.delayed(const Duration(milliseconds: 300), () {
                                      if (mounted) {
                                        context.read<OnboardingBloc>().add(const NextStepRequested());
                                      }
                                    });
                                  } else {
                                    context.read<OnboardingBloc>().add(const NextStepRequested());
                                  }
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
                          child: Text(
                            state.currentStep == OnboardingStep.immiGroves ? 'Finish' : 'Next',
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 80), // Empty space when button is hidden
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