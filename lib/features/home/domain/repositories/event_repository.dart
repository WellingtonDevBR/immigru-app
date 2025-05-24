import 'package:dartz/dartz.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/home/domain/entities/event.dart';

/// Repository interface for event-related operations
abstract class EventRepository {
  /// Get upcoming events
  ///
  /// [upcoming] - Whether to only include upcoming events
  /// [limit] - Maximum number of events to return
  /// [offset] - Pagination offset
  Future<Either<Failure, List<Event>>> getEvents({
    bool upcoming = true,
    int limit = 10,
    int offset = 0,
  });

  /// Register for an event
  ///
  /// [eventId] - ID of the event to register for
  /// [userId] - ID of the user registering
  Future<Either<Failure, bool>> registerForEvent({
    required String eventId,
    required String userId,
  });
}
