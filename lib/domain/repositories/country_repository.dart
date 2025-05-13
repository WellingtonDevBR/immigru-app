import 'package:immigru/domain/entities/country.dart';

/// Repository interface for country-related operations
abstract class CountryRepository {
  /// Get a list of all countries
  Future<List<Country>> getCountries();
}
