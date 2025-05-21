import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/onboarding/presentation/bloc/onboarding/onboarding_bloc.dart';
import 'package:immigru/features/onboarding/presentation/bloc/onboarding/onboarding_event.dart';
import 'package:immigru/core/logging/logger_interface.dart';
import 'package:immigru/core/di/service_locator.dart';

/// Base class for all onboarding steps
///
/// This abstract class provides common functionality for all onboarding steps,
/// including access to the onboarding bloc and logging.
abstract class BaseOnboardingStep extends StatefulWidget {
  const BaseOnboardingStep({super.key});
}

/// Base state class for all onboarding steps
///
/// This abstract class provides common functionality for all onboarding step states,
/// including access to the onboarding bloc and logging.
abstract class BaseOnboardingStepState<T extends BaseOnboardingStep>
    extends State<T> {
  /// Reference to the onboarding bloc
  late OnboardingBloc _onboardingBloc;

  /// Reference to the logger
  late LoggerInterface _logger;

  /// Get the onboarding bloc
  OnboardingBloc get onboardingBloc => _onboardingBloc;

  /// Get the logger
  LoggerInterface get logger => _logger;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safely capture the bloc reference when dependencies change
    _onboardingBloc = BlocProvider.of<OnboardingBloc>(context);
    _logger = ServiceLocator.instance<LoggerInterface>(
        instanceName: 'onboarding_logger');
  }

  /// Helper method to safely add an event to the onboarding bloc
  void addOnboardingEvent(OnboardingEvent event) {
    if (mounted) {
      _onboardingBloc.add(event);
    }
  }

  /// Helper method to move to the next step
  void goToNextStep() {
    addOnboardingEvent(const NextStepRequested());
  }

  /// Helper method to move to the previous step
  void goToPreviousStep() {
    addOnboardingEvent(const PreviousStepRequested());
  }

  /// Helper method to mark the onboarding as completed
  void completeOnboarding() {
    addOnboardingEvent(const OnboardingCompleted());
  }

  /// Helper method to mark the current step as saved
  void saveOnboardingProgress() {
    addOnboardingEvent(const OnboardingSaved());
  }
}
