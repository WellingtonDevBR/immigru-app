import 'package:immigru/domain/entities/onboarding_data.dart';
import 'package:immigru/domain/repositories/onboarding_repository.dart' as old_repo;
import 'package:immigru/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:immigru/shared/interfaces/logger_interface.dart';

/// Adapter class to connect the old OnboardingRepository with the new feature-first architecture
class OnboardingRepositoryAdapter implements OnboardingFeatureRepository {
  final old_repo.OnboardingRepository _oldRepository;
  final LoggerInterface _logger;

  OnboardingRepositoryAdapter(
    this._oldRepository,
    this._logger,
  );

  @override
  Future<void> saveStepData(String step, Map<String, dynamic> data) async {
    try {
      // Convert the step data to the format expected by the old repository
      final baseData = await _oldRepository.getOnboardingData();
      
      // Update the specific step data
      switch (step) {
        case 'birthCountry':
          final updatedData = baseData.copyWith(
            birthCountry: data['countryId'],
          );
          await _oldRepository.saveOnboardingData(updatedData);
          break;
        // Add more cases for other steps as they are implemented
        default:
          _logger.d('Unknown step: $step', tag: 'Onboarding');
      }
    } catch (e, stackTrace) {
      _logger.e('Error saving step data', tag: 'Onboarding', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<OnboardingData?> getOnboardingData() async {
    try {
      return await _oldRepository.getOnboardingData();
    } catch (e, stackTrace) {
      _logger.e('Error getting onboarding data', tag: 'Onboarding', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<bool> isOnboardingComplete() async {
    try {
      // Check if onboarding data exists and is marked as completed
      final data = await _oldRepository.getOnboardingData();
      return data.isCompleted;
    } catch (e, stackTrace) {
      _logger.e('Error checking onboarding status', tag: 'Onboarding', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<void> completeOnboarding() async {
    try {
      // Get current onboarding data
      final baseData = await _oldRepository.getOnboardingData();
      
      // Mark as completed
      final updatedData = baseData.copyWith(isCompleted: true);
      await _oldRepository.saveOnboardingData(updatedData);
    } catch (e, stackTrace) {
      _logger.e('Error completing onboarding', tag: 'Onboarding', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
