import 'package:flutter/material.dart';
import 'package:immigru/presentation/blocs/auth/auth_state.dart';
import 'package:immigru/presentation/screens/auth/widgets/_shared/auth_google.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

class EmailSignupForm extends StatefulWidget {
  final Function(BuildContext) submitForm;
  final AuthState authState;
  final VoidCallback? onGoogleSignUpPressed;

  const EmailSignupForm({
    Key? key,
    required this.submitForm,
    required this.authState,
    this.onGoogleSignUpPressed,
  }) : super(key: key);

  @override
  State<EmailSignupForm> createState() => _EmailSignupFormState();
}

class _EmailSignupFormState extends State<EmailSignupForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() => _isPasswordVisible = !_isPasswordVisible);
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Email
        _buildTextField(
          controller: _emailController,
          hint: 'Enter your email',
          icon: Icons.email_outlined,
          isDarkMode: isDarkMode,
        ),
        const SizedBox(height: 16),

        // Password
        _buildTextField(
          controller: _passwordController,
          hint: 'Enter your password',
          icon: Icons.lock_outline,
          isDarkMode: isDarkMode,
          obscureText: !_isPasswordVisible,
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
            onPressed: _togglePasswordVisibility,
          ),
        ),
        const SizedBox(height: 16),

        // Confirm Password
        _buildTextField(
          controller: _confirmPasswordController,
          hint: 'Confirm your password',
          icon: Icons.lock_outline,
          isDarkMode: isDarkMode,
          obscureText: !_isConfirmPasswordVisible,
          suffixIcon: IconButton(
            icon: Icon(
              _isConfirmPasswordVisible
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
            onPressed: _toggleConfirmPasswordVisibility,
          ),
        ),
        const SizedBox(height: 16),

        // Terms
        _buildTermsCheckbox(isDarkMode, primaryColor),
        const SizedBox(height: 24),

        // Sign Up Button
        ElevatedButton(
          onPressed: widget.authState.isLoading
              ? null
              : () => widget.submitForm(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            disabledBackgroundColor: primaryColor.withOpacity(0.6),
          ),
          child: widget.authState.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Sign up',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
        const SizedBox(height: 24),

        // Divider
        Row(
          children: [
            Expanded(
              child:
                  Divider(color: isDarkMode ? Colors.white30 : Colors.black12),
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
              child:
                  Divider(color: isDarkMode ? Colors.white30 : Colors.black12),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Google button
        _buildGoogleSignUpButton(context, isDarkMode),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDarkMode,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    // Set keyboard type based on the icon/field type
    TextInputType keyboardType = TextInputType.text;
    if (icon == Icons.email_outlined) {
      keyboardType = TextInputType.emailAddress;
    } else if (icon == Icons.phone_outlined) {
      keyboardType = TextInputType.phone;
    }
    
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isDarkMode ? Colors.white54 : Colors.black38,
        ),
        filled: true,
        fillColor: isDarkMode
            ? Colors.grey.withOpacity(0.1)
            : Colors.grey.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(
          icon,
          color: isDarkMode ? Colors.white54 : Colors.black38,
          size: 20,
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildTermsCheckbox(bool isDarkMode, Color primaryColor) {
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _agreeToTerms,
            onChanged: (value) =>
                setState(() => _agreeToTerms = value ?? false),
            activeColor: primaryColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
                fontSize: 14,
              ),
              children: [
                const TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms of Service',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleSignUpButton(BuildContext context, bool isDarkMode) {
    return GoogleAuthButton(
      text: 'Sign up with Google',
      isLoading: widget.authState.isLoading,
      onPressed: () {
        if (widget.onGoogleSignUpPressed != null) {
          widget.onGoogleSignUpPressed!();
        } else {
          debugPrint(
              'Google Sign-Up button pressed, but no callback was provided');
        }
      },
      isDarkMode: isDarkMode,
    );
  }
}
