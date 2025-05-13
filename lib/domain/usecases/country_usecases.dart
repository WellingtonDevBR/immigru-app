import 'package:immigru/domain/entities/country.dart';
import 'package:immigru/domain/repositories/country_repository.dart';

/// Use case for getting all countries
class GetCountriesUseCase {
  final CountryRepository _repository;

  GetCountriesUseCase(this._repository);

  /// Execute the use case to get all countries
  Future<List<Country>> call() async {
    return await _repository.getCountries();
  }
}
