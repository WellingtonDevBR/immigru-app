import 'package:dartz/dartz.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/auth/domain/repositories/auth_repository.dart';

/// Use case for user logout
class LogoutUseCase {
  final AuthRepository _repository;

  /// Constructor
  LogoutUseCase(this._repository);

  /// Execute the logout use case
  /// 
  /// Returns Either void on success or a Failure on error
  Future<Either<Failure, void>> call() {
    return _repository.signOut();
  }
}