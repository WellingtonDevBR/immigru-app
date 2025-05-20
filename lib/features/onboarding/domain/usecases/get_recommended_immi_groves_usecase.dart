import '../entities/immi_grove.dart';
import '../repositories/immi_grove_repository.dart';

/// Use case for getting recommended ImmiGroves
class GetRecommendedImmiGrovesUseCase {
  final ImmiGroveRepository _repository;

  /// Creates a new instance of [GetRecommendedImmiGrovesUseCase]
  const GetRecommendedImmiGrovesUseCase(this._repository);

  /// Get recommended ImmiGroves for the current user
  /// 
  /// [limit] is the maximum number of ImmiGroves to return
  Future<List<ImmiGrove>> call({int limit = 6}) {
    return _repository.getRecommendedImmiGroves(limit: limit);
  }
}
