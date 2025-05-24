import 'package:dartz/dartz.dart';
import 'package:immigru/core/error/exceptions.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/core/error/failures.dart';
import 'package:immigru/features/home/data/datasources/event_data_source_impl.dart' show EventDataSource;
import 'package:immigru/features/home/domain/entities/event.dart';
import 'package:immigru/features/home/domain/repositories/event_repository.dart';

/// Implementation of the EventRepository interface
class EventRepositoryImpl implements EventRepository {
  final EventDataSource _eventDataSource;
  final UnifiedLogger _logger;

  /// Create a new EventRepositoryImpl
  EventRepositoryImpl({
    required EventDataSource eventDataSource,
    required UnifiedLogger logger,
  })  : _eventDataSource = eventDataSource,
        _logger = logger;

  @override
  Future<Either<Failure, List<Event>>> getEvents({
    bool upcoming = true,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final events = await _eventDataSource.getEvents(
        upcoming: upcoming,
        limit: limit,
        offset: offset,
      );
      return Right(events);
    } on ServerException catch (e) {
      _logger.e('Failed to get events: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      _logger.e('Unexpected error getting events: $e');
      return Left(ServerFailure(message: 'Failed to get events: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> registerForEvent({
    required String eventId,
    required String userId,
  }) async {
    try {
      final result = await _eventDataSource.registerForEvent(
        eventId: eventId,
        userId: userId,
      );
      return Right(result);
    } on ServerException catch (e) {
      _logger.e('Failed to register for event: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      _logger.e('Unexpected error registering for event: $e');
      return Left(ServerFailure(message: 'Failed to register for event: $e'));
    }
  }
}
