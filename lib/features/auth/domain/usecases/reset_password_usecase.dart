import 'package:immigru/features/auth/domain/repositories/auth_repository.dart';

/// Use case for resetting a user's password
class ResetPasswordUseCase {
  final AuthRepository _authRepository;

  /// Constructor
  ResetPasswordUseCase(this._authRepository);

  /// Execute the use case to reset a password
  Future<void> call({required String email}) async {
    return await _authRepository.resetPassword(email);
  }
}
