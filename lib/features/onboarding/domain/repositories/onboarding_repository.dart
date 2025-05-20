import 'package:immigru/features/onboarding/domain/entities/onboarding_data.dart';

/// Repository interface for onboarding operations
abstract class OnboardingRepository {
  /// Save onboarding data for a specific step
  Future<void> saveStepData(String step, Map<String, dynamic> data);
  
  /// Get onboarding data
  Future<OnboardingData?> getOnboardingData();
  
  /// Check if onboarding is complete
  Future<bool> isOnboardingComplete();
  
  /// Mark onboarding as complete
  Future<void> completeOnboarding();
}
