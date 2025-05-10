import 'package:immigru/domain/entities/onboarding_data.dart';
import 'package:immigru/domain/repositories/onboarding_repository.dart';

/// Use case for saving onboarding data
class SaveOnboardingDataUseCase {
  final OnboardingRepository repository;

  SaveOnboardingDataUseCase(this.repository);

  Future<void> call(OnboardingData data) async {
    return await repository.saveOnboardingData(data);
  }
}

/// Use case for retrieving onboarding data
class GetOnboardingDataUseCase {
  final OnboardingRepository repository;

  GetOnboardingDataUseCase(this.repository);

  Future<OnboardingData> call() async {
    return await repository.getOnboardingData();
  }
}

/// Use case for checking if onboarding is completed
class CheckOnboardingStatusUseCase {
  final OnboardingRepository repository;

  CheckOnboardingStatusUseCase(this.repository);

  Future<bool> call() async {
    return await repository.hasCompletedOnboarding();
  }
}

/// Use case for completing onboarding
class CompleteOnboardingUseCase {
  final OnboardingRepository repository;

  CompleteOnboardingUseCase(this.repository);

  Future<void> call() async {
    return await repository.completeOnboarding();
  }
}
