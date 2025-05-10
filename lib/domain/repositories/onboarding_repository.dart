import 'package:immigru/domain/entities/onboarding_data.dart';

/// Repository interface for onboarding data operations
abstract class OnboardingRepository {
  /// Save onboarding data for the current user
  Future<void> saveOnboardingData(OnboardingData data);
  
  /// Get onboarding data for the current user
  Future<OnboardingData> getOnboardingData();
  
  /// Check if the user has completed onboarding
  Future<bool> hasCompletedOnboarding();
  
  /// Mark onboarding as completed for the current user
  Future<void> completeOnboarding();
}
