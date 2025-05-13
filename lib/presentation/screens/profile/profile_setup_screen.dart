import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/core/di/injection_container.dart' as di;
import 'package:immigru/presentation/blocs/profile/profile_bloc.dart';
import 'package:immigru/presentation/blocs/profile/profile_event.dart';
import 'package:immigru/presentation/blocs/profile/profile_state.dart';
import 'package:immigru/presentation/screens/profile/widgets/basic_info_step.dart';
import 'package:immigru/presentation/screens/profile/widgets/bio_step.dart';
import 'package:immigru/presentation/screens/profile/widgets/display_name_step.dart';
import 'package:immigru/presentation/screens/profile/widgets/location_step.dart';
import 'package:immigru/presentation/screens/profile/widgets/photo_step.dart';
import 'package:immigru/presentation/screens/profile/widgets/privacy_step.dart';
import 'package:immigru/presentation/theme/app_colors.dart';
import 'package:immigru/presentation/widgets/loading_indicator.dart';

/// Screen for the profile setup flow
class ProfileSetupScreen extends StatelessWidget {
  /// Route name for navigation
  static const routeName = '/profile-setup';

  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ProfileBloc>()..add(const ProfileLoaded()),
      child: const _ProfileSetupView(),
    );
  }
}

class _ProfileSetupView extends StatelessWidget {
  const _ProfileSetupView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(
              child: LoadingIndicator(),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile Setup'),
            leading: state.currentStep != ProfileSetupStep.basicInfo
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      context
                          .read<ProfileBloc>()
                          .add(const PreviousStepRequested());
                    },
                  )
                : null,
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Progress indicator
                LinearProgressIndicator(
                  value: _calculateProgress(state.currentStep),
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryColor,
                  ),
                ),
                // Current step
                Expanded(
                  child: _buildCurrentStep(context, state),
                ),
                // Bottom navigation
                _buildBottomNavigation(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Calculate progress based on current step
  double _calculateProgress(ProfileSetupStep currentStep) {
    final totalSteps = ProfileSetupStep.values.length - 1; // Exclude 'completed'
    final currentStepIndex = ProfileSetupStep.values.indexOf(currentStep);
    return currentStepIndex / totalSteps;
  }

  /// Build the current step widget
  Widget _buildCurrentStep(BuildContext context, ProfileState state) {
    switch (state.currentStep) {
      case ProfileSetupStep.basicInfo:
        return BasicInfoStep(
          firstName: state.profile.firstName ?? '',
          lastName: state.profile.lastName ?? '',
        );
      case ProfileSetupStep.displayName:
        return DisplayNameStep(
          displayName: state.profile.displayName ?? '',
        );
      case ProfileSetupStep.bio:
        return BioStep(
          bio: state.profile.bio ?? '',
        );
      case ProfileSetupStep.location:
        return LocationStep(
          currentLocation: state.profile.currentLocation ?? '',
          destinationCity: state.profile.destinationCity ?? '',
        );
      case ProfileSetupStep.photo:
        return PhotoStep(
          photoUrl: state.profile.profilePhotoUrl,
          isUploading: state.isPhotoUploading,
        );
      case ProfileSetupStep.privacy:
        return PrivacyStep(
          isPrivate: state.profile.isPrivate,
        );
      case ProfileSetupStep.completed:
        // Navigate to home screen when completed
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed('/home');
        });
        return const Center(
          child: LoadingIndicator(),
        );
    }
  }

  /// Build the bottom navigation buttons
  Widget _buildBottomNavigation(BuildContext context, ProfileState state) {
    // Don't show navigation on completed step
    if (state.currentStep == ProfileSetupStep.completed) {
      return const SizedBox.shrink();
    }

    final isLastStep = state.currentStep == ProfileSetupStep.privacy;
    final isOptionalStep = state.currentStep == ProfileSetupStep.bio ||
        state.currentStep == ProfileSetupStep.photo;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Skip button (only for optional steps)
          if (isOptionalStep)
            TextButton(
              onPressed: () {
                context.read<ProfileBloc>().add(const StepSkipped());
              },
              child: const Text('Skip'),
            )
          else
            const SizedBox.shrink(),
          
          // Next/Finish button
          ElevatedButton(
            onPressed: state.isCurrentStepValid && !state.isSubmitting
                ? () {
                    if (isLastStep) {
                      context.read<ProfileBloc>().add(const ProfileSetupCompleted());
                    } else {
                      context.read<ProfileBloc>().add(const NextStepRequested());
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 12.0,
              ),
            ),
            child: state.isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    isLastStep ? 'Finish' : 'Next',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
