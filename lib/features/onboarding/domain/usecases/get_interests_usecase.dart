import '../entities/interest.dart';
import '../repositories/interest_repository.dart';

/// Use case for retrieving all available interests
class GetInterestsUseCase {
  final InterestRepository _repository;

  const GetInterestsUseCase(this._repository);

  /// Execute the use case to get all available interests
  Future<List<Interest>> call() => _repository.getInterests();
}
