import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:immigru/features/auth/auth_feature.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:immigru/features/onboarding/onboarding_feature.dart';
import 'package:immigru/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_state.dart';
import 'package:immigru/features/auth/presentation/screens/login_screen.dart';
import 'package:immigru/new_core/di/service_locator.dart';
import 'package:immigru/presentation/screens/home/home_screen.dart';
import 'package:immigru/domain/entities/user.dart' as domain_old;
import 'package:immigru/presentation/screens/welcome/welcome_screen.dart';
import 'package:immigru/shared/theme/app_theme.dart';
import 'package:immigru/shared/theme/theme_provider.dart';

/// Main application widget
class ImmigruApp extends StatelessWidget {
  /// Constructor
  const ImmigruApp({super.key});

  @override 
  Widget build(BuildContext context) {
    final sl = ServiceLocator.instance;
    final authFeature = AuthFeature(sl);
    final onboardingFeature = OnboardingFeature(sl);
    
    return MultiBlocProvider(
      providers: [
        authFeature.provideBloc(),
        onboardingFeature.provideBloc(),
      ],
      child: ChangeNotifierProvider(
        create: (_) => sl<ThemeProvider>(),
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
  final sl = ServiceLocator.instance;
  late final AuthFeature _authFeature;
  
  @override
  void initState() {
    super.initState();
    _authFeature = AuthFeature(sl);
    
    // Check authentication status on app start
    _authFeature.checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'Immigru',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: _buildHomeScreen(),
      routes: {
        ..._authFeature.getRoutes(),
        '/onboarding': (context) => const OnboardingScreen(),
      },
      onGenerateRoute: (settings) {
        // Try auth routes first
        final authRoute = _authFeature.generateRoute(settings);
        if (authRoute != null) {
          return authRoute;
        }
        
        // Add other feature routes here
        if (settings.name == '/onboarding') {
          return MaterialPageRoute(
            builder: (_) => const OnboardingScreen(),
          );
        }
        
        // Default route handling
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Route not found'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHomeScreen() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state.isAuthenticated && state.user != null) {
          // Check if user has completed onboarding
          final hasCompletedOnboarding = state.user!.hasCompletedOnboarding;
          
          // Convert feature-first User to domain User for compatibility with old screens
          final domainUser = domain_old.User(
            id: state.user!.id,
            email: state.user!.email ?? '',
            name: state.user!.displayName ?? 'User',
            // Note: hasCompletedOnboarding is stored in the state but not part of the User constructor
          );
          
          if (hasCompletedOnboarding) {
            return HomeScreen(user: domainUser);
          } else {
            return const OnboardingScreen();
          }
        } else {
          // Check if user has seen welcome screen
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
  
  Future<bool> _getHasSeenWelcomeScreen() async {
    // This would come from a welcome feature or onboarding service
    // For now, we'll just return a placeholder
    return true;
  }
}
