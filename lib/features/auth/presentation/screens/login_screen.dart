import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_event.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_state.dart';
import 'package:immigru/features/auth/presentation/screens/phone_verification_screen.dart';
import 'package:immigru/features/auth/presentation/widgets/auth_footer.dart';
import 'package:immigru/features/auth/presentation/widgets/auth_header.dart';
import 'package:immigru/features/auth/presentation/widgets/auth_wrapper.dart';
import 'package:immigru/features/auth/presentation/widgets/email_login_widget.dart';
import 'package:immigru/features/auth/presentation/widgets/error_message_widget.dart';
import 'package:immigru/features/auth/presentation/widgets/phone_login_widget.dart';
import 'package:immigru/features/onboarding/presentation/screens/onboarding_screen.dart';

/// Login screen for the application
/// Supports both email and phone authentication methods
class LoginScreen extends StatefulWidget {
  /// Route name for navigation
  static const String routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEmailTab = true;

  // Constants for SharedPreferences keys
  static const String _emailKey = 'last_login_email';

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Loads the previously saved email from SharedPreferences
  Future<void> _loadSavedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString(_emailKey);
      if (savedEmail != null && savedEmail.isNotEmpty) {
        setState(() {
          _emailController.text = savedEmail;
        });
      }
    } catch (e) {}
  }

  /// Saves the email to SharedPreferences for future use
  Future<void> _saveEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_emailKey, email);
    } catch (e) {}
  }

  // Password visibility is now handled by SecureInputField

  // Only allow explicit user-triggered tab switching
  void _toggleTab(bool isEmailTab) {
    setState(() {
      _isEmailTab = isEmailTab;
    });
  }

  void _handleEmailLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      context.read<AuthBloc>().add(AuthSetErrorEvent(
            message: 'Please fill in all fields',
            code: 'validation_error',
          ));
      return;
    }

    // Save email for future use
    _saveEmail(email);

    // Dispatch login event to BLoC
    context.read<AuthBloc>().add(AuthSignInWithEmailEvent(
          email: email,
          password: password,
        ));
  }

  void _handlePhoneLogin() {
    // Get the selected country code from the PhoneLoginWidget using the global key
    final countryCode =
        phoneLoginWidgetKey.currentState?.getCountryCode() ?? '+1';
    final phoneDigits = _phoneController.text.trim();

    if (phoneDigits.isEmpty) {
      context.read<AuthBloc>().add(AuthSetErrorEvent(
            message: 'Please enter your phone number',
            code: 'validation_error',
          ));
      return;
    }

    // Combine country code with phone number to create E.164 format
    final fullPhoneNumber = countryCode + phoneDigits;

    // Validate phone number format (E.164 format required by Supabase)
    if (!RegExp(r'^\+[0-9]{1,4}[0-9]{6,12}$').hasMatch(fullPhoneNumber)) {
      context.read<AuthBloc>().add(AuthSetErrorEvent(
            message: 'Please enter a valid phone number',
            code: 'validation_error',
          ));
      return;
    }

    // Store the full phone number in a variable that will be accessible to the BlocConsumer
    // This ensures we have the correct number when navigating to the verification screen
    _phoneController.text = phoneDigits; // Keep only digits in the controller

    // Dispatch phone auth event to BLoC
    context.read<AuthBloc>().add(AuthStartPhoneAuthEvent(
          phoneNumber: fullPhoneNumber,
        ));

    // Navigate directly to the OTP verification screen
    // This approach is more reliable than depending on state changes
    Navigator.of(context).pushNamed(
      PhoneVerificationScreen.routeName,
      arguments: fullPhoneNumber,
    );
  }

  void _handleGoogleLogin() {
    context.read<AuthBloc>().add(AuthSignInWithGoogleEvent());
  }

  void _navigateToSignUp() {
    Navigator.of(context).pushNamed('/signup');
  }

  void _navigateToForgotPassword() {
    Navigator.of(context).pushNamed('/forgot-password');
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.isAuthenticated) {
            if (state.user?.hasCompletedOnboarding ?? false) {
              AuthWrapper.navigateToRoot(context);
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const OnboardingScreen()),
              );
            }
          }

          // Handle OTP code sent state
          if (state.isCodeSent && !state.isLoading) {
            // Get the full phone number for verification
            final countryCode =
                phoneLoginWidgetKey.currentState?.getCountryCode() ?? '+1';
            final phoneDigits = _phoneController.text.trim();
            final fullPhoneNumber = countryCode + phoneDigits;

            // Navigate to phone verification screen with the full phone number
            Navigator.of(context).pushNamed(
              PhoneVerificationScreen.routeName,
              arguments: fullPhoneNumber,
            );
          }

          // Error handling is now managed directly by the BLoC
          // and displayed in the UI via the ErrorMessageWidget
          if (state.errorMessage != null && !state.isLoading) {
            // IMPORTANT: Do not reset the tab state on error
          }
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
                      // App logo and welcome message
                      AuthHeader(
                        title: 'Immigru',
                        isDarkMode: isDarkMode,
                        primaryColor: primaryColor,
                      ),

                      const SizedBox(height: 32),

                      // Error message display using the ErrorMessageWidget
                      if (state.errorMessage != null)
                        ErrorMessageWidget(
                          message: state.errorMessage!,
                          errorCode: state.errorCode,
                          onClose: () {
                            context.read<AuthBloc>().add(AuthClearErrorEvent());
                          },
                        ),

                      const SizedBox(height: 16),

                      // Tab bar for switching between email and phone login
                      Container(
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.grey.withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _toggleTab(true),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    color: _isEmailTab
                                        ? primaryColor
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Email',
                                      style: TextStyle(
                                        color: _isEmailTab
                                            ? Colors.white
                                            : isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _toggleTab(false),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    color: !_isEmailTab
                                        ? primaryColor
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Phone',
                                      style: TextStyle(
                                        color: !_isEmailTab
                                            ? Colors.white
                                            : isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Login form based on selected tab
                      if (_isEmailTab)
                        EmailLoginWidget(
                          emailController: _emailController,
                          passwordController: _passwordController,
                          isDarkMode: isDarkMode,
                          state: state,
                          onEmailLogin: _handleEmailLogin,
                          onGoogleSignIn: _handleGoogleLogin,
                          onForgotPassword: _navigateToForgotPassword,
                        )
                      else
                        PhoneLoginWidget(
                          key: phoneLoginWidgetKey,
                          phoneController: _phoneController,
                          isDarkMode: isDarkMode,
                          state: state,
                          onPhoneLogin: _handlePhoneLogin,
                          onGoogleSignIn: _handleGoogleLogin,
                        ),

                      const SizedBox(height: 24),

                      // Sign up link
                      AuthFooter(
                        promptText: "Don't have an account?",
                        actionText: 'Sign Up',
                        onPressed: _navigateToSignUp,
                        isDarkMode: isDarkMode,
                        primaryColor: primaryColor,
                      ),
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
}
