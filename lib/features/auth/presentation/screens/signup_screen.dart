import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/core/utils/input_validation.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_event.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_state.dart';
import 'package:immigru/features/auth/presentation/widgets/auth_button.dart';
import 'package:immigru/features/auth/presentation/widgets/auth_header.dart';
import 'package:immigru/features/auth/presentation/widgets/error_message_widget.dart';
import 'package:immigru/features/auth/presentation/widgets/social_login_button.dart';
import 'package:immigru/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:immigru/shared/theme/app_colors.dart';
import 'package:immigru/shared/theme/app_text_styles.dart';
import 'package:immigru/shared/widgets/secure_input_field.dart';

/// Signup screen for the app
class SignupScreen extends StatefulWidget {
  /// Route name for navigation
  static const String routeName = '/signup';

  /// Constructor
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleAgreeToTerms(bool? value) {
    setState(() {
      _agreeToTerms = value ?? false;
    });
  }

  void _handleSignup() {
    // Clear any previous errors
    context.read<AuthBloc>().add(AuthClearErrorEvent());
    
    // First validate the form inputs
    if (_formKey.currentState?.validate() ?? false) {
      // Check if user agreed to terms
      if (!_agreeToTerms) {
        context.read<AuthBloc>().add(
          AuthSetErrorEvent(
            message: 'Please agree to the terms and conditions before signing up',
            code: 'terms_not_accepted',
          ),
        );
        return;
      }
      
      // Validate password strength
      final passwordError = InputValidation.validatePassword(_passwordController.text);
      if (passwordError != null) {
        // Determine the specific error code based on the error message
        String errorCode = 'weak_password';
        if (passwordError.contains('at least 8 characters')) {
          errorCode = 'password_too_short';
        } else if (passwordError.contains('uppercase') || 
                  passwordError.contains('lowercase') || 
                  passwordError.contains('number') || 
                  passwordError.contains('special character')) {
          errorCode = 'password_complexity';
        }
        
        context.read<AuthBloc>().add(
          AuthSetErrorEvent(
            message: passwordError,
            code: errorCode,
          ),
        );
        return;
      }
      
      // Validate password match
      if (_passwordController.text != _confirmPasswordController.text) {
        context.read<AuthBloc>().add(
          AuthSetErrorEvent(
            message: 'Passwords do not match. Please try again.',
            code: 'password_mismatch',
          ),
        );
        return;
      }
      
      // All validations passed, proceed with signup
      context.read<AuthBloc>().add(
        AuthSignUpWithEmailEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  void _handleGoogleLogin() {
    // Clear any previous errors
    context.read<AuthBloc>().add(AuthClearErrorEvent());
    
    context.read<AuthBloc>().add(AuthSignInWithGoogleEvent());
  }

  void _navigateToLogin() {
    Navigator.of(context).pop();
  }
  
  void _dismissError() {
    // Clear errors by emitting a new state without errors
    context.read<AuthBloc>().add(AuthClearErrorEvent());
  }

  void _navigateToTerms() {
    // Navigate to terms and conditions
  }

  void _navigateToPrivacyPolicy() {
    // Navigate to privacy policy
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.isAuthenticated) {
            // Use direct navigation for onboarding for consistency
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            );
          }
          
          // Error handling is now managed directly by the BLoC
          // and displayed in the UI via the ErrorMessageWidget
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTitle(),
                      const SizedBox(height: 24),
                      
                      // Display error message if there is one
                      if (state.errorMessage != null && state.errorMessage!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: ErrorMessageWidget(
                            message: state.errorMessage!,
                            errorCode: state.errorCode,
                            onClose: _dismissError,
                            withHapticFeedback: true,
                          ),
                        ),
                      
                      const SizedBox(height: 16),
                      _buildSignupForm(),
                      const SizedBox(height: 24),
                      _buildTermsAndConditions(),
                      const SizedBox(height: 24),
                      _buildSignupButton(state),
                      const SizedBox(height: 24),
                      _buildSocialLoginDivider(),
                      const SizedBox(height: 24),
                      _buildSocialLoginButtons(),
                      const SizedBox(height: 40),
                      _buildLoginPrompt(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitle() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthHeader(
          title: 'Create Account',
          isDarkMode: isDarkMode,
          primaryColor: primaryColor,
        ),
        const SizedBox(height: 8),
        Text(
          'Sign up to start your immigration journey',
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildSignupForm() {
    final focusNode1 = FocusNode();
    final focusNode2 = FocusNode();
    final focusNode3 = FocusNode();
    
    return Column(
      children: [
        // Email field
        SecureInputField(
          controller: _emailController,
          focusNode: focusNode1,
          labelText: 'Email',
          hintText: 'Enter your email',
          inputType: SecureInputType.email,
          autoValidate: true,
        ),
        const SizedBox(height: 16),
        
        // Password field with requirements
        SecureInputField(
          controller: _passwordController,
          focusNode: focusNode2,
          labelText: 'Password',
          hintText: 'Enter your password',
          inputType: SecureInputType.password,
          showPasswordRequirements: true,
          autoValidate: true,
          onChanged: (value) {
            // Force rebuild of confirm password field when password changes
            if (_confirmPasswordController.text.isNotEmpty) {
              setState(() {});
            }
          },
        ),
        const SizedBox(height: 16),
        
        // Confirm password field
        SecureInputField(
          controller: _confirmPasswordController,
          focusNode: focusNode3,
          labelText: 'Confirm Password',
          hintText: 'Confirm your password',
          inputType: SecureInputType.password,
          showPasswordRequirements: false,
          autoValidate: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            if (value != _passwordController.text) {
              // No need to set global error here, just return validation error
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTermsAndConditions() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _agreeToTerms,
            onChanged: _toggleAgreeToTerms,
            activeColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: 'By creating an account, you agree to our ',
              style: AppTextStyles.bodySmall(brightness: Theme.of(context).brightness),
              children: [
                TextSpan(
                  text: 'Terms of Service',
                  style: AppTextStyles.bodySmall(brightness: Theme.of(context).brightness).copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = _navigateToTerms,
                ),
                const TextSpan(
                  text: ' and ',
                ),
                TextSpan(
                  text: 'Privacy Policy',
                  style: AppTextStyles.bodySmall(brightness: Theme.of(context).brightness).copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = _navigateToPrivacyPolicy,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignupButton(AuthState state) {
    return AuthButton(
      text: 'Sign Up',
      isLoading: state.isLoading,
      onPressed: _handleSignup,
    );
  }

  Widget _buildSocialLoginDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.border(Theme.of(context).brightness),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Or continue with',
            style: AppTextStyles.bodySmall(brightness: Theme.of(context).brightness).copyWith(
              color: AppColors.textSecondary(Theme.of(context).brightness),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.border(Theme.of(context).brightness),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLoginButtons() {
    return SocialLoginButton(
      text: 'Continue with Google',
      icon: 'assets/icons/google_logo.svg',
      onPressed: _handleGoogleLogin,
    );
  }

  Widget _buildLoginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: AppTextStyles.bodySmall(brightness: Theme.of(context).brightness),
        ),
        TextButton(
          onPressed: _navigateToLogin,
          child: Text(
            'Login',
            style: AppTextStyles.buttonMedium(brightness: Theme.of(context).brightness).copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
