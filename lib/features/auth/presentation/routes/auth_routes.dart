import 'package:flutter/material.dart';
import 'package:immigru/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:immigru/features/auth/presentation/screens/login_screen.dart';
import 'package:immigru/features/auth/presentation/screens/phone_verification_screen.dart';
import 'package:immigru/features/auth/presentation/screens/signup_screen.dart';

/// Route configuration for the auth feature
class AuthRoutes {
  /// Register auth routes with the app's route configuration
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      LoginScreen.routeName: (context) => const LoginScreen(),
      SignupScreen.routeName: (context) => const SignupScreen(),
      ForgotPasswordScreen.routeName: (context) => const ForgotPasswordScreen(),
      PhoneVerificationScreen.routeName: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args is String) {
          return PhoneVerificationScreen(phoneNumber: args);
        }
        // Fallback if no phone number is provided
        return const PhoneVerificationScreen(phoneNumber: '');
      },
    };
  }

  /// Generate route for the auth feature
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case LoginScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
      case SignupScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => const SignupScreen(),
        );
      case ForgotPasswordScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
        );
      case PhoneVerificationScreen.routeName:
        final args = settings.arguments;
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => PhoneVerificationScreen(phoneNumber: args),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const PhoneVerificationScreen(phoneNumber: ''),
        );
      default:
        return null;
    }
  }
}
