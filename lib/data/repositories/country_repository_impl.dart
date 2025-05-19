import 'package:immigru/data/datasources/supabase_data_source.dart';
import 'package:immigru/data/models/country_model.dart';
import 'package:immigru/domain/entities/country.dart';
import 'package:immigru/domain/repositories/country_repository.dart';

/// Implementation of the CountryRepository
class CountryRepositoryImpl implements CountryRepository {
  final SupabaseDataSource _dataSource;

  CountryRepositoryImpl({
    required SupabaseDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<List<Country>> getCountries() async {
    try {
      final countriesData = await _dataSource.getCountries();

      return countriesData.map((data) => CountryModel.fromJson(data)).toList();
    } catch (e) {
      return [];
    }
  }
}
