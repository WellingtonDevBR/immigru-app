import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:immigru/core/di/injection_container.dart';
import 'package:immigru/core/services/logger_service.dart';
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
  final LoggerService _logger = LoggerService();

  @override
  void initState() {
    super.initState();
    _logger.info('App', 'Initializing ImmigruApp');
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
    // PRODUCTION MODE NAVIGATION
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state.isAuthenticated && state.user != null) {
          _logger.info('App', 'User authenticated, checking onboarding status');
          return FutureBuilder<bool>(
            future: sl<OnboardingRepository>().hasCompletedOnboarding(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              final hasCompletedOnboarding = snapshot.data ?? false;
              
              if (hasCompletedOnboarding) {
                _logger.info('App', 'Onboarding completed, showing home screen');
                return HomeScreen(user: state.user);
              } else {
                _logger.info('App', 'Onboarding not completed, showing onboarding screen');
                return OnboardingScreen(user: state.user);
              }
            },
          );
        } else {
          return FutureBuilder<bool>(
            future: sl<OnboardingService>().hasSeenWelcomeScreen(),
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
                _logger.info('App', 'User not authenticated, showing login screen');
                return const LoginScreen();
              } else {
                _logger.info('App', 'First-time user, showing welcome screen');
                return const WelcomeScreen();
              }
            },
          );
        }
      },
    );
  }
}
