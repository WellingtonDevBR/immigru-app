import 'package:immigru/features/auth/domain/entities/user.dart';
import 'package:immigru/features/auth/domain/repositories/auth_repository.dart';

/// Use case for user signup with email and password
class SignUpWithEmailUseCase {
  final AuthRepository _repository;

  /// Constructor
  SignUpWithEmailUseCase(this._repository);

  /// Execute the signup use case
  Future<User> call(String email, String password) {
    return _repository.signUpWithEmailAndPassword(email, password);
  }
}
