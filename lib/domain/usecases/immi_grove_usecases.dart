import 'package:immigru/domain/entities/immi_grove.dart';
import 'package:immigru/domain/repositories/immi_grove_repository.dart';

/// Use case for getting recommended ImmiGroves
class GetRecommendedImmiGrovesUseCase {
  final ImmiGroveRepository _repository;

  GetRecommendedImmiGrovesUseCase(this._repository);

  Future<List<ImmiGrove>> call({int limit = 6}) {
    return _repository.getRecommendedImmiGroves(limit: limit);
  }
}

/// Use case for joining an ImmiGrove
class JoinImmiGroveUseCase {
  final ImmiGroveRepository _repository;

  JoinImmiGroveUseCase(this._repository);

  Future<void> call(String immiGroveId) {
    return _repository.joinImmiGrove(immiGroveId);
  }
}

/// Use case for leaving an ImmiGrove
class LeaveImmiGroveUseCase {
  final ImmiGroveRepository _repository;

  LeaveImmiGroveUseCase(this._repository);

  Future<void> call(String immiGroveId) {
    return _repository.leaveImmiGrove(immiGroveId);
  }
}

/// Use case for getting ImmiGroves that the user has joined
class GetJoinedImmiGrovesUseCase {
  final ImmiGroveRepository _repository;

  GetJoinedImmiGrovesUseCase(this._repository);

  Future<List<ImmiGrove>> call() {
    return _repository.getJoinedImmiGroves();
  }
}
