import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_event.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_state.dart';
import 'package:immigru/features/auth/presentation/screens/login_screen.dart';
import 'package:immigru/features/home/presentation/screens/home_screen.dart';
import 'package:immigru/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A widget that handles authentication state and redirects to the appropriate screen
///
/// This wrapper listens to authentication state changes and ensures users are
/// directed to the correct screen based on their authentication status.
class AuthWrapper extends StatefulWidget {
  /// Child widget to display when user is authenticated
  final Widget? child;

  /// Constructor
  const AuthWrapper({
    super.key,
    this.child,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Check authentication status on initialization
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    if (!_isInitialized) {
      // Trigger auth check in the AuthBloc
      BlocProvider.of<AuthBloc>(context).add(AuthCheckStatusEvent());
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Handle authentication state changes
        if (!state.isAuthenticated && !state.isLoading) {
          // User is not authenticated, navigate to login screen
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state.isLoading) {
            // Show loading indicator while checking auth status
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (state.isAuthenticated && state.user != null) {
            // User is authenticated
            if (state.user!.hasCompletedOnboarding) {
              // User has completed onboarding, show home screen or child widget
              return widget.child ?? const HomeScreen();
            } else {
              // User has not completed onboarding, show onboarding screen
              // Trigger a refresh of the user data to ensure we have the latest onboarding status
              if (!_isInitialized) {
                Future.microtask(() {
                  BlocProvider.of<AuthBloc>(context).add(const AuthRefreshUserEvent());
                });
              }
              return const OnboardingScreen();
            }
          } else {
            // User is not authenticated, check if they've seen the welcome screen
            return FutureBuilder<bool>(
              future: _getHasSeenWelcomeScreen(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final hasSeenWelcomeScreen = snapshot.data ?? false;
                if (hasSeenWelcomeScreen) {
                  // User has seen welcome screen, show login screen
                  return const LoginScreen();
                } else {
                  // User hasn't seen welcome screen, navigate to welcome screen
                  Navigator.of(context)
                      .pushReplacementNamed('/features/welcome');
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }

  Future<bool> _getHasSeenWelcomeScreen() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      return preferences.getBool('has_seen_welcome_screen') ?? false;
    } catch (e) {
      // If there's an error, assume user hasn't seen welcome screen
      return false;
    }
  }
}
