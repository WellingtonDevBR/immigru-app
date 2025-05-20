import '../entities/immi_grove.dart';
import '../repositories/immi_grove_repository.dart';

/// Use case for getting ImmiGroves that the user has joined
class GetJoinedImmiGrovesUseCase {
  final ImmiGroveRepository _repository;

  /// Creates a new instance of [GetJoinedImmiGrovesUseCase]
  const GetJoinedImmiGrovesUseCase(this._repository);

  /// Get ImmiGroves that the current user has joined
  Future<List<ImmiGrove>> call() {
    return _repository.getJoinedImmiGroves();
  }
}
