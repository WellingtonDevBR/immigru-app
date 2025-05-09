import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/core/constants/app_colors.dart';
import 'package:immigru/core/di/injection_container.dart';
import 'package:immigru/core/services/logger_service.dart';
import 'package:immigru/presentation/blocs/auth/auth_bloc.dart';
import 'package:immigru/presentation/blocs/auth/auth_event.dart';
import 'package:immigru/presentation/blocs/auth/auth_state.dart';
import 'package:immigru/presentation/screens/auth/phone_login_screen.dart';
import 'package:immigru/presentation/screens/auth/signup_screen.dart';
import 'package:immigru/presentation/screens/auth/widgets/login/login_widgets.dart';
import 'package:immigru/presentation/screens/home/home_screen.dart';
import 'package:immigru/presentation/theme/app_theme.dart';
import 'package:provider/provider.dart';

/// Login screen that supports both email and phone authentication
/// with responsive design and theme toggle
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _logger = LoggerService();
  bool _obscurePassword = true;
  late TabController _tabController;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _logger.debug('Login', 'Login screen initialized');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleTheme(BuildContext context) {
    final themeProvider = Provider.of<AppThemeProvider>(context, listen: false);
    themeProvider.toggleTheme();
    _logger.debug('Login', 'Theme toggled to: ${themeProvider.isDarkMode ? 'dark' : 'light'}');
  }

  void _submitForm(BuildContext context, AuthState state) {
    if (_formKey.currentState!.validate()) {
      // Clear any previous error
      setState(() {
        _errorMessage = null;
      });
      
      // Sanitize input
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      
      _logger.debug('Login', 'Submitting login form with email: $email');
      
      // Add event to the bloc
      context.read<AuthBloc>().add(
            AuthLoginEvent(
              email: email,
              password: password,
            ),
          );
    }
  }
  
  void _signInWithGoogle(BuildContext context) {
    // Clear any previous error
    setState(() {
      _errorMessage = null;
    });
    _logger.debug('Login', 'Starting Google sign-in');
    context.read<AuthBloc>().add(AuthGoogleLoginEvent());
  }
  
  void _navigateToPhoneLogin(BuildContext context) {
    _logger.debug('Login', 'Navigating to phone login screen');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PhoneLoginScreen()),
    );
  }
  
  void _navigateToSignup(BuildContext context) {
    _logger.debug('Login', 'Navigating to signup screen');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );
  }

  // Helper method to build the email login form
  Widget _buildEmailLoginForm(BuildContext context, bool isDarkMode, Color primaryColor, AuthState state) {
    return EmailLoginForm(
      emailController: _emailController,
      passwordController: _passwordController,
      obscurePassword: _obscurePassword,
      isDarkMode: isDarkMode,
      primaryColor: primaryColor,
      state: state,
      togglePasswordVisibility: _togglePasswordVisibility,
      onSubmit: _submitForm,
    );
  }
  
  // Helper method to build the phone login button
  Widget _buildPhoneLoginButton(BuildContext context, bool isDarkMode, Color primaryColor, AuthState state) {
    return PhoneLoginButton(
      isDarkMode: isDarkMode,
      primaryColor: primaryColor,
      state: state,
      onPhoneLogin: _navigateToPhoneLogin,
      onGoogleSignIn: _signInWithGoogle,
    );
  }

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
    
    return BlocProvider(
      create: (context) => sl<AuthBloc>(),
      child: Scaffold(
        backgroundColor: isDarkMode ? AppColors.darkBackground : Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          // Set status bar color based on theme
          child: AppBar(
            backgroundColor: isDarkMode ? AppColors.darkBackground : Colors.white,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: isDarkMode ? AppColors.darkBackground : Colors.white,
              statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
            ),
          ),
        ),
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            setState(() {
              _isLoading = state.isLoading;
            });
            
            if (state.hasError) {
              // Store error message in state instead of showing a snackbar
              setState(() {
                _errorMessage = state.errorMessage ?? 'An error occurred';
              });
              _logger.error('Login', 'Authentication error: ${state.errorMessage}');
            } else if (!state.isLoading) {
              // Clear error message if no error and not loading
              setState(() {
                _errorMessage = null;
              });
            }
            
            // Navigate to home screen when authentication is successful
            if (state.isAuthenticated && state.user != null) {
              _logger.info('Login', 'Authentication successful, navigating to home screen');
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => HomeScreen(user: state.user)),
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
                  // Make the login screen fill the entire available space
                  final screenHeight = size.height;
                  final screenWidth = size.width;
                  
                  return Container(
                    width: screenWidth,
                    height: screenHeight,
                    color: isDarkMode ? AppColors.darkBackground : Colors.white,
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: screenHeight - viewPadding.top - viewPadding.bottom,
                          maxWidth: 500, // Limit maximum width for better readability on large screens
                        ),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Column(
                              children: [
                                // App bar with logo and theme toggle
                                const SizedBox(height: 16),
                                LoginHeader(
                                  isDarkMode: isDarkMode,
                                  primaryColor: primaryColor,
                                  onThemeToggle: () => _toggleTheme(context),
                                ),
                                
                                // Main content - takes all available space
                                Expanded(
                                  child: Center(
                                    child: Container(
                                      width: isSmallScreen ? double.infinity : 400,
                                      constraints: const BoxConstraints(
                                        maxWidth: 450,
                                      ),
                                      child: Form(
                                        key: _formKey,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            // Welcome text
                                            Text(
                                              'Welcome back',
                                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: isDarkMode ? Colors.white : Colors.black87,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Log in to access your Immigru account',
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: isDarkMode ? Colors.white70 : Colors.black54,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 32),
                                            
                                            // Tab bar for switching between email and phone login
                                            LoginTabBar(
                                              controller: _tabController,
                                              isDarkMode: isDarkMode,
                                              primaryColor: primaryColor,
                                            ),
                                            const SizedBox(height: 24),
                                            
                                            // Error message display
                                            if (_errorMessage != null) ...[  
                                              ErrorMessageWidget(
                                                message: _errorMessage!,
                                                onClose: () {
                                                  setState(() {
                                                    _errorMessage = null;
                                                  });
                                                },
                                              ),
                                              const SizedBox(height: 16),
                                            ],
                                            
                                            // Tab content
                                            SizedBox(
                                              height: isSmallScreen ? 450 : 500, // Responsive height for tab content
                                              child: TabBarView(
                                                controller: _tabController,
                                                physics: const BouncingScrollPhysics(), // Smoother scrolling
                                                children: [
                                                  // Email login tab
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                                                    child: _buildEmailLoginForm(context, isDarkMode, primaryColor, state),
                                                  ),
                                                  
                                                  // Phone login tab
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                                                    child: _buildPhoneLoginButton(context, isDarkMode, primaryColor, state),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            
                                            // Sign up link
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 16.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'New to Immigru? ',
                                                    style: TextStyle(
                                                      color: isDarkMode ? Colors.white70 : Colors.black54,
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () => _navigateToSignup(context),
                                                    style: TextButton.styleFrom(
                                                      foregroundColor: primaryColor,
                                                      padding: EdgeInsets.zero,
                                                      minimumSize: const Size(0, 0),
                                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    ),
                                                    child: const Text(
                                                      'Create an account',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
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
