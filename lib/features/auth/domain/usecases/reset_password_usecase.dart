import 'package:dartz/dartz.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/auth/domain/repositories/auth_repository.dart';

/// Use case for resetting a user's password
class ResetPasswordUseCase {
  final AuthRepository _authRepository;

  /// Constructor
  ResetPasswordUseCase(this._authRepository);

  /// Execute the use case to reset a password
  ///
  /// Returns Either void on success or a Failure on error
  Future<Either<Failure, void>> call({required String email}) {
    return _authRepository.resetPassword(email);
  }
}
