import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:immigru/core/di/injection_container.dart';
import 'package:immigru/core/services/onboarding_service.dart';
import 'package:immigru/domain/repositories/onboarding_repository.dart';
import 'package:immigru/presentation/blocs/auth/auth_bloc.dart';
import 'package:immigru/presentation/blocs/auth/auth_event.dart';
import 'package:immigru/presentation/blocs/auth/auth_state.dart';
import 'package:immigru/presentation/screens/auth/login_screen.dart';
import 'package:immigru/presentation/screens/home/home_screen.dart';
import 'package:immigru/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:immigru/presentation/screens/welcome/welcome_screen.dart';
import 'package:immigru/presentation/theme/app_theme.dart';


class ImmigruApp extends StatelessWidget {
  const ImmigruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => sl<AuthBloc>()..add(AuthCheckStatusEvent()),
        ),
      ],
      child: ChangeNotifierProvider(
        create: (_) => AppThemeProvider(),
        child: const _ImmigruAppContent(),
      ),
    );
  }
}

class _ImmigruAppContent extends StatefulWidget {
  const _ImmigruAppContent();

  @override
  State<_ImmigruAppContent> createState() => _ImmigruAppContentState();
}

class _ImmigruAppContentState extends State<_ImmigruAppContent> {

  @override
  void initState() {
    super.initState();
    print('DEBUG: _ImmigruAppContentState initialized');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<AppThemeProvider>(context);
    
    return MaterialApp(
      title: 'Immigru',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: _buildHomeScreen(),
    );
  }

  Widget _buildHomeScreen() {
    print('DEBUG: Building home screen in old architecture');
    // PRODUCTION MODE NAVIGATION
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        print('DEBUG: Auth state - isLoading: ${state.isLoading}, isAuthenticated: ${state.isAuthenticated}, user: ${state.user != null ? 'exists' : 'null'}');
        if (state.isLoading) {
          print('DEBUG: Showing loading screen');
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state.isAuthenticated && state.user != null) {
          print('DEBUG: User is authenticated');

          return FutureBuilder<bool>(
            future: sl<OnboardingRepository>().hasCompletedOnboarding(),
            builder: (context, snapshot) {
              print('DEBUG: Onboarding check - connectionState: ${snapshot.connectionState}');
              if (snapshot.connectionState == ConnectionState.waiting) {
                print('DEBUG: Waiting for onboarding check');
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              final hasCompletedOnboarding = snapshot.data ?? false;
              print('DEBUG: hasCompletedOnboarding: $hasCompletedOnboarding');
              
              if (hasCompletedOnboarding) {
                print('DEBUG: Navigating to HomeScreen');
                return HomeScreen(user: state.user);
              } else {
                print('DEBUG: Navigating to OnboardingScreen');
                return OnboardingScreen(user: state.user);
              }
            },
          );
        } else {
          print('DEBUG: User is not authenticated');
          return FutureBuilder<bool>(
            future: sl<OnboardingService>().hasSeenWelcomeScreen(),
            builder: (context, snapshot) {
              print('DEBUG: Welcome screen check - connectionState: ${snapshot.connectionState}');
              if (snapshot.connectionState == ConnectionState.waiting) {
                print('DEBUG: Waiting for welcome screen check');
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              final hasSeenWelcomeScreen = snapshot.data ?? false;
              print('DEBUG: hasSeenWelcomeScreen: $hasSeenWelcomeScreen');
              
              if (hasSeenWelcomeScreen) {
                print('DEBUG: Navigating to LoginScreen');
                return const LoginScreen();
              } else {
                print('DEBUG: Navigating to WelcomeScreen');
                return const WelcomeScreen();
              }
            },
          );
        }
      },
    );
  }
}
