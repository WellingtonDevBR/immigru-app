import 'package:immigru/core/logging/logger_interface.dart';
import '../../domain/entities/immi_grove.dart';
import '../../domain/repositories/immi_grove_repository.dart';
import '../datasources/immi_grove_data_source.dart';

/// Implementation of the ImmiGroveRepository
class ImmiGroveRepositoryImpl implements ImmiGroveRepository {
  final ImmiGroveDataSource _dataSource;
  final LoggerInterface _logger;

  /// Creates a new ImmiGroveRepositoryImpl
  ImmiGroveRepositoryImpl({
    required ImmiGroveDataSource dataSource,
    required LoggerInterface logger,
  })  : _dataSource = dataSource,
        _logger = logger;

  @override
  Future<List<ImmiGrove>> getRecommendedImmiGroves({int limit = 6}) async {
    try {
      return await _dataSource.getRecommendedImmiGroves(limit: limit);
    } catch (e) {
      _logger.e('Error in getRecommendedImmiGroves: $e');
      rethrow;
    }
  }

  @override
  Future<void> joinImmiGrove(String immiGroveId) async {
    try {
      await _dataSource.joinImmiGrove(immiGroveId);
    } catch (e) {
      _logger.e('Error in joinImmiGrove: $e');
      rethrow;
    }
  }

  @override
  Future<void> leaveImmiGrove(String immiGroveId) async {
    try {
      await _dataSource.leaveImmiGrove(immiGroveId);
    } catch (e) {
      _logger.e('Error in leaveImmiGrove: $e');
      rethrow;
    }
  }

  @override
  Future<List<ImmiGrove>> getJoinedImmiGroves() async {
    try {
      return await _dataSource.getJoinedImmiGroves();
    } catch (e) {
      _logger.e('Error in getJoinedImmiGroves: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveSelectedImmiGroves(List<String> immiGroveIds) async {
    try {
      await _dataSource.saveSelectedImmiGroves(immiGroveIds);
    } catch (e) {
      _logger.e('Error in saveSelectedImmiGroves: $e');
      rethrow;
    }
  }
}
