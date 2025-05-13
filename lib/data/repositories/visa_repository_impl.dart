import 'package:immigru/core/services/supabase_service.dart';
import 'package:immigru/data/models/visa_model.dart';
import 'package:immigru/domain/entities/visa.dart';
import 'package:immigru/domain/repositories/visa_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementation of the VisaRepository interface
class VisaRepositoryImpl implements VisaRepository {
  final SupabaseService _supabaseService;

  VisaRepositoryImpl(this._supabaseService);

  @override
  Future<List<Visa>> getVisas() async {
    try {
      final response = await _supabaseService.client
          .functions
          .invoke('get-visas', method: HttpMethod.get);

      if (response.status != 200) {
        throw Exception('Failed to load visas');
      }

      final List<dynamic> visasJson = response.data;
      return visasJson.map((json) => VisaModel.fromJson(json)).toList();
    } catch (e) {
      // Return some default visas for now
      return _getDefaultVisas();
    }
  }

  @override
  Future<List<Visa>> getVisasForCountry(int countryId) async {
    try {
      // Use the correct GET endpoint structure with query parameters
      final response = await _supabaseService.client
          .functions
          .invoke(
            'get-countries-with-visas?countryId=$countryId',
            method: HttpMethod.get,
          );

      if (response.status != 200) {
        throw Exception('Failed to load visas: ${response.status}');
      }

      // Handle the response format with data and error fields
      final responseData = response.data as Map<String, dynamic>;
      
      // Check if there's an error
      if (responseData['error'] != null && responseData['error'] != 'null') {
        throw Exception(responseData['error']);
      }
      
      // Get the data array
      final List<dynamic> visasJson = responseData['data'] ?? [];
      
      // If no visas found, return default visas
      if (visasJson.isEmpty) {
        return _getDefaultVisas().where((visa) => visa.countryId == countryId).toList();
      }
      
      // Convert JSON to Visa models
      return visasJson.map((json) => VisaModel.fromJson(json)).toList();
    } catch (e) {
      // Log the error
      print('Error fetching visas for country $countryId: $e');
      // Filter default visas by country
      return _getDefaultVisas().where((visa) => visa.countryId == countryId).toList();
    }
  }

  @override
  Future<Visa?> getVisaById(int visaId) async {
    try {
      final response = await _supabaseService.client
          .functions
          .invoke('get-visa-by-id', 
          body: {'visaId': visaId});

      if (response.status != 200) {
        throw Exception('Failed to load visa');
      }
      
      // Handle the response format with data and error fields
      final responseData = response.data as Map<String, dynamic>;
      
      // Check if there's an error
      if (responseData['error'] != null && responseData['error'] != 'null') {
        throw Exception(responseData['error']);
      }
      
      // Get the data
      final visaJson = responseData['data'];
      
      if (visaJson == null || (visaJson is List && visaJson.isEmpty)) {
        return null;
      }

      return VisaModel.fromJson(visaJson is List ? visaJson.first : visaJson);
    } catch (e) {
      // Find in default visas
      try {
        return _getDefaultVisas().firstWhere(
          (visa) => visa.id == visaId,
        );
      } catch (e) {
        return null;
      }
    }
  }

  @override
  List<Visa> getFallbackVisaOptions(int countryId) {
    return [
      Visa(
        id: 1001,
        countryId: countryId,
        visaName: 'Tourist',
        visaCode: 'TOUR',
        type: 'Visitor',
        description: 'Tourist/visitor visa for short-term stays',
      ),
      Visa(
        id: 1002,
        countryId: countryId,
        visaName: 'Student',
        visaCode: 'STUD',
        type: 'Education',
        description: 'Student visa for educational purposes',
      ),
      Visa(
        id: 1003,
        countryId: countryId,
        visaName: 'Work',
        visaCode: 'WORK',
        type: 'Employment',
        description: 'Work visa for employment purposes',
      ),
      Visa(
        id: 1004,
        countryId: countryId,
        visaName: 'Partner/Family',
        visaCode: 'FAM',
        type: 'Family',
        description: 'Family or partner visa for reunification',
      ),
      Visa(
        id: 1005,
        countryId: countryId,
        visaName: 'Refugee/Asylum',
        visaCode: 'REF',
        type: 'Humanitarian',
        description: 'Refugee or asylum seeker visa',
      ),
      Visa(
        id: 1006,
        countryId: countryId,
        visaName: 'Bridging/Provisional',
        visaCode: 'BRDG',
        type: 'Temporary',
        description: 'Temporary bridging or provisional visa',
      ),
      Visa(
        id: 1007,
        countryId: countryId,
        visaName: 'PR/Citizen',
        visaCode: 'PR',
        type: 'Permanent',
        description: 'Permanent residency or citizenship',
      ),
      Visa(
        id: 1008,
        countryId: countryId,
        visaName: 'Other/Unsure',
        visaCode: 'OTHER',
        type: 'Other',
        description: 'Other visa type or unsure',
      ),
    ];
  }

  // Provide some default visa types for testing and fallback
  List<Visa> _getDefaultVisas() {
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
      const VisaModel(
        id: 4,
        countryId: 234, // USA
        visaName: 'H-1B Specialty Occupation',
        visaCode: 'H-1B',
        type: 'Work',
        pathwayToPR: true,
        allowsWork: true,
        description: 'For workers in specialty occupations that require theoretical or technical expertise.',
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
      // UK
      const VisaModel(
        id: 4,
        countryId: 234, // UK
        visaName: 'Skilled Worker Visa',
        visaCode: 'SW',
        type: 'Work',
        pathwayToPR: true,
        allowsWork: true,
        description: 'This visa has replaced the Tier 2 (General) work visa. You can apply for a Skilled Worker visa if you have been offered a skilled job in the UK.',
        isPublic: true,
      ),
      const VisaModel(
        id: 5,
        countryId: 234, // UK
        visaName: 'Student Visa',
        visaCode: 'ST',
        type: 'Student',
        pathwayToPR: false,
        allowsWork: true,
        description: 'This visa has replaced the Tier 4 (General) student visa. You can apply for a Student visa to study in the UK if you are 16 or over.',
        isPublic: true,
      ),
      const VisaModel(
        id: 6,
        countryId: 234, // UK
        visaName: 'Global Talent Visa',
        visaCode: 'GT',
        type: 'Work',
        pathwayToPR: true,
        allowsWork: true,
        description: 'This visa has replaced the Tier 1 (Exceptional Talent) visa. It is for people who can show they have exceptional talent or exceptional promise in academia or research, arts and culture, or digital technology.',
        isPublic: true,
      ),
    ];
  }
}
