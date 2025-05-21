import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:immigru/features/welcome/di/welcome_module.dart';
import 'package:immigru/features/welcome/presentation/bloc/welcome_bloc.dart';
import 'package:immigru/features/welcome/presentation/screens/welcome_screen.dart';

/// Feature module for the welcome feature
class WelcomeFeature {
  final GetIt _serviceLocator;

  /// Constructor
  WelcomeFeature(this._serviceLocator);

  /// Initialize the welcome feature
  Future<void> initialize() async {
    try {
      // Check if WelcomeBloc is already registered to prevent duplicate registration
      if (!_serviceLocator.isRegistered<WelcomeBloc>()) {
        await WelcomeModule.register(_serviceLocator);
      } else {}
    } catch (e) {
      // Continue execution even if there's an error to prevent app crashes
    }
  }

  /// Get the welcome routes
  Map<String, WidgetBuilder> getRoutes() {
    return {
      '/features/welcome': (context) => BlocProvider<WelcomeBloc>(
            create: (context) => _serviceLocator<WelcomeBloc>(),
            child: const WelcomeScreen(),
          ),
    };
  }

  /// Generate route for the welcome feature
  Route<dynamic>? generateRoute(RouteSettings settings) {
    if (settings.name == '/features/welcome') {
      return MaterialPageRoute(
        builder: (_) => BlocProvider<WelcomeBloc>(
          create: (context) => _serviceLocator<WelcomeBloc>(),
          child: const WelcomeScreen(),
        ),
      );
    }
    return null;
  }

  /// Provide the welcome bloc for the app
  BlocProvider<WelcomeBloc> provideBloc() {
    return BlocProvider<WelcomeBloc>(
      create: (context) => _serviceLocator<WelcomeBloc>(),
    );
  }
}
