import 'package:dartz/dartz.dart';
import 'package:immigru/features/home/domain/entities/event.dart';
import 'package:immigru/features/home/domain/repositories/event_repository.dart';
import 'package:immigru/core/network/models/failure.dart';

/// Use case for getting events
class GetEventsUseCase {
  final EventRepository repository;

  GetEventsUseCase(this.repository);

  /// Execute the use case
  /// 
  /// [upcoming] - Whether to only include upcoming events
  /// [limit] - Maximum number of events to return
  /// [offset] - Pagination offset
  Future<Either<Failure, List<Event>>> call({
    bool upcoming = true,
    int limit = 10,
    int offset = 0,
  }) {
    return repository.getEvents(
      upcoming: upcoming,
      limit: limit,
      offset: offset,
    );
  }
}
