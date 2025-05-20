import '../entities/interest.dart';
import '../repositories/interest_repository.dart';

/// Use case for retrieving user's selected interests
class GetUserInterestsUseCase {
  final InterestRepository _repository;

  const GetUserInterestsUseCase(this._repository);

  /// Execute the use case to get user's selected interests
  Future<List<Interest>> call() => _repository.getUserInterests();
}
