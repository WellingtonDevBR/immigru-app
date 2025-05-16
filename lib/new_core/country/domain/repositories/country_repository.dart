import 'package:immigru/new_core/country/domain/entities/country.dart';

/// Repository interface for country-related operations in the new architecture
abstract class CountryFeatureRepository {
  /// Get a list of all countries
  Future<List<Country>> getCountries();
}
