import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/core/constants/app_colors.dart';
import 'package:immigru/core/di/injection_container.dart';
import 'package:immigru/presentation/blocs/auth/auth_bloc.dart';
import 'package:immigru/presentation/blocs/auth/auth_event.dart';
import 'package:immigru/presentation/blocs/auth/auth_state.dart';
import 'package:immigru/presentation/screens/auth/login_screen.dart';
import 'package:immigru/presentation/screens/home/home_screen.dart';
import 'package:immigru/presentation/widgets/auth/social_login_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  void _submitForm(BuildContext context, AuthState state) {
    if (_formKey.currentState!.validate() && _agreeToTerms) {
      context.read<AuthBloc>().add(
            AuthSignupEvent(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              name: '', // We're not collecting name in this design
            ),
          );
    } else if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms of Service and Privacy Policy'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    final primaryColor = AppColors.primaryColor;
    
    return BlocProvider(
      create: (context) => sl<AuthBloc>(),
      child: Scaffold(
        backgroundColor: isDarkMode ? AppColors.darkBackground : Colors.white,
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.hasError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'An error occurred'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            
            // Navigate to home screen when authentication is successful
            if (state.isAuthenticated) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            }
          },
          builder: (context, state) {
            // Show loading indicator when authentication is in progress
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            return SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    decoration: BoxDecoration(
                      color: isDarkMode ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isDarkMode ? null : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Tab selector (Email/Phone)
                          Container(
                            decoration: BoxDecoration(
                              color: isDarkMode 
                                  ? Colors.black.withOpacity(0.2) 
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                // Email Tab
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: const Text(
                                      'Email',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                // Phone Tab
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: Text(
                                      'Phone',
                                      style: TextStyle(
                                        color: isDarkMode ? Colors.white70 : Colors.black54,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Create account header
                          Text(
                            'Create your account',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Begin your journey with Immigru',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Email Field
                          Text(
                            'Email',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: isDarkMode 
                                  ? Colors.grey.withOpacity(0.1) 
                                  : Colors.grey.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDarkMode 
                                    ? Colors.grey.withOpacity(0.2) 
                                    : Colors.grey.withOpacity(0.1),
                              ),
                            ),
                            child: TextFormField(
                              controller: _emailController,
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                if (!emailRegExp.hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: 'your.email@example.com',
                                hintStyle: TextStyle(
                                  color: isDarkMode ? Colors.white54 : Colors.black38,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: isDarkMode ? Colors.white54 : Colors.black38,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        
                          // Password Field
                          Text(
                            'Password',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: isDarkMode 
                                  ? Colors.grey.withOpacity(0.1) 
                                  : Colors.grey.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDarkMode 
                                    ? Colors.grey.withOpacity(0.2) 
                                    : Colors.grey.withOpacity(0.1),
                              ),
                            ),
                            child: TextFormField(
                              controller: _passwordController,
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                              obscureText: _obscurePassword,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 8) {
                                  return 'Password must be at least 8 characters';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: 'Create a strong password',
                                hintStyle: TextStyle(
                                  color: isDarkMode ? Colors.white54 : Colors.black38,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: isDarkMode ? Colors.white54 : Colors.black38,
                                  size: 20,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    color: isDarkMode ? Colors.white54 : Colors.black38,
                                    size: 20,
                                  ),
                                  onPressed: _togglePasswordVisibility,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Confirm Password Field
                          Text(
                            'Confirm Password',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: isDarkMode 
                                  ? Colors.grey.withOpacity(0.1) 
                                  : Colors.grey.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDarkMode 
                                    ? Colors.grey.withOpacity(0.2) 
                                    : Colors.grey.withOpacity(0.1),
                              ),
                            ),
                            child: TextFormField(
                              controller: _confirmPasswordController,
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                              obscureText: _obscureConfirmPassword,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: 'Confirm your password',
                                hintStyle: TextStyle(
                                  color: isDarkMode ? Colors.white54 : Colors.black38,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: isDarkMode ? Colors.white54 : Colors.black38,
                                  size: 20,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                    color: isDarkMode ? Colors.white54 : Colors.black38,
                                    size: 20,
                                  ),
                                  onPressed: _toggleConfirmPasswordVisibility,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
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
                          const SizedBox(height: 16),
                          
                          // Social login options
                          Row(
                            children: [
                              // Google button
                              Expanded(
                                child: SocialLoginButton(
                                  platform: 'Google',
                                  logoPath: 'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg',
                                  isNetworkImage: true,
                                  isLoading: state.isLoading,
                                  onPressed: () {
                                    context.read<AuthBloc>().add(AuthGoogleLoginEvent());
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Apple button
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    // TODO: Implement Apple sign in
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    side: BorderSide(
                                      color: isDarkMode ? Colors.white30 : Colors.black12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.apple,
                                        size: 24,
                                        color: isDarkMode ? Colors.white : Colors.black,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Apple',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: isDarkMode ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Terms and conditions
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _agreeToTerms,
                                  onChanged: (value) {
                                    setState(() {
                                      _agreeToTerms = value ?? false;
                                    });
                                  },
                                  activeColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    text: 'I agree to Immigru\'s ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDarkMode ? Colors.white70 : Colors.black54,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Terms of Service',
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        // Add gesture recognizer if needed
                                      ),
                                      const TextSpan(
                                        text: ' and ',
                                      ),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        // Add gesture recognizer if needed
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Signup Button
                          ElevatedButton(
                            onPressed: () => _submitForm(context, state),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
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
                                    'Sign up',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Login Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white70 : Colors.black54,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: primaryColor,
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Log in',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
