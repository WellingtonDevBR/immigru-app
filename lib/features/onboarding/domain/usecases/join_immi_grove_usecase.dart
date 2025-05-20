import '../repositories/immi_grove_repository.dart';

/// Use case for joining an ImmiGrove community
class JoinImmiGroveUseCase {
  final ImmiGroveRepository _repository;

  /// Creates a new instance of [JoinImmiGroveUseCase]
  const JoinImmiGroveUseCase(this._repository);

  /// Join an ImmiGrove community
  /// 
  /// [immiGroveId] is the ID of the ImmiGrove to join
  Future<void> call(String immiGroveId) {
    return _repository.joinImmiGrove(immiGroveId);
  }
}
