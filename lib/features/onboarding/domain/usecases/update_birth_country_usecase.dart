import 'package:immigru/new_core/country/domain/entities/country.dart';
import 'package:immigru/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Use case for updating the birth country during onboarding
class UpdateBirthCountryUseCase {
  final OnboardingFeatureRepository _repository;

  UpdateBirthCountryUseCase(this._repository);

  /// Execute the use case to update the birth country
  /// 
  /// [country] The selected country
  Future<void> call(Country country) async {
    await _repository.saveStepData('birthCountry', {
      'countryId': country.isoCode,
      'countryName': country.name,
    });
  }
}
