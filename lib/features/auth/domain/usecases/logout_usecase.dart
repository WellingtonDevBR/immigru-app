import 'package:dartz/dartz.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/core/storage/secure_storage.dart';
import 'package:immigru/features/auth/domain/repositories/auth_repository.dart';

/// Use case for user logout
class LogoutUseCase {
  final AuthRepository _repository;
  final UnifiedLogger _logger = UnifiedLogger();
  final SecureStorage _secureStorage = SecureStorage();

  /// Constructor
  LogoutUseCase(this._repository);

  /// Execute the logout use case
  /// 
  /// This will:
  /// 1. Sign out from the authentication provider
  /// 2. Clear any secure storage tokens
  /// 3. Clear any cached user data
  /// 
  /// Returns Either void on success or a Failure on error
  Future<Either<Failure, void>> call() async {
    _logger.d('Executing logout use case', tag: 'LogoutUseCase');
    
    try {
      // Clear any secure storage tokens first
      await _secureStorage.deleteAll();
      _logger.d('Cleared secure storage', tag: 'LogoutUseCase');
      
      // Then sign out from the authentication provider
      final result = await _repository.signOut();
      
      return result.fold(
        (failure) {
          _logger.e('Sign out failed: ${failure.message}', tag: 'LogoutUseCase');
          return Left(failure);
        },
        (_) {
          _logger.d('Successfully signed out', tag: 'LogoutUseCase');
          return const Right(null);
        },
      );
    } catch (e) {
      _logger.e('Unexpected error during logout: $e', tag: 'LogoutUseCase');
      return Left(Failure(
        message: 'An unexpected error occurred during logout',
        code: 'unexpected_logout_error',
      ));
    }
  }
}