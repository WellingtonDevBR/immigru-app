import 'package:immigru/features/onboarding/domain/entities/interest.dart';
import 'package:immigru/features/onboarding/domain/repositories/interest_repository.dart';
import 'package:immigru/new_core/logging/logger_interface.dart';

import '../datasources/interest_data_source.dart';

/// Implementation of InterestRepository
class InterestRepositoryImpl implements InterestRepository {
  final InterestDataSource _dataSource;
  final LoggerInterface _logger;
  
  /// Create a new InterestRepositoryImpl
  InterestRepositoryImpl({
    required InterestDataSource dataSource,
    required LoggerInterface logger,
  }) : _dataSource = dataSource, _logger = logger;
  
  @override
  Future<List<Interest>> getInterests() async {
    try {
      _logger.i('InterestRepositoryImpl: Getting all interests');
      return await _dataSource.getInterests();
    } catch (e) {
      _logger.e('InterestRepositoryImpl: Error getting interests', error: e);
      return [];
    }
  }
  
  @override
  Future<bool> saveUserInterests(List<int> interestIds) async {
    try {
      _logger.i('InterestRepositoryImpl: Saving user interests');
      return await _dataSource.saveUserInterests(interestIds);
    } catch (e) {
      _logger.e('InterestRepositoryImpl: Error saving user interests', error: e);
      return false;
    }
  }
  
  @override
  Future<List<Interest>> getUserInterests() async {
    try {
      _logger.i('InterestRepositoryImpl: Getting user interests');
      return await _dataSource.getUserInterests();
    } catch (e) {
      _logger.e('InterestRepositoryImpl: Error getting user interests', error: e);
      return [];
    }
  }
}
