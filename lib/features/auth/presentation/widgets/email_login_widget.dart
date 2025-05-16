import 'package:flutter/material.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_state.dart';
import 'package:immigru/features/auth/presentation/widgets/auth_button.dart';
import 'package:immigru/features/auth/presentation/widgets/social_login_button.dart';
import 'package:immigru/shared/theme/app_colors.dart';
import 'package:immigru/shared/theme/app_text_styles.dart';
import 'package:immigru/shared/widgets/secure_input_field.dart';

/// Widget for email login form
class EmailLoginWidget extends StatelessWidget {
  /// Controller for email input
  final TextEditingController emailController;

  /// Controller for password input
  final TextEditingController passwordController;

  /// Whether the app is in dark mode
  final bool isDarkMode;

  /// Current auth state
  final AuthState state;

  /// Callback for email login
  final VoidCallback onEmailLogin;

  /// Callback for Google sign in
  final VoidCallback onGoogleSignIn;

  /// Callback for forgot password
  final VoidCallback onForgotPassword;

  /// Constructor
  const EmailLoginWidget({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isDarkMode,
    required this.state,
    required this.onEmailLogin,
    required this.onGoogleSignIn,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Email field with enhanced validation and security
        SecureInputField(
          controller: emailController,
          labelText: 'Email',
          hintText: 'Enter your email',
          inputType: SecureInputType.email,
          autoValidate: true,
        ),
        const SizedBox(height: 16),

        // Password field with enhanced validation and security
        SecureInputField(
          controller: passwordController,
          labelText: 'Password',
          hintText: 'Enter your password',
          inputType: SecureInputType.password,
          showPasswordRequirements: false, // Don't show requirements on login
          autoValidate: true,
        ),
        const SizedBox(height: 8),

        // Forgot password link
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onForgotPassword,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Forgot Password?',
              style: AppTextStyles.buttonMedium(
                brightness: isDarkMode ? Brightness.dark : Brightness.light,
              ).copyWith(
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Error messages are now handled at the screen level
        // for consistent positioning and behavior

        // Login button
        AuthButton(
          text: 'Login',
          isLoading: state.isLoading,
          onPressed: onEmailLogin,
        ),

        const SizedBox(height: 24),

        // Divider
        Row(
          children: [
            Expanded(
              child: Divider(
                color: isDarkMode ? Colors.white30 : Colors.black12,
                thickness: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: AppTextStyles.bodySmall(
                  brightness: isDarkMode ? Brightness.dark : Brightness.light,
                ).copyWith(
                  color: isDarkMode ? Colors.white54 : Colors.black45,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: isDarkMode ? Colors.white30 : Colors.black12,
                thickness: 1,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Google sign in button
        SocialLoginButton(
          text: 'Continue with Google',
          icon: 'assets/icons/google_logo.svg',
          onPressed: onGoogleSignIn,
        ),
      ],
    );
  }
}
