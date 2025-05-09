import 'package:immigru/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Use case for sending OTP to phone number
class SendOtpToPhoneUseCase {
  final AuthRepository _repository;

  SendOtpToPhoneUseCase(this._repository);

  Future<void> call({required String phone}) {
    return _repository.sendOtpToPhone(phone: phone);
  }
}

/// Use case for verifying phone with OTP
class VerifyPhoneOtpUseCase {
  final AuthRepository _repository;

  VerifyPhoneOtpUseCase(this._repository);

  Future<AuthResponse> call({required String phone, required String otpCode}) {
    return _repository.verifyPhoneOtp(phone: phone, otpCode: otpCode);
  }
}

/// Use case for signing in with email and password
class SignInWithEmailUseCase {
  final AuthRepository _repository;

  SignInWithEmailUseCase(this._repository);

  Future<AuthResponse> call({required String email, required String password}) {
    return _repository.signInWithEmail(email: email, password: password);
  }
}

/// Use case for signing up with email and password
class SignUpWithEmailUseCase {
  final AuthRepository _repository;

  SignUpWithEmailUseCase(this._repository);

  Future<AuthResponse> call({required String email, required String password}) {
    return _repository.signUpWithEmail(email: email, password: password);
  }
}

/// Use case for signing out
class SignOutUseCase {
  final AuthRepository _repository;

  SignOutUseCase(this._repository);

  Future<void> call() {
    return _repository.signOut();
  }
}

/// Use case for resetting password
class ResetPasswordUseCase {
  final AuthRepository _repository;

  ResetPasswordUseCase(this._repository);

  Future<void> call(String email) {
    return _repository.resetPassword(email);
  }
}

/// Use case for getting the current user
class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  User? call() {
    return _repository.currentUser;
  }
}

/// Use case for checking if user is authenticated
class IsAuthenticatedUseCase {
  final AuthRepository _repository;

  IsAuthenticatedUseCase(this._repository);

  bool call() {
    return _repository.isAuthenticated;
  }
}
