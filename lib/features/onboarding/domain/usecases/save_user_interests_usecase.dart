import '../repositories/interest_repository.dart';

/// Use case for saving user's selected interests
class SaveUserInterestsUseCase {
  final InterestRepository _repository;

  const SaveUserInterestsUseCase(this._repository);

  /// Execute the use case to save user's selected interests
  Future<bool> call(List<int> interestIds) => _repository.saveUserInterests(interestIds);
}
