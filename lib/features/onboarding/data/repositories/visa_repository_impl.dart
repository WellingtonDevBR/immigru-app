import 'package:immigru/data/models/visa_model.dart';
import 'package:immigru/domain/entities/visa.dart';
import 'package:immigru/features/onboarding/domain/repositories/visa_repository.dart';
import 'package:immigru/new_core/network/edge_function_client.dart';
import 'package:immigru/new_core/logging/logger_interface.dart';

/// Implementation of the VisaRepository interface for the new architecture
class VisaRepositoryImpl implements VisaRepository {
  final EdgeFunctionClient _edgeFunctionClient;
  final LoggerInterface _logger;

  /// Constructor
  VisaRepositoryImpl(this._edgeFunctionClient, this._logger);

  @override
  Future<List<Visa>> getVisas() async {
    try {
      _logger.i('Fetching all visas', tag: 'VisaRepository');
      
      final response = await _edgeFunctionClient.invoke(
        'get-visas',
        body: {},
      );
      
      if (!response.isSuccess || response.data == null) {
        _logger.e(
          'Failed to load visas: ${response.message}',
          tag: 'VisaRepository',
        );
        return _getDefaultVisas();
      }
      
      final List<dynamic> visasJson = response.data;
      return visasJson.map((json) => VisaModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      _logger.e(
        'Error fetching visas',
        tag: 'VisaRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return _getDefaultVisas();
    }
  }

  @override
  Future<List<Visa>> getVisasForCountry(int countryId) async {
    try {
      _logger.i('Fetching visas for country $countryId', tag: 'VisaRepository');
      
      // The edge function expects countryId as a query parameter, not in the body
      final response = await _edgeFunctionClient.invoke(
        'get-countries-with-visas',
        params: {'countryId': countryId.toString()},
        body: {},
      );
      
      if (!response.isSuccess || response.data == null) {
        _logger.e(
          'Failed to load visas for country $countryId: ${response.message}',
          tag: 'VisaRepository',
        );
        return _getCountrySpecificVisas(countryId);
      }
      
      final responseData = response.data as Map<String, dynamic>;
      
      if (responseData['error'] != null && responseData['error'] != 'null') {
        _logger.e(
          'Error in response: ${responseData['error']}',
          tag: 'VisaRepository',
        );
        return _getCountrySpecificVisas(countryId);
      }
      
      if (responseData['data'] == null) {
        _logger.w(
          'No visa data found for country $countryId',
          tag: 'VisaRepository',
        );
        return _getCountrySpecificVisas(countryId);
      }
      
      final List<dynamic> visasJson = responseData['data'];
      if (visasJson.isEmpty) {
        _logger.w(
          'Empty visa data for country $countryId, using fallback',
          tag: 'VisaRepository',
        );
        return _getCountrySpecificVisas(countryId);
      }
      
      return visasJson.map((json) => VisaModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      _logger.e(
        'Error fetching visas for country $countryId',
        tag: 'VisaRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return _getCountrySpecificVisas(countryId);
    }
  }

  @override
  Future<Visa?> getVisaById(int visaId) async {
    try {
      _logger.i('Fetching visa with ID $visaId', tag: 'VisaRepository');
      
      final visas = await getVisas();
      return visas.firstWhere(
        (visa) => visa.id == visaId,
        orElse: () => throw Exception('Visa not found'),
      );
    } catch (e, stackTrace) {
      _logger.e(
        'Error fetching visa with ID $visaId',
        tag: 'VisaRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  @override
  List<Visa> getFallbackVisaOptions(int countryId) {
    _logger.i('Using fallback visa options for country $countryId', tag: 'VisaRepository');
    
    return [
      VisaModel(
        id: 1001,
        countryId: countryId,
        visaName: 'Tourist',
        visaCode: 'TOUR',
        type: 'Visitor',
        pathwayToPR: false,
        allowsWork: false,
        description: 'Tourist/visitor visa for short-term stays',
        isPublic: true,
      ),
      VisaModel(
        id: 1002,
        countryId: countryId,
        visaName: 'Student',
        visaCode: 'STUD',
        type: 'Education',
        pathwayToPR: false,
        allowsWork: true,
        description: 'Student visa for educational purposes',
        isPublic: true,
      ),
      VisaModel(
        id: 1003,
        countryId: countryId,
        visaName: 'Work',
        visaCode: 'WORK',
        type: 'Employment',
        pathwayToPR: false,
        allowsWork: true,
        description: 'Work visa for employment purposes',
        isPublic: true,
      ),
      VisaModel(
        id: 1004,
        countryId: countryId,
        visaName: 'Partner/Family',
        visaCode: 'FAM',
        type: 'Family',
        pathwayToPR: false,
        allowsWork: false,
        description: 'Family or partner visa for reunification',
        isPublic: true,
      ),
      VisaModel(
        id: 1005,
        countryId: countryId,
        visaName: 'Refugee/Asylum',
        visaCode: 'REF',
        type: 'Humanitarian',
        pathwayToPR: false,
        allowsWork: false,
        description: 'Refugee or asylum seeker visa',
        isPublic: true,
      ),
      VisaModel(
        id: 1006,
        countryId: countryId,
        visaName: 'Bridging/Provisional',
        visaCode: 'BRDG',
        type: 'Temporary',
        pathwayToPR: false,
        allowsWork: false,
        description: 'Temporary bridging or provisional visa',
        isPublic: true,
      ),
      VisaModel(
        id: 1007,
        countryId: countryId,
        visaName: 'PR/Citizen',
        visaCode: 'PR',
        type: 'Permanent',
        pathwayToPR: true,
        allowsWork: true,
        description: 'Permanent residency or citizenship',
        isPublic: true,
      ),
      VisaModel(
        id: 1008,
        countryId: countryId,
        visaName: 'Other/Unsure',
        visaCode: 'OTHER',
        type: 'Other',
        pathwayToPR: false,
        allowsWork: false,
        description: 'Other visa type or unsure',
        isPublic: true,
      ),
    ];
  }
  
  /// Get country-specific visas or fallback to generic options
  List<Visa> _getCountrySpecificVisas(int countryId) {
    _logger.i('Getting country-specific visas for country $countryId', tag: 'VisaRepository');
    
    // First check if we have specific visas for this country
    final countrySpecificVisas = _getDefaultVisas()
        .where((visa) => visa.countryId == countryId)
        .toList();
    
    // If we have specific visas for this country, return them
    if (countrySpecificVisas.isNotEmpty) {
      _logger.i('Found ${countrySpecificVisas.length} specific visas for country $countryId', tag: 'VisaRepository');
      return countrySpecificVisas;
    }
    
    // Otherwise, return generic visas with the country ID updated
    _logger.i('No specific visas found for country $countryId, using generic visas', tag: 'VisaRepository');
    final genericVisas = _getDefaultVisas()
        .where((visa) => visa.countryId == 0) // Generic visas have countryId = 0
        .map((visa) {
          // Create a copy with the requested country ID
          return VisaModel(
            id: visa.id,
            countryId: countryId,
            visaName: visa.visaName,
            visaCode: visa.visaCode,
            type: visa.type,
            pathwayToPR: visa.pathwayToPR,
            allowsWork: visa.allowsWork,
            description: visa.description,
            isPublic: visa.isPublic,
          );
        })
        .toList();
    
    // If we still don't have visas, use the fallback options
    if (genericVisas.isEmpty) {
      _logger.i('No generic visas found, using fallback options', tag: 'VisaRepository');
      return getFallbackVisaOptions(countryId);
    }
    
    return genericVisas;
  }
  
  /// Get default visas for all supported countries
  List<Visa> _getDefaultVisas() {
    _logger.i('Getting default visas', tag: 'VisaRepository');
    
    return [
      // Australia
      const VisaModel(
        id: 1,
        countryId: 13, // Australia
        visaName: 'Student Visa (Subclass 500)',
        visaCode: '500',
        type: 'Student',
        pathwayToPR: false,
        allowsWork: true,
        description: 'This visa allows you to stay in Australia to study full-time in a recognized education institution.',
        isPublic: true,
      ),
      const VisaModel(
        id: 2,
        countryId: 13, // Australia
        visaName: 'Temporary Skill Shortage Visa (Subclass 482)',
        visaCode: '482',
        type: 'Work',
        pathwayToPR: true,
        allowsWork: true,
        description: 'This visa lets an employer sponsor a skilled worker to fill a position they cannot find a suitably skilled Australian to fill.',
        isPublic: true,
      ),
      const VisaModel(
        id: 3, 
        countryId: 13, 
        visaName: 'Skilled Independent Visa (Subclass 189)', 
        visaCode: '189', 
        type: 'Skilled Migration', 
        pathwayToPR: true, 
        allowsWork: true, 
        description: 'For invited workers and New Zealand citizens with skills to fill positions needed in Australia.', 
        isPublic: true,
      ),
      const VisaModel(
        id: 10,
        countryId: 13, // Australia
        visaName: 'Visitor Visa',
        visaCode: '600',
        type: 'Tourist',
        pathwayToPR: false,
        allowsWork: false,
        description: 'For tourism or visiting family and friends.',
        isPublic: true,
      ),
      const VisaModel(
        id: 11,
        countryId: 13, // Australia
        visaName: 'Working Holiday Visa',
        visaCode: '417',
        type: 'Work and Holiday',
        pathwayToPR: false,
        allowsWork: true,
        description: 'For young adults who want to work and travel in Australia for up to a year.',
        isPublic: true,
      ),
      const VisaModel(
        id: 12,
        countryId: 13, // Australia
        visaName: 'Permanent Resident/Citizen',
        visaCode: 'PR',
        type: 'Permanent',
        pathwayToPR: true,
        allowsWork: true,
        description: 'Permanent residency or citizenship status.',
        isPublic: true,
      ),
      
      // USA
      const VisaModel(
        id: 20,
        countryId: 234, // USA
        visaName: 'H-1B Specialty Occupation',
        visaCode: 'H-1B',
        type: 'Work',
        pathwayToPR: true,
        allowsWork: true,
        description: 'For workers in specialty occupations that require theoretical or technical expertise.',
        isPublic: true,
      ),
      const VisaModel(
        id: 21,
        countryId: 234, // USA
        visaName: 'F-1 Student Visa',
        visaCode: 'F-1',
        type: 'Student',
        pathwayToPR: false,
        allowsWork: true,
        description: 'For academic students admitted to a SEVP-certified school.',
        isPublic: true,
      ),
      const VisaModel(
        id: 22,
        countryId: 234, // USA
        visaName: 'B-2 Tourist Visa',
        visaCode: 'B-2',
        type: 'Tourist',
        pathwayToPR: false,
        allowsWork: false,
        description: 'For tourism, vacation, visiting family, medical treatment.',
        isPublic: true,
      ),
      const VisaModel(
        id: 23,
        countryId: 234, // USA
        visaName: 'Green Card/Citizen',
        visaCode: 'GC',
        type: 'Permanent',
        pathwayToPR: true,
        allowsWork: true,
        description: 'Permanent residency or citizenship status.',
        isPublic: true,
      ),
      
      // UK
      const VisaModel(
        id: 30,
        countryId: 235, // UK
        visaName: 'Skilled Worker Visa',
        visaCode: 'SW',
        type: 'Work',
        pathwayToPR: true,
        allowsWork: true,
        description: 'This visa has replaced the Tier 2 (General) work visa. You can apply for a Skilled Worker visa if you have been offered a skilled job in the UK.',
        isPublic: true,
      ),
      const VisaModel(
        id: 31,
        countryId: 235, // UK
        visaName: 'Student Visa',
        visaCode: 'ST',
        type: 'Student',
        pathwayToPR: false,
        allowsWork: true,
        description: 'This visa has replaced the Tier 4 (General) student visa. You can apply for a Student visa to study in the UK if you are 16 or over.',
        isPublic: true,
      ),
      const VisaModel(
        id: 32,
        countryId: 235, // UK
        visaName: 'Global Talent Visa',
        visaCode: 'GT',
        type: 'Work',
        pathwayToPR: true,
        allowsWork: true,
        description: 'This visa has replaced the Tier 1 (Exceptional Talent) visa. It is for people who can show they have exceptional talent or exceptional promise in academia or research, arts and culture, or digital technology.',
        isPublic: true,
      ),
      
      // Generic visas for any country
      const VisaModel(
        id: 100,
        countryId: 0, // Generic
        visaName: 'Tourist/Visitor Visa',
        visaCode: 'VISITOR',
        type: 'Visitor',
        pathwayToPR: false,
        allowsWork: false,
        description: 'Short-term visa for tourism or visiting family/friends.',
        isPublic: true,
      ),
      const VisaModel(
        id: 101,
        countryId: 0, // Generic
        visaName: 'Work Visa',
        visaCode: 'WORK',
        type: 'Work',
        pathwayToPR: false,
        allowsWork: true,
        description: 'General work visa for employment purposes.',
        isPublic: true,
      ),
      const VisaModel(
        id: 102,
        countryId: 0, // Generic
        visaName: 'Student Visa',
        visaCode: 'STUDENT',
        type: 'Student',
        pathwayToPR: false,
        allowsWork: true,
        description: 'For studying at educational institutions.',
        isPublic: true,
      ),
      const VisaModel(
        id: 103,
        countryId: 0, // Generic
        visaName: 'Permanent Resident/Citizen',
        visaCode: 'PR',
        type: 'Permanent',
        pathwayToPR: true,
        allowsWork: true,
        description: 'Permanent residency or citizenship status.',
        isPublic: true,
      ),
    ];
  }
}
