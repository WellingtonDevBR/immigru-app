import 'package:immigru/features/onboarding/domain/entities/onboarding_data.dart';

/// Repository interface for onboarding data in the new feature-first architecture
abstract class OnboardingFeatureRepository {
  /// Save data for a specific onboarding step
  Future<void> saveStepData(String step, Map<String, dynamic> data);
  
  /// Get all onboarding data
  Future<OnboardingData?> getOnboardingData();
  
  /// Check if onboarding is complete
  Future<bool> isOnboardingComplete();
  
  /// Mark onboarding as complete
  Future<void> completeOnboarding();
}
