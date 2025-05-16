import 'package:immigru/features/auth/domain/repositories/auth_repository.dart';

/// Use case for user logout
class LogoutUseCase {
  final AuthRepository _repository;

  /// Constructor
  LogoutUseCase(this._repository);

  /// Execute the logout use case
  Future<void> call() {
    return _repository.signOut();
  }
}
