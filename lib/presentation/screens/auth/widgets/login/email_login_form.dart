import 'package:flutter/material.dart';
import 'package:immigru/presentation/blocs/auth/auth_state.dart';
import 'package:immigru/presentation/screens/auth/widgets/_shared/auth_google.dart';

/// Widget for email login form
class EmailLoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool isDarkMode;
  final Color primaryColor;
  final AuthState state;
  final Function() togglePasswordVisibility;
  final Function(BuildContext, AuthState) onSubmit;
  final VoidCallback? onGoogleSignInPressed;

  const EmailLoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isDarkMode,
    required this.primaryColor,
    required this.state,
    required this.togglePasswordVisibility,
    required this.onSubmit,
    this.onGoogleSignInPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email field
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your email',
              hintStyle: TextStyle(
                color: isDarkMode ? Colors.white54 : Colors.black38,
              ),
              filled: true,
              fillColor: isDarkMode 
                  ? Colors.grey.withValues(alpha: 0.1) 
                  : Colors.grey.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Icon(
                Icons.email_outlined,
                color: isDarkMode ? Colors.white54 : Colors.black38,
                size: 20,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: passwordController,
            obscureText: obscurePassword,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your password',
              hintStyle: TextStyle(
                color: isDarkMode ? Colors.white54 : Colors.black38,
              ),
              filled: true,
              fillColor: isDarkMode 
                  ? Colors.grey.withValues(alpha: 0.1) 
                  : Colors.grey.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Icon(
                Icons.lock_outline,
                color: isDarkMode ? Colors.white54 : Colors.black38,
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: isDarkMode ? Colors.white54 : Colors.black38,
                  size: 20,
                ),
                onPressed: togglePasswordVisibility,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Forgot Password
          Align(
            alignment: Alignment.centerRight, 
            child: TextButton(
              onPressed: () {
                // TODO: Implement forgot password
              },
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Login Button
          ElevatedButton(
            onPressed: state.isLoading ? null : () => onSubmit(context, state),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              disabledBackgroundColor: primaryColor.withValues(alpha: 0.6),
            ),
            child: state.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Log in',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          
          const SizedBox(height: 24),
          
          // OR divider
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: isDarkMode ? Colors.white30 : Colors.black12,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR CONTINUE WITH',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white54 : Colors.black45,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: isDarkMode ? Colors.white30 : Colors.black12,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Google sign-in button
          _buildGoogleSignInButton(context),
        ],
      ),
    );
  }
  
  Widget _buildGoogleSignInButton(BuildContext context) {
    return GoogleAuthButton (
      isLoading: state.isLoading,
      text: 'Sign in with Google',
      onPressed: () {
        // Pass the click event up to the parent widget if callback is provided
        if (onGoogleSignInPressed != null) {
          onGoogleSignInPressed!();
        } else {
          debugPrint('Google Sign-In button pressed, but no callback was provided');
        }
      },
      isDarkMode: isDarkMode,
    );
  }
}
