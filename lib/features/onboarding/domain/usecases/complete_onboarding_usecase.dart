import 'package:immigru/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Use case for marking onboarding as completed
class CompleteOnboardingUseCase {
  final OnboardingRepository _repository;

  CompleteOnboardingUseCase(this._repository);

  /// Execute the use case to mark onboarding as completed
  Future<void> call() async {
    return await _repository.completeOnboarding();
  }
}
