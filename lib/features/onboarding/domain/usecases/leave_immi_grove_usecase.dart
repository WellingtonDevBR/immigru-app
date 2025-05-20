import '../repositories/immi_grove_repository.dart';

/// Use case for leaving an ImmiGrove community
class LeaveImmiGroveUseCase {
  final ImmiGroveRepository _repository;

  /// Creates a new instance of [LeaveImmiGroveUseCase]
  const LeaveImmiGroveUseCase(this._repository);

  /// Leave an ImmiGrove community
  /// 
  /// [immiGroveId] is the ID of the ImmiGrove to leave
  Future<void> call(String immiGroveId) {
    return _repository.leaveImmiGrove(immiGroveId);
  }
}
