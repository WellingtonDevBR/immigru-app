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
      HomeModule.init(_serviceLocator);
    } catch (e) {
      print('Error initializing HomeFeature: $e');
    }
  }

  /// Get the home routes
  Map<String, WidgetBuilder> getRoutes() {
    return {
      '/features/home': (context) => BlocProvider<HomeBloc>(
            create: (context) => _serviceLocator<HomeBloc>(),
            child: const HomeScreen(),
          ),
    };
  }

  /// Generate route for the home feature
  Route<dynamic>? generateRoute(RouteSettings settings) {
    if (settings.name == '/features/home') {
      return MaterialPageRoute(
        builder: (_) => BlocProvider<HomeBloc>(
          create: (context) => _serviceLocator<HomeBloc>(),
          child: const HomeScreen(),
        ),
      );
    }
    return null;
  }

  /// Provide the home bloc for the app
  BlocProvider<HomeBloc> provideBloc() {
    return BlocProvider<HomeBloc>(
      create: (context) => _serviceLocator<HomeBloc>(),
    );
  }
}
