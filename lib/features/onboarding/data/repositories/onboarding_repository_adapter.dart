import 'package:immigru/features/onboarding/domain/entities/onboarding_data.dart';
import 'package:immigru/features/onboarding/domain/repositories/onboarding_feature_repository.dart';
import 'package:immigru/core/logging/logger_interface.dart';

/// Adapter class to connect the old repository implementation with the new feature-first architecture
class OnboardingRepositoryAdapter implements OnboardingFeatureRepository {
  final OnboardingFeatureRepository _oldRepository;
  final LoggerInterface _logger;

  OnboardingRepositoryAdapter(
    this._oldRepository,
    this._logger,
  );

  @override
  Future<void> saveStepData(String step, Map<String, dynamic> data) async {
    try {
      // Since we're now using the same interface, we can just delegate the call
      // to the underlying repository implementation
      await _oldRepository.saveStepData(step, data);
      _logger.i('Successfully saved step data for: $step', tag: 'Onboarding');
    } catch (e, stackTrace) {
      _logger.e('Error saving step data',
          tag: 'Onboarding', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<OnboardingData?> getOnboardingData() async {
    try {
      return await _oldRepository.getOnboardingData();
    } catch (e, stackTrace) {
      _logger.e('Error getting onboarding data',
          tag: 'Onboarding', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<bool> isOnboardingComplete() async {
    try {
      return await _oldRepository.isOnboardingComplete();
    } catch (e, stackTrace) {
      _logger.e('Error checking onboarding completion',
          tag: 'Onboarding', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<void> completeOnboarding() async {
    try {
      await _oldRepository.completeOnboarding();
      _logger.i('Successfully completed onboarding', tag: 'Onboarding');
    } catch (e, stackTrace) {
      _logger.e('Error completing onboarding',
          tag: 'Onboarding', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
