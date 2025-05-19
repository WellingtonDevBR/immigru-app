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

                return HomeScreen(user: state.user);
              } else {

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

                return const LoginScreen();
              } else {

                return const WelcomeScreen();
              }
            },
          );
        }
      },
    );
  }
}
