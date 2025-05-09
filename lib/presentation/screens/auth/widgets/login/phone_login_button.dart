import 'package:flutter/material.dart';
import 'package:immigru/presentation/blocs/auth/auth_state.dart';
import 'package:immigru/presentation/screens/auth/widgets/login/google_sign_in_button.dart';

/// Widget for phone login button
class PhoneLoginButton extends StatelessWidget {
  final bool isDarkMode;
  final Color primaryColor;
  final AuthState state;
  final Function(BuildContext) onPhoneLogin;
  final Function(BuildContext) onGoogleSignIn;

  const PhoneLoginButton({
    Key? key,
    required this.isDarkMode,
    required this.primaryColor,
    required this.state,
    required this.onPhoneLogin,
    required this.onGoogleSignIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Icon(
            Icons.phone_android,
            size: 64,
            color: primaryColor.withOpacity(0.8),
          ),
          const SizedBox(height: 24),
          Text(
            'Sign in with your phone number',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'We\'ll send you a verification code to confirm your identity',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: state.isLoading ? null : () => onPhoneLogin(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Continue with Phone',
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
                  'OR',
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
    return GoogleSignInButton(
      isLoading: state.isLoading,
      onPressed: () => onGoogleSignIn(context),
      isDarkMode: isDarkMode,
    );
  }
}
