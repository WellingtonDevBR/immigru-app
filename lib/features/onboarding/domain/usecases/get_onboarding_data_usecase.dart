import 'package:immigru/features/onboarding/domain/entities/onboarding_data.dart';
import 'package:immigru/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Use case for retrieving onboarding data
class GetOnboardingDataUseCase {
  final OnboardingRepository _repository;

  GetOnboardingDataUseCase(this._repository);

  /// Execute the use case to get onboarding data
  Future<OnboardingData?> call() async {
    return await _repository.getOnboardingData();
  }
}
