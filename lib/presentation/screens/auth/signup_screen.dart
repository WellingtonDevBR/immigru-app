import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/core/di/injection_container.dart';
import 'package:immigru/presentation/blocs/auth/auth_bloc.dart';
import 'package:immigru/presentation/blocs/auth/auth_event.dart';
import 'package:immigru/presentation/blocs/auth/auth_state.dart';
import 'package:immigru/presentation/screens/auth/login_screen.dart';
import 'package:immigru/presentation/screens/auth/widgets/_shared/auth_footer.dart';
import 'package:immigru/presentation/screens/auth/widgets/_shared/auth_header.dart';
import 'package:immigru/presentation/screens/auth/widgets/_shared/auth_tabbar.dart';
import 'package:immigru/presentation/screens/auth/widgets/login/error_message.dart';
import 'package:immigru/presentation/screens/auth/widgets/signup/signup_widgets.dart';
import 'package:immigru/presentation/screens/home/home_screen.dart';
import 'package:immigru/presentation/theme/app_colors.dart';
import 'package:immigru/presentation/theme/app_theme.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper method to navigate to login screen
  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  // Helper method to submit the form
  void _submitForm(BuildContext context) {
    // Reset the form validation state to ensure it can be submitted again
    _formKey.currentState?.reset();
    _formKey.currentState?.validate();

    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final confirmPassword = _confirmPasswordController.text.trim();

      if (password != confirmPassword) {
        setState(() {
          _errorMessage = 'Passwords do not match';
        });
        return;
      }

      if (!_agreeToTerms) {
        setState(() {
          _errorMessage = 'Please agree to the terms and conditions';
        });
        return;
      }

      // Clear any existing error message
      setState(() {
        _errorMessage = null;
      });

      // Dispatch signup event
      context.read<AuthBloc>().add(AuthSignupEvent(
            email: email,
            password: password,
            agreeToTerms: _agreeToTerms,
          ));
    }
  }

  void _toggleTheme(BuildContext context) {
    final themeProvider = Provider.of<AppThemeProvider>(context, listen: false);
    themeProvider.toggleTheme();
  }

  // Helper method to sign up with Google
  void _signUpWithGoogle(BuildContext context) {
    // Clear any existing error message
    setState(() {
      _errorMessage = null;
    });

    // Dispatch Google login event
    context.read<AuthBloc>().add(AuthGoogleLoginEvent());
  }

  // Form state variables - moved from individual form components to maintain state
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final bool _agreeToTerms = false;

  @override
  Widget build(BuildContext context) {
    // Get the current theme brightness
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    final primaryColor = AppColors.primaryColor;

    // Get screen dimensions for responsive layout
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final viewPadding = MediaQuery.of(context).viewPadding;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        // Set status bar color based on theme
        child: AppBar(
          backgroundColor: isDarkMode ? AppColors.darkBackground : Colors.white,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor:
                isDarkMode ? AppColors.darkBackground : Colors.white,
            statusBarIconBrightness:
                isDarkMode ? Brightness.light : Brightness.dark,
          ),
        ),
      ),
      body: BlocProvider(
        create: (context) => sl<AuthBloc>(),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.hasError) {
              // Store error message in state instead of showing a snackbar
              setState(() {
                _errorMessage = state.errorMessage ?? 'An error occurred';
              });
              // Reset the form state to allow resubmission
              _formKey.currentState?.validate();
            } else if (!state.isLoading) {
              // Clear error message if no error and not loading
              setState(() {
                _errorMessage = null;
              });
            }

            // Handle email verification needed state
            if (state.needsEmailVerification) {
              setState(() {
                _errorMessage = null;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Please check your email to verify your account before logging in.'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 8),
                ),
              );
              // Navigate back to login screen after showing message
              void delayedNavigateToLogin(BuildContext ctx) async {
                await Future.delayed(const Duration(seconds: 3));
                if (!mounted) return;
                Navigator.of(ctx).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }

              delayedNavigateToLogin(context);
            }

            // Navigate to home screen when authentication is successful
            if (state.isAuthenticated) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            }
          },
          builder: (context, state) {
            // Show loading indicator when authentication is in progress and no error
            if (state.isLoading && _errorMessage == null) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              );
            }

            return SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Make the signup screen fill the entire available space
                  final screenHeight = constraints.maxHeight;
                  final screenWidth = constraints.maxWidth;

                  return Container(
                    width: screenWidth,
                    height: screenHeight,
                    color: isDarkMode ? AppColors.darkBackground : Colors.white,
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: screenHeight -
                              viewPadding.top -
                              viewPadding.bottom,
                          maxWidth:
                              500, // Limit maximum width for better readability on large screens
                        ),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Column(
                              children: [
                                // App bar with logo and theme toggle
                                const SizedBox(height: 16),
                                AuthHeader(
                                  isDarkMode: isDarkMode,
                                  primaryColor: primaryColor,
                                  onThemeToggle: () => _toggleTheme(context),
                                  title: 'Immigru',
                                  icon: Icons.eco_rounded,
                                ),
                                const SizedBox(height: 30),
                                Center(
                                  child: Container(
                                    width:
                                        isSmallScreen ? double.infinity : 400,
                                    constraints:
                                        const BoxConstraints(maxWidth: 450),
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            'Create your account',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: isDarkMode
                                                      ? Colors.white
                                                      : Colors.black87,
                                                ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Join Immigru to start your immigration journey',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: isDarkMode
                                                      ? Colors.white70
                                                      : Colors.black54,
                                                ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 32),
                                          AuthTabBar(
                                            controller: _tabController,
                                            isDarkMode: isDarkMode,
                                            primaryColor: primaryColor,
                                          ),
                                          const SizedBox(height: 32),
                                          if (_errorMessage != null) ...[
                                            const SizedBox(height: 16),
                                            ErrorMessageWidget(
                                              message: _errorMessage!,
                                              onClose: () {
                                                setState(() {
                                                  _errorMessage = null;
                                                });
                                              },
                                            ),
                                          ],
                                          SizedBox(
                                            height: isSmallScreen
                                                ? 450
                                                : 500, // Responsive height for tab content
                                            child: TabBarView(
                                              controller: _tabController,
                                              physics:
                                                  const BouncingScrollPhysics(),
                                              children: [
                                                EmailSignupForm(
                                                  submitForm: _submitForm,
                                                  authState: state,
                                                  onGoogleSignUpPressed: () {
                                                    _signUpWithGoogle(context);
                                                  },
                                                ),
                                                PhoneSignupForm(
                                                  authState: state,
                                                  tabController: _tabController,
                                                ),
                                              ],
                                            ),
                                          ),
                                          AuthFooter(
                                            promptText: 'Have an account? ',
                                            actionText: 'Log in',
                                            onPressed: () =>
                                                _navigateToLogin(context),
                                            isDarkMode: isDarkMode,
                                            primaryColor: primaryColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
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
            );
          },
        ),
      ),
    );
  }
}
