import 'package:immigru/core/services/logger_service.dart';
import 'package:immigru/data/datasources/remote/immi_grove_edge_function_data_source.dart';
import 'package:immigru/data/models/immi_grove_model.dart';
import 'package:immigru/domain/entities/immi_grove.dart';
import 'package:immigru/domain/repositories/immi_grove_repository.dart';

/// Implementation of the ImmiGroveRepository
class ImmiGroveRepositoryImpl implements ImmiGroveRepository {
  final ImmiGroveEdgeFunctionDataSource _edgeFunctionDataSource;
  final LoggerService _logger;

  ImmiGroveRepositoryImpl({
    required ImmiGroveEdgeFunctionDataSource edgeFunctionDataSource,
    required LoggerService logger,
  })  : _edgeFunctionDataSource = edgeFunctionDataSource,
        _logger = logger;

  @override
  Future<List<ImmiGrove>> getRecommendedImmiGroves({int limit = 6}) async {
    try {
      final response = await _edgeFunctionDataSource.getRecommendedImmiGroves(limit: limit);
      
      if (response['data'] == null) {
        return [];
      }
      
      final List<dynamic> immigrovesData = response['data'] as List<dynamic>;
      
      return immigrovesData.map((immigroveJson) {
        return ImmiGroveModel.fromJson(immigroveJson as Map<String, dynamic>);
      }).toList();
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  @override
  Future<void> joinImmiGrove(String immiGroveId) async {
    try {
      await _edgeFunctionDataSource.joinImmiGrove(immiGroveId);
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  @override
  Future<void> leaveImmiGrove(String immiGroveId) async {
    try {
      await _edgeFunctionDataSource.leaveImmiGrove(immiGroveId);
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  @override
  Future<List<ImmiGrove>> getJoinedImmiGroves() async {
    try {
      final List<Map<String, dynamic>> response = await _edgeFunctionDataSource.getJoinedImmiGroves();
      
      return response.map((immigroveJson) {
        // Convert the keys to match our model's expected format
        final formattedJson = {
          'Id': immigroveJson['Id'] ?? immigroveJson['ImmiGroveId'],
          'Name': immigroveJson['Name'],
          'Slug': immigroveJson['Slug'] ?? '',
          'Description': immigroveJson['Description'],
          'Type': immigroveJson['Type'],
          'CountryId': immigroveJson['CountryId'],
          'VisaId': immigroveJson['VisaId'],
          'LanguageId': immigroveJson['LanguageId'],
          'IsPublic': immigroveJson['ImmiGroveIsPublic'] ?? true,
          'CreatedBy': immigroveJson['CreatedBy'] ?? '',
          'CoverImageUrl': immigroveJson['CoverImageUrl'],
          'CreatedAt': immigroveJson['CreatedAt'] ?? DateTime.now().toIso8601String(),
          'UpdatedAt': immigroveJson['UpdatedAt'] ?? DateTime.now().toIso8601String(),
          'MemberCount': immigroveJson['MemberCount'],
        };
        
        return ImmiGroveModel.fromJson(formattedJson);
      }).toList();
    } catch (e, stackTrace) {
      rethrow;
    }
  }
}
