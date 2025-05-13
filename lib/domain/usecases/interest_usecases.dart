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

/// Use case for saving user interests
class SaveUserInterestsUseCase {
  final InterestRepository _repository;

  SaveUserInterestsUseCase(this._repository);

  /// Call method to execute the use case
  /// 
  /// [interestIds] is a list of interest IDs to save
  Future<bool> call(List<int> interestIds) async {
    return await _repository.saveUserInterests(interestIds);
  }
}

/// Use case for getting user interests
class GetUserInterestsUseCase {
  final InterestRepository _repository;

  GetUserInterestsUseCase(this._repository);

  /// Call method to execute the use case
  Future<List<Interest>> call() async {
    return await _repository.getUserInterests();
  }
}
