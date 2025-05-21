import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:immigru/features/auth/auth_feature.dart';
import 'package:immigru/features/auth/presentation/widgets/auth_wrapper.dart';
import 'package:immigru/features/home/home_feature.dart';
import 'package:immigru/features/home/presentation/bloc/home_bloc.dart';
import 'package:immigru/features/onboarding/onboarding_feature.dart';
import 'package:immigru/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:immigru/features/welcome/welcome_feature.dart';
import 'package:immigru/features/welcome/presentation/bloc/welcome_bloc.dart';
import 'package:immigru/features/welcome/presentation/screens/welcome_screen.dart';
import 'package:immigru/core/di/service_locator.dart';
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
  late final HomeFeature _homeFeature;
  late final WelcomeFeature _welcomeFeature;

  @override
  void initState() {
    super.initState();
    _authFeature = AuthFeature(sl);
    _homeFeature = HomeFeature(sl);
    _welcomeFeature = WelcomeFeature(sl);

    // Initialize features in a safer way to prevent multiple registrations
    _initializeFeatures();

    // Check authentication status on app start
    _authFeature.checkAuthStatus();
  }
  
  // Safe initialization of features with proper error handling
  Future<void> _initializeFeatures() async {
    try {
      // Initialize home feature first to ensure HomeBloc is registered
      await _homeFeature.initialize();
      print('Home feature initialized successfully');
    } catch (e) {
      print('Home feature initialization error: $e');
      // Continue execution even if there's an error
    }

    try {
      // Then initialize welcome feature
      await _welcomeFeature.initialize();
      print('Welcome feature initialized successfully');
    } catch (e) {
      print('Welcome feature initialization error: $e');
      // Continue execution even if there's an error
    }
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
        '/features/welcome': (context) => BlocProvider<WelcomeBloc>(
              create: (context) => sl<WelcomeBloc>(),
              child: const WelcomeScreen(),
            ),
      },
      onGenerateRoute: (settings) {
        // Try auth routes first
        final authRoute = _authFeature.generateRoute(settings);
        if (authRoute != null) {
          return authRoute;
        }

        // Try welcome routes
        final welcomeRoute = _welcomeFeature.generateRoute(settings);
        if (welcomeRoute != null) {
          return welcomeRoute;
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
    // Use a single instance of HomeBloc for the entire app
    return BlocProvider<HomeBloc>(
      create: (context) => sl<HomeBloc>(),
      child: const AuthWrapper(), // Let AuthWrapper handle HomeScreen creation
    );
  }
}
