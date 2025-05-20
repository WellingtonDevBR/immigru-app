import 'package:immigru/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Use case for saving onboarding data for a specific step
class SaveOnboardingDataUseCase {
  final OnboardingRepository _repository;

  SaveOnboardingDataUseCase(this._repository);

  /// Execute the use case to save onboarding data for a specific step
  /// 
  /// [step] The step identifier (e.g., 'birthCountry', 'currentStatus')
  /// [data] The data to save for the step
  Future<void> call(String step, Map<String, dynamic> data) async {
    return await _repository.saveStepData(step, data);
  }
}
