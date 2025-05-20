import 'package:immigru/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Use case for checking if onboarding is completed
class CheckOnboardingStatusUseCase {
  final OnboardingRepository _repository;

  CheckOnboardingStatusUseCase(this._repository);

  /// Execute the use case to check if onboarding is completed
  Future<bool> call() async {
    return await _repository.isOnboardingComplete();
  }
}
