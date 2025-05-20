import 'package:immigru/features/onboarding/domain/entities/visa.dart';
import 'package:immigru/features/onboarding/domain/repositories/visa_repository.dart';
import 'package:immigru/new_core/network/edge_function_client.dart';
import 'package:immigru/new_core/logging/logger_interface.dart';

/// Model class for Visa entity to handle JSON conversion
class VisaModel extends Visa {
  VisaModel({
    required super.id,
    required super.name,
    super.visaCode,
    super.description,
    required super.countryId,
    super.isCommon = false,
    super.type,
    super.pathwayToPR = false,
    super.allowsWork = false,
  });

  /// Create a VisaModel from JSON data
  factory VisaModel.fromJson(Map<String, dynamic> json) {
    return VisaModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['visaName'] ?? '',
      visaCode: json['visaCode'],
      description: json['description'],
      countryId: json['countryId'] ?? 0,
      isCommon: json['isCommon'] ?? false,
      type: json['type'],
      pathwayToPR: json['pathwayToPR'] ?? false,
      allowsWork: json['allowsWork'] ?? false,
    );
  }

  /// Convert VisaModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'visaCode': visaCode,
      'description': description,
      'countryId': countryId,
      'isCommon': isCommon,
      'type': type,
      'pathwayToPR': pathwayToPR,
      'allowsWork': allowsWork,
    };
  }
}

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
        name: 'Business Visitor',
        countryId: countryId,
        visaCode: 'TOUR',
        type: 'Visitor',
        pathwayToPR: false,
        allowsWork: false,
        description: 'Business visitor visa for short-term business activities',
        isCommon: true,
      ),
      VisaModel(
        id: 1002,
        name: 'Student',
        countryId: countryId,
        visaCode: 'STUD',
        type: 'Education',
        pathwayToPR: false,
        allowsWork: true,
        description: 'Student visa for educational purposes',
        isCommon: true,
      ),
      VisaModel(
        id: 1003,
        name: 'Work',
        countryId: countryId,
        visaCode: 'WORK',
        type: 'Employment',
        pathwayToPR: true,
        allowsWork: true,
        description: 'Work visa for skilled professionals',
        isCommon: true,
      ),
      VisaModel(
        id: 1004,
        name: 'Partner/Family',
        countryId: countryId,
        visaCode: 'FAM',
        type: 'Family',
        pathwayToPR: false,
        allowsWork: false,
        description: 'Family or partner visa for reunification',
        isCommon: true,
      ),
      VisaModel(
        id: 1005,
        name: 'Refugee/Asylum',
        countryId: countryId,
        visaCode: 'REF',
        type: 'Humanitarian',
        pathwayToPR: false,
        allowsWork: false,
        description: 'Refugee or asylum seeker visa',
        isCommon: true,
      ),
      VisaModel(
        id: 1006,
        name: 'Bridging/Provisional',
        countryId: countryId,
        visaCode: 'BRDG',
        type: 'Temporary',
        pathwayToPR: false,
        allowsWork: false,
        description: 'Temporary bridging or provisional visa',
        isCommon: true,
      ),
      VisaModel(
        id: 1007,
        name: 'PR/Citizen',
        countryId: countryId,
        visaCode: 'PR',
        type: 'Permanent',
        pathwayToPR: true,
        allowsWork: true,
        description: 'Permanent residency visa',
        isCommon: true,
      ),
      VisaModel(
        id: 1008,
        name: 'Other/Unsure',
        countryId: countryId,
        visaCode: 'OTHER',
        type: 'Other',
        pathwayToPR: false,
        allowsWork: false,
        description: 'Transit visa for short layovers',
        isCommon: true,
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
            name: visa.name,
            visaCode: visa.visaCode,
            type: visa.type,
            pathwayToPR: visa.pathwayToPR,
            allowsWork: visa.allowsWork,
            description: visa.description,
            isCommon: visa.isCommon,
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
      VisaModel(
        id: 1,
        name: 'Student Visa (Subclass 500)',
        countryId: 13, // Australia
        visaCode: '500',
        type: 'Student',
        pathwayToPR: false,
        allowsWork: true,
        description: 'This visa allows you to stay in Australia to study full-time in a recognized education institution.',
        isCommon: true,
      ),
      VisaModel(
        id: 2,
        name: 'Temporary Skill Shortage Visa (Subclass 482)',
        countryId: 13, // Australia
        visaCode: '482',
        type: 'Work',
        pathwayToPR: true,
        allowsWork: true,
        description: 'This visa lets an employer sponsor a skilled worker to fill a position they cannot find a suitably skilled Australian to fill.',
        isCommon: true,
      ),
      VisaModel(
        id: 3, 
        name: 'Skilled Independent Visa (Subclass 189)', 
        countryId: 13, 
        visaCode: '189', 
        type: 'Skilled Migration', 
        pathwayToPR: true, 
        allowsWork: true, 
        description: 'For invited workers and New Zealand citizens with skills to fill positions needed in Australia.', 
        isCommon: true,
      ),
      VisaModel(
        id: 10,
        name: 'Visitor Visa',
        countryId: 13, // Australia
        visaCode: '600',
        type: 'Tourist',
        pathwayToPR: false,
        allowsWork: false,
        description: 'For tourism or visiting family and friends.',
        isCommon: true,
      ),
      VisaModel(
        id: 11,
        name: 'Working Holiday Visa',
        countryId: 13, // Australia
        visaCode: '417',
        type: 'Work and Holiday',
        pathwayToPR: false,
        allowsWork: true,
        description: 'For young adults who want to work and travel in Australia for up to a year.',
        isCommon: true,
      ),
      VisaModel(
        id: 12,
        name: 'Permanent Resident/Citizen',
        countryId: 13, // Australia
        visaCode: 'PR',
        type: 'Permanent',
        pathwayToPR: true,
        allowsWork: true,
        description: 'Permanent residency or citizenship status.',
        isCommon: true,
      ),
      
      // USA
      VisaModel(
        id: 20,
        name: 'H-1B Specialty Occupation',
        countryId: 234, // USA
        visaCode: 'H-1B',
        type: 'Work',
        pathwayToPR: true,
        allowsWork: true,
        description: 'For workers in specialty occupations that require theoretical or technical expertise.',
        isCommon: true,
      ),
      VisaModel(
        id: 21,
        name: 'F-1 Student Visa',
        countryId: 234, // USA
        visaCode: 'F-1',
        type: 'Student',
        pathwayToPR: false,
        allowsWork: true,
        description: 'For academic students admitted to a SEVP-certified school.',
        isCommon: true,
      ),
      VisaModel(
        id: 22,
        name: 'B-2 Tourist Visa',
        countryId: 234, // USA
        visaCode: 'B-2',
        type: 'Tourist',
        pathwayToPR: false,
        allowsWork: false,
        description: 'For tourism, vacation, visiting family, medical treatment.',
        isCommon: true,
      ),
      VisaModel(
        id: 23,
        name: 'Green Card/Citizen',
        countryId: 234, // USA
        visaCode: 'GC',
        type: 'Permanent',
        pathwayToPR: true,
        allowsWork: true,
        description: 'Permanent residency or citizenship status.',
        isCommon: true,
      ),
      
      // UK
      VisaModel(
        id: 30,
        name: 'Skilled Worker Visa',
        countryId: 235, // UK
        visaCode: 'SW',
        type: 'Work',
        pathwayToPR: true,
        allowsWork: true,
        description: 'This visa has replaced the Tier 2 (General) work visa. You can apply for a Skilled Worker visa if you have been offered a skilled job in the UK.',
        isCommon: true,
      ),
      VisaModel(
        id: 31,
        name: 'Student Visa',
        countryId: 235, // UK
        visaCode: 'ST',
        type: 'Student',
        pathwayToPR: false,
        allowsWork: true,
        description: 'This visa has replaced the Tier 4 (General) student visa. You can apply for a Student visa to study in the UK if you are 16 or over.',
        isCommon: true,
      ),
      VisaModel(
        id: 32,
        name: 'Global Talent Visa',
        countryId: 235, // UK
        visaCode: 'GT',
        type: 'Work',
        pathwayToPR: true,
        allowsWork: true,
        description: 'This visa has replaced the Tier 1 (Exceptional Talent) visa. It is for people who can show they have exceptional talent or exceptional promise in academia or research, arts and culture, or digital technology.',
        isCommon: true,
      ),
      
      // Generic visas for any country
      VisaModel(
        id: 40,
        name: 'Tourist/Visitor Visa',
        countryId: 0, // Generic
        visaCode: 'VISITOR',
        type: 'Visitor',
        pathwayToPR: false,
        allowsWork: false,
        description: 'Short-term visa for tourism or visiting family/friends.',
        isCommon: true,
      ),
      VisaModel(
        id: 41,
        name: 'Work Visa',
        countryId: 0, // Generic
        visaCode: 'WORK',
        type: 'Work',
        pathwayToPR: false,
        allowsWork: true,
        description: 'General work visa for employment purposes.',
        isCommon: true,
      ),
      VisaModel(
        id: 42,
        name: 'Student Visa',
        countryId: 0, // Generic
        visaCode: 'STUDENT',
        type: 'Student',
        pathwayToPR: false,
        allowsWork: true,
        description: 'For studying at educational institutions.',
        isCommon: true,
      ),
      VisaModel(
        id: 33,
        name: 'Permanent Resident/Citizen',
        countryId: 0, // Generic
        visaCode: 'PR',
        type: 'Permanent',
        pathwayToPR: true,
        allowsWork: true,
        description: 'Permanent residency or citizenship status.',
        isCommon: true,
      ),
    ];
  }
}
