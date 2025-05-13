import 'package:immigru/domain/entities/interest.dart';
import 'package:immigru/domain/repositories/interest_repository.dart';

/// Use case for getting all available interests
class GetInterestsUseCase {
  final InterestRepository _repository;

  GetInterestsUseCase(this._repository);

  /// Call method to execute the use case
  Future<List<Interest>> call() async {
    return await _repository.getInterests();
  }
}
