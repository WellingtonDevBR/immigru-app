import 'package:dartz/dartz.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/home/domain/repositories/event_repository.dart';

/// Use case for registering for an event
class RegisterForEventUseCase {
  final EventRepository repository;

  /// Create a new RegisterForEventUseCase
  RegisterForEventUseCase(this.repository);

  /// Execute the use case
  /// 
  /// [eventId] - ID of the event to register for
  /// [userId] - ID of the user registering
  Future<Either<Failure, bool>> call({
    required String eventId,
    required String userId,
  }) {
    return repository.registerForEvent(
      eventId: eventId,
      userId: userId,
    );
  }
}
