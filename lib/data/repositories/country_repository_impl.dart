import 'package:immigru/data/datasources/supabase_data_source.dart';
import 'package:immigru/data/models/country_model.dart';
import 'package:immigru/domain/entities/country.dart';
import 'package:immigru/domain/repositories/country_repository.dart';
import 'package:immigru/core/services/logger_service.dart';

/// Implementation of the CountryRepository
class CountryRepositoryImpl implements CountryRepository {
  final SupabaseDataSource _dataSource;
  final LoggerService _logger;

  CountryRepositoryImpl({
    required SupabaseDataSource dataSource,
    required LoggerService logger,
  })  : _dataSource = dataSource,
        _logger = logger;

  @override
  Future<List<Country>> getCountries() async {
    try {
      _logger.debug('CountryRepository', 'Fetching countries from Supabase');
      final countriesData = await _dataSource.getCountries();
      
      _logger.debug('CountryRepository', 'Received ${countriesData.length} countries');
      
      return countriesData.map((data) => CountryModel.fromJson(data)).toList();
    } catch (e) {
      _logger.error('CountryRepository', 'Error fetching countries: $e');
      return [];
    }
  }
}
