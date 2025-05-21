import 'package:immigru/core/country/domain/entities/country.dart';
import 'package:immigru/core/country/domain/repositories/country_repository.dart';
import 'package:immigru/core/network/edge_function_client.dart';
import 'package:immigru/core/logging/logger_interface.dart';

/// Implementation of the CountryFeatureRepository for the new architecture
class CountryRepositoryImpl implements CountryFeatureRepository {
  final EdgeFunctionClient _edgeFunctionClient;
  final LoggerInterface _logger;
  
  // Cache for countries to prevent excessive API calls
  static List<Country>? _countriesCache;
  // Timestamp when the cache was last updated
  static DateTime? _cacheTimestamp;
  // Cache duration (10 minutes)
  static const Duration _cacheDuration = Duration(minutes: 10);
  // Flag to track if a request is in progress to prevent duplicate calls
  static bool _isRequestInProgress = false;

  CountryRepositoryImpl(this._edgeFunctionClient, this._logger);

  @override
  Future<List<Country>> getCountries() async {
    try {
      // Check if we have a valid cache
      if (_countriesCache != null && _cacheTimestamp != null) {
        final now = DateTime.now();
        final cacheAge = now.difference(_cacheTimestamp!);
        
        // Return cached data if it's still valid and not empty
        if (cacheAge < _cacheDuration && _countriesCache!.isNotEmpty) {
          _logger.i('Using cached countries data (${_countriesCache!.length} countries, cache age: ${cacheAge.inSeconds}s)', 
              tag: 'CountryRepository');
          return _countriesCache!;
        }
      }
      
      // Check if a request is already in progress to prevent duplicate calls
      if (_isRequestInProgress) {
        _logger.i('Countries request already in progress, waiting...', tag: 'CountryRepository');
        // Wait for a short time and check if cache was populated by another request
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (_countriesCache != null && _countriesCache!.isNotEmpty) {
          _logger.i('Cache was populated by another request, using cached data', tag: 'CountryRepository');
          return _countriesCache!;
        }
        
        // If still no cache, use fallback countries
        if (_isRequestInProgress) {
          _logger.w('Request still in progress, using fallback countries', tag: 'CountryRepository');
          return _getFallbackCountries();
        }
      }
      
      // Mark that a request is in progress
      _isRequestInProgress = true;
      
      _logger.i('Fetching countries from get-countries edge function', tag: 'CountryRepository');
      
      // Direct invocation of the edge function without body parameters
      final response = await _edgeFunctionClient.invoke<dynamic>(
        'get-countries',
        body: {}, // No parameters needed
      );

      _logger.i('Received response from get-countries edge function', tag: 'CountryRepository');
      
      // Reset the in-progress flag
      _isRequestInProgress = false;
      
      // Log the raw response for debugging
      _logger.i('Response type: ${response.data.runtimeType}', tag: 'CountryRepository');
      
      // Handle null response
      if (response.data == null) {
        _logger.e('No data returned from get-countries edge function', tag: 'CountryRepository');
        return _getFallbackCountries();
      }
      
      // Handle different response formats
      List<dynamic> countriesData;
      
      if (response.data is List) {
        // Direct list response
        _logger.i('Response is a List', tag: 'CountryRepository');
        countriesData = response.data as List<dynamic>;
      } else if (response.data is Map) {
        // Map response, check for data field
        _logger.i('Response is a Map', tag: 'CountryRepository');
        final mapData = response.data as Map<String, dynamic>;
        
        if (mapData.containsKey('data')) {
          final innerData = mapData['data'];
          if (innerData is List) {
            _logger.i('Found data field with List value', tag: 'CountryRepository');
            countriesData = innerData;
          } else {
            _logger.e('data field is not a List: ${innerData.runtimeType}', tag: 'CountryRepository');
            return _getFallbackCountries();
          }
        } else if (mapData.containsKey('countries')) {
          // Some APIs wrap in 'countries' field
          final innerData = mapData['countries'];
          if (innerData is List) {
            _logger.i('Found countries field with List value', tag: 'CountryRepository');
            countriesData = innerData;
          } else {
            _logger.e('countries field is not a List: ${innerData.runtimeType}', tag: 'CountryRepository');
            return _getFallbackCountries();
          }
        } else {
          // Try to use the map itself as a single country
          _logger.w('No data or countries field found, checking if map is a single country', tag: 'CountryRepository');
          if (mapData.containsKey('Id') || mapData.containsKey('id') || 
              mapData.containsKey('IsoCode') || mapData.containsKey('isoCode')) {
            _logger.i('Map appears to be a single country', tag: 'CountryRepository');
            countriesData = [mapData];
          } else {
            _logger.e('Map does not contain expected country fields', tag: 'CountryRepository');
            return _getFallbackCountries();
          }
        }
      } else {
        _logger.e('Unexpected response type: ${response.data.runtimeType}', tag: 'CountryRepository');
        return _getFallbackCountries();
      }
      
      // Convert the data to Country objects
      final countries = countriesData.map((countryData) {
        if (countryData is! Map<String, dynamic>) {
          _logger.w('Invalid country data format', tag: 'CountryRepository');
          return null;
        }
        
        // Helper function to get value with case-insensitive field names
        T? getValue<T>(String fieldName) {
          // Try uppercase first (API standard)
          if (countryData[fieldName] != null) {
            return countryData[fieldName] as T?;
          }
          // Try uppercase first letter (Pascal case)
          final pascalCase = fieldName[0].toUpperCase() + fieldName.substring(1);
          if (countryData[pascalCase] != null) {
            return countryData[pascalCase] as T?;
          }
          // Try all uppercase
          final upperCase = fieldName.toUpperCase();
          if (countryData[upperCase] != null) {
            return countryData[upperCase] as T?;
          }
          // Try all lowercase
          final lowerCase = fieldName.toLowerCase();
          if (countryData[lowerCase] != null) {
            return countryData[lowerCase] as T?;
          }
          return null;
        }
        
        // Try to parse dates if available
        DateTime? updatedAt;
        DateTime? createdAt;
        
        try {
          final updatedAtStr = getValue<String>('updatedAt') ?? getValue<String>('UpdatedAt');
          if (updatedAtStr != null) {
            updatedAt = DateTime.parse(updatedAtStr);
          }
        } catch (e) {
          _logger.w('Failed to parse UpdatedAt date', tag: 'CountryRepository');
        }
        
        try {
          final createdAtStr = getValue<String>('createdAt') ?? getValue<String>('CreatedAt');
          if (createdAtStr != null) {
            createdAt = DateTime.parse(createdAtStr);
          }
        } catch (e) {
          _logger.w('Failed to parse CreatedAt date', tag: 'CountryRepository');
        }
        
        // Get country ID, handling different formats
        int id = 0;
        try {
          id = getValue<int>('id') ?? getValue<int>('Id') ?? 0;
        } catch (e) {
          // Handle case where ID might be a string
          final idStr = getValue<String>('id') ?? getValue<String>('Id');
          if (idStr != null) {
            id = int.tryParse(idStr) ?? 0;
          }
        }
        
        // Get isActive, handling different formats
        bool isActive = true;
        try {
          isActive = getValue<bool>('isActive') ?? getValue<bool>('IsActive') ?? true;
        } catch (e) {
          // Handle case where isActive might be a string
          final activeStr = getValue<String>('isActive') ?? getValue<String>('IsActive');
          if (activeStr != null) {
            isActive = activeStr.toLowerCase() == 'true';
          }
        }
        
        return Country(
          id: id,
          isoCode: getValue<String>('isoCode') ?? getValue<String>('IsoCode') ?? '',
          name: getValue<String>('name') ?? getValue<String>('Name') ?? '',
          officialName: getValue<String>('officialName') ?? getValue<String>('OfficialName') ?? '',
          continent: getValue<String>('continent') ?? getValue<String>('Continent') ?? '',
          region: getValue<String>('region') ?? getValue<String>('Region') ?? '',
          subRegion: getValue<String>('subRegion') ?? getValue<String>('SubRegion') ?? '',
          nationality: getValue<String>('nationality') ?? getValue<String>('Nationality') ?? '',
          phoneCode: getValue<String>('phoneCode') ?? getValue<String>('PhoneCode') ?? '',
          currency: getValue<String>('currency') ?? getValue<String>('Currency') ?? '',
          currencySymbol: getValue<String>('currencySymbol') ?? getValue<String>('CurrencySymbol') ?? '',
          timezones: getValue<String>('timezones') ?? getValue<String>('Timezones') ?? '',
          flagUrl: getValue<String>('flagUrl') ?? getValue<String>('FlagUrl') ?? '',
          isActive: isActive,
          updatedAt: updatedAt,
          createdAt: createdAt,
        );
      }).whereType<Country>().toList();
      
      // Store the countries in the cache
      _countriesCache = countries;
      _cacheTimestamp = DateTime.now();
      
      _logger.i('Fetched ${countries.length} countries and updated cache', tag: 'CountryRepository');
      return countries;
    } catch (e, stackTrace) {
      // Reset the in-progress flag when an error occurs
      _isRequestInProgress = false;
      
      _logger.e(
        'Error fetching countries',
        tag: 'CountryRepository',
        error: e,
        stackTrace: stackTrace,
      );
      
      // If we have a valid cache, use it even if it's expired rather than fallback data
      if (_countriesCache != null && _countriesCache!.isNotEmpty) {
        _logger.i('Using expired cache after error (${_countriesCache!.length} countries)', 
            tag: 'CountryRepository');
        return _countriesCache!;
      }
      
      // Provide fallback countries in case of error
      return _getFallbackCountries();
    }
  }
  
