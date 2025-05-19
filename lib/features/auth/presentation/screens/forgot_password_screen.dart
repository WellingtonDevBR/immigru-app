import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_event.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_state.dart';
import 'package:immigru/features/auth/presentation/widgets/auth_button.dart';
import 'package:immigru/features/auth/presentation/widgets/auth_header.dart';
import 'package:immigru/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:immigru/features/auth/presentation/widgets/error_message_widget.dart';
import 'package:immigru/shared/theme/app_colors.dart';
import 'package:immigru/shared/theme/app_text_styles.dart';

/// Screen for resetting password
class ForgotPasswordScreen extends StatefulWidget {
  /// Route name for navigation
  static const routeName = '/forgot-password';

  /// Constructor
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _resetEmailSent = false;
  String? _errorMessage;
  String? _errorCode;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleResetPassword() {
    // Clear any previous errors
    setState(() {
      _errorMessage = null;
      _errorCode = null;
    });
    
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      
      if (email.isEmpty) {
        setState(() {
          _errorMessage = 'Please enter your email address';
          _errorCode = 'empty_email';
        });
        return;
      }
      
      context.read<AuthBloc>().add(
        AuthResetPasswordEvent(
          email: email,
        ),
      );
      
      // Show success message
      setState(() {
        _resetEmailSent = true;
      });
    }
  }
  
  void _dismissError() {
    setState(() {
      _errorMessage = null;
      _errorCode = null;
    });
  }

  void _navigateToLogin() {
    Navigator.of(context).pop();
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
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            setState(() {
              _errorMessage = state.errorMessage;
              _errorCode = state.errorCode;
              _resetEmailSent = false; // Reset success state if there's an error
            });
          }
        },
        child: SafeArea(
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
                    if (_errorMessage != null && !_resetEmailSent)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: ErrorMessageWidget(
                          message: _errorMessage!,
                          errorCode: _errorCode,
                          onClose: _dismissError,
                        ),
                      ),
                    
                    const SizedBox(height: 16),
                    if (!_resetEmailSent) ...[
                      _buildEmailField(),
                      const SizedBox(height: 40),
                      _buildResetButton(context.read<AuthBloc>().state),
                    ] else ...[
                      _buildSuccessMessage(),
                      const SizedBox(height: 40),
                      _buildBackToLoginButton(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
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
          title: 'Forgot Password',
          isDarkMode: isDarkMode,
          primaryColor: primaryColor,
        ),
        const SizedBox(height: 8),
        Text(
          _resetEmailSent
              ? 'Check your email for reset instructions'
              : 'Enter your email to receive password reset instructions',
          style: AppTextStyles.bodyLarge(brightness: Theme.of(context).brightness).copyWith(
            color: AppColors.textSecondary(Theme.of(context).brightness),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return AuthTextField(
      controller: _emailController,
      label: 'Email',
      hint: 'Enter your email',
      keyboardType: TextInputType.emailAddress,
      prefixIcon: Icons.email,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildResetButton(AuthState state) {
    return AuthButton(
      text: 'Reset Password',
      isLoading: state.isLoading,
      onPressed: _handleResetPassword,
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha:0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.email_outlined,
            size: 40,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Email Sent!',
          style: AppTextStyles.heading2(brightness: Theme.of(context).brightness),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'If an account exists with this email, we\'ve sent password reset instructions. Please check your inbox and follow the instructions to reset your password.',
          style: AppTextStyles.bodyMedium(brightness: Theme.of(context).brightness).copyWith(
            color: AppColors.textSecondary(Theme.of(context).brightness),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBackToLoginButton() {
    return AuthButton(
      text: 'Back to Login',
      onPressed: _navigateToLogin,
    );
  }
}
