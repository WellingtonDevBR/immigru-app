import 'package:dartz/dartz.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/home/domain/repositories/immi_grove_repository.dart';

/// Use case for joining or leaving an ImmiGrove
class JoinImmiGroveUseCase {
  final ImmiGroveRepository repository;

  /// Create a new JoinImmiGroveUseCase
  JoinImmiGroveUseCase(this.repository);

  /// Execute the use case
  /// 
  /// [immiGroveId] - ID of the ImmiGrove to join/leave
  /// [userId] - ID of the user performing the action
  /// [join] - Whether to join (true) or leave (false)
  Future<Either<Failure, bool>> call({
    required String immiGroveId,
    required String userId,
    required bool join,
  }) {
    return repository.joinImmiGrove(
      immiGroveId: immiGroveId,
      userId: userId,
      join: join,
    );
  }
}