  /// Provides a fallback list of countries in case the API call fails
  List<Country> _getFallbackCountries() {
    return [
      Country(
        id: 1,
        isoCode: 'US',
        name: 'United States',
        officialName: 'United States of America',
        continent: 'North America',
        region: 'Northern America',
        subRegion: 'Northern America',
        nationality: 'American',
        phoneCode: '+1',
        currency: 'USD',
        currencySymbol: '\$',
        timezones: 'UTC-12:00 to UTC+12:00',
        flagUrl: 'https://flagcdn.com/w320/us.png',
        isActive: true,
      ),
      Country(
        id: 3,
        isoCode: 'BR',
        name: 'Brazil',
        officialName: 'Federative Republic of Brazil',
        continent: 'South America',
        region: 'Latin America',
        subRegion: 'South America',
        nationality: 'Brazilian',
        phoneCode: '+55',
        currency: 'BRL',
        currencySymbol: 'R\$',
        timezones: 'UTC-05:00 to UTC-02:00',
        flagUrl: 'https://flagcdn.com/w320/br.png',
        isActive: true,
      ),
      Country(
        id: 2,
        isoCode: 'CA',
        name: 'Canada',
        officialName: 'Canada',
        continent: 'North America',
        region: 'Northern America',
        subRegion: 'Northern America',
        nationality: 'Canadian',
        phoneCode: '+1',
        currency: 'CAD',
        currencySymbol: '\$',
        timezones: 'UTC-08:00 to UTC-04:00',
        flagUrl: 'https://flagcdn.com/w320/ca.png',
        isActive: true,
      ),
    ];
  }
}
