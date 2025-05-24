import 'package:dartz/dartz.dart';
import 'package:immigru/core/error/exceptions.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/core/error/failures.dart';
import 'package:immigru/features/home/data/datasources/immi_grove_data_source_impl.dart'
    show ImmiGroveDataSource;
import 'package:immigru/features/home/domain/entities/immi_grove.dart';
import 'package:immigru/features/home/domain/repositories/immi_grove_repository.dart';

/// Implementation of the ImmiGroveRepository interface
class ImmiGroveRepositoryImpl implements ImmiGroveRepository {
  final ImmiGroveDataSource _immiGroveDataSource;
  final UnifiedLogger _logger;

  /// Create a new ImmiGroveRepositoryImpl
  ImmiGroveRepositoryImpl({
    required ImmiGroveDataSource immiGroveDataSource,
    required UnifiedLogger logger,
  })  : _immiGroveDataSource = immiGroveDataSource,
        _logger = logger;

  @override
  Future<Either<Failure, List<ImmiGrove>>> getImmiGroves({
    String? query,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final immiGroves = await _immiGroveDataSource.getImmiGroves(
        query: query,
        limit: limit,
        offset: offset,
      );
      return Right(immiGroves);
    } on ServerException catch (e) {
      _logger.e('Failed to get ImmiGroves: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      _logger.e('Unexpected error getting ImmiGroves: $e');
      return Left(ServerFailure(message: 'Failed to get ImmiGroves: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ImmiGrove>>> getRecommendedImmiGroves({
    int limit = 5,
  }) async {
    try {
      final immiGroves = await _immiGroveDataSource.getRecommendedImmiGroves(
        limit: limit,
      );
      return Right(immiGroves);
    } on ServerException catch (e) {
      _logger.e('Failed to get recommended ImmiGroves: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      _logger.e('Unexpected error getting recommended ImmiGroves: $e');
      return Left(
          ServerFailure(message: 'Failed to get recommended ImmiGroves: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> joinImmiGrove({
    required String immiGroveId,
    required String userId,
    required bool join,
  }) async {
    try {
      final result = await _immiGroveDataSource.joinImmiGrove(
        immiGroveId: immiGroveId,
        userId: userId,
        join: join,
      );
      return Right(result);
    } on ServerException catch (e) {
      _logger.e('Failed to join/leave ImmiGrove: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      _logger.e('Unexpected error joining/leaving ImmiGrove: $e');
      return Left(ServerFailure(message: 'Failed to join/leave ImmiGrove: $e'));
    }
  }
}
