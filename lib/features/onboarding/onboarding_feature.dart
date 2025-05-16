import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:immigru/features/onboarding/di/onboarding_module.dart';
import 'package:immigru/features/onboarding/presentation/bloc/onboarding/onboarding_bloc.dart';
import 'package:immigru/features/onboarding/presentation/bloc/onboarding/onboarding_event.dart';
import 'package:immigru/features/onboarding/presentation/screens/onboarding_screen.dart';

/// Feature module for the onboarding feature
class OnboardingFeature {
  final GetIt _serviceLocator;
  
  /// Constructor
  OnboardingFeature(this._serviceLocator);
  
  /// Initialize the onboarding feature
  Future<void> initialize() async {
    await OnboardingModule.register(_serviceLocator);
  }
  
  /// Get the onboarding routes
  Map<String, WidgetBuilder> getRoutes() {
    return {
      '/features/onboarding': (context) => const OnboardingScreen(),
    };
  }

  /// Generate route for the onboarding feature
  Route<dynamic>? generateRoute(RouteSettings settings) {
    if (settings.name == '/features/onboarding') {
      return MaterialPageRoute(
        builder: (_) => const OnboardingScreen(),
      );
    }
    return null;
  }
  
  /// Provide the onboarding bloc for the app
  BlocProvider<OnboardingBloc> provideBloc() {
    return BlocProvider<OnboardingBloc>(
      create: (context) => _serviceLocator<OnboardingBloc>()
        ..add(const OnboardingInitialized()),
    );
  }
}
