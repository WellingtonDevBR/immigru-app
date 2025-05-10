import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class AuthSignupEvent extends AuthEvent {
  final String email;
  final String password;
  final String? name;
  final bool agreeToTerms;

  const AuthSignupEvent({
    required this.email,
    required this.password,
    this.name,
    this.agreeToTerms = false,
  });

  @override
  List<Object?> get props => [email, password, name, agreeToTerms];
}

class AuthLogoutEvent extends AuthEvent {}

class AuthCheckStatusEvent extends AuthEvent {}

class AuthGoogleLoginEvent extends AuthEvent {}

class AuthPhoneLoginEvent extends AuthEvent {
  final String phone;
  final String otpCode;

  const AuthPhoneLoginEvent({
    required this.phone,
    required this.otpCode,
  });

  @override
  List<Object> get props => [phone, otpCode];
}

class AuthSendOtpEvent extends AuthEvent {
  final String phone;

  const AuthSendOtpEvent({
    required this.phone,
  });

  @override
  List<Object> get props => [phone];
}

class AuthResetPasswordEvent extends AuthEvent {
  final String email;

  const AuthResetPasswordEvent({
    required this.email,
  });

  @override
  List<Object> get props => [email];
}
