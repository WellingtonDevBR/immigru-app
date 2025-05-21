import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:immigru/features/home/di/home_module.dart';
import 'package:immigru/features/home/presentation/bloc/home_bloc.dart';
import 'package:immigru/features/home/presentation/screens/home_screen.dart';

/// Feature module for the home feature
class HomeFeature {
  final GetIt _serviceLocator;

  /// Constructor
  HomeFeature(this._serviceLocator);

  /// Initialize the home feature
  Future<void> initialize() async {
    try {
      // Check if HomeBloc is already registered to prevent duplicate registration
      if (!_serviceLocator.isRegistered<HomeBloc>()) {
        HomeModule.init(_serviceLocator);
      } else {}
    } catch (e) {
      // Continue execution even if there's an error to prevent app crashes
    }
  }

  /// Get the home routes
  Map<String, WidgetBuilder> getRoutes() {
    return {
      '/features/home': (context) => BlocProvider.value(
            value: _serviceLocator<HomeBloc>(),
            child: HomeScreen(),
          ),
    };
  }

  /// Generate route for the home feature
  Route<dynamic>? generateRoute(RouteSettings settings) {
    if (settings.name == '/features/home') {
      return MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: _serviceLocator<HomeBloc>(),
          child: HomeScreen(),
        ),
      );
    }
    return null;
  }

  /// Provide the home bloc for the app
  BlocProvider<HomeBloc> provideBloc() {
    // Ensure HomeBloc is registered before providing it
    if (!_serviceLocator.isRegistered<HomeBloc>()) {
      HomeModule.init(_serviceLocator);
    }

    // Use BlocProvider.value to reuse the existing instance
    return BlocProvider.value(
      value: _serviceLocator<HomeBloc>(),
    );
  }
}
