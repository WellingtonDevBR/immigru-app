import 'package:immigru/domain/entities/visa.dart';

/// Repository interface for visa data in the new architecture
abstract class VisaRepository {
  /// Get all visas
  Future<List<Visa>> getVisas();
  
  /// Get visas for a specific country
  Future<List<Visa>> getVisasForCountry(int countryId);
  
  /// Get a specific visa by ID
  Future<Visa?> getVisaById(int visaId);
  
  /// Get generic fallback visa options for a country
  /// Used when no specific visa data is available
  List<Visa> getFallbackVisaOptions(int countryId);
}
