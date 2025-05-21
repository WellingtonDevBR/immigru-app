import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_event.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_state.dart';
import 'package:immigru/features/auth/presentation/screens/login_screen.dart';
import 'package:immigru/features/home/presentation/screens/home_screen.dart';
import 'package:immigru/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:immigru/features/welcome/presentation/screens/welcome_screen.dart';
import 'package:immigru/features/welcome/presentation/bloc/welcome_bloc.dart';
import 'package:immigru/features/home/presentation/bloc/home_bloc.dart';
import 'package:immigru/core/di/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:immigru/core/logging/unified_logger.dart';

/// A widget that handles authentication state and redirects to the appropriate screen
class AuthWrapper extends StatefulWidget {
  final Widget? child;

  const AuthWrapper({super.key, this.child});
  
  /// Helper method to safely navigate to the root of the app
  /// This ensures we're using a single instance of AuthWrapper
  /// and letting it handle the routing logic
  static void navigateToRoot(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => BlocProvider<HomeBloc>(
        create: (context) => ServiceLocator.instance<HomeBloc>(),
        child: const AuthWrapper(),
      )),
      (route) => false,
    );
  }

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final UnifiedLogger _logger = UnifiedLogger();
  
  // Cooldown mechanism to prevent excessive refreshes
  DateTime? _lastRefreshTime;
  final Duration _refreshCooldown = const Duration(seconds: 30);
  
  // Use a constant key for HomeScreen to preserve state
  final Widget _homeScreenInstance = HomeScreen(key: const Key('home_screen_singleton'));

  @override
  void initState() {
    super.initState();
    // No side effects in initState - will be handled by BlocListener
  }
  
  // Check if we're within the cooldown period
  bool _canRefresh() {
    final now = DateTime.now();
    if (_lastRefreshTime != null && 
        now.difference(_lastRefreshTime!) < _refreshCooldown) {
      return false;
    }
    return true;
  }
  
  // Update the refresh timestamp
  void _updateRefreshTimestamp() {
    _lastRefreshTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Listener for authentication changes
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) => 
              previous.isAuthenticated != current.isAuthenticated,
          listener: (context, state) {
            if (state.isAuthenticated) {
              // User just authenticated, refresh data if needed
              if (_canRefresh()) {
                _logger.d('User authenticated, refreshing user data', tag: 'AuthWrapper');
                _updateRefreshTimestamp();
                context.read<AuthBloc>().add(AuthRefreshUserEvent());
              } else {
                _logger.d('Skipping refresh - within cooldown period', tag: 'AuthWrapper');
              }
            } else if (!state.isLoading) {
              // User is not authenticated, navigate to login
              _logger.d('User not authenticated, navigating to login', tag: 'AuthWrapper');
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
              }
            }
          },
        ),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        buildWhen: (previous, current) => 
            previous.isAuthenticated != current.isAuthenticated ||
            previous.isLoading != current.isLoading ||
            (previous.user?.hasCompletedOnboarding != current.user?.hasCompletedOnboarding),
        builder: (context, state) {
          // Loading state
          if (state.isLoading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          
          // Authenticated state
          if (state.isAuthenticated && state.user != null) {
            final hasCompletedOnboarding = state.user!.hasCompletedOnboarding;
            _logger.d('User onboarding status: $hasCompletedOnboarding', tag: 'AuthWrapper');
            
            if (hasCompletedOnboarding) {
              // User has completed onboarding, show home screen
              return widget.child ?? _homeScreenInstance;
            } else {
              // User has not completed onboarding, show onboarding screen
              _logger.d('User has not completed onboarding, showing onboarding screen', tag: 'AuthWrapper');
              return const OnboardingScreen();
            }
          }
          
          // Not authenticated: check if user has seen welcome screen
          return FutureBuilder<bool>(
            future: _getHasSeenWelcomeScreen(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              
              final hasSeenWelcomeScreen = snapshot.data ?? false;
              
              if (hasSeenWelcomeScreen) {
                return const LoginScreen();
              } else {
                // Show welcome screen
                return BlocProvider<WelcomeBloc>(
                  create: (context) => ServiceLocator.instance<WelcomeBloc>(),
                  child: const WelcomeScreen(),
                );
              }
            },
          );
        },
      ),
    );
  }

  Future<bool> _getHasSeenWelcomeScreen() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      return preferences.getBool('has_seen_welcome_screen') ?? false;
    } catch (e) {
      return false;
    }
  }
}
