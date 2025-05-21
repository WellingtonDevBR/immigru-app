import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:immigru/features/auth/di/auth_module.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_event.dart';
import 'package:immigru/features/auth/presentation/routes/auth_routes.dart';

/// Auth feature module that provides all auth functionality
class AuthFeature {
  final GetIt _serviceLocator;

  /// Constructor
  AuthFeature(this._serviceLocator);

  /// Initialize the auth feature
  Future<void> initialize() async {
    await AuthModule.register(_serviceLocator);
  }

  /// Get the auth routes
  Map<String, WidgetBuilder> getRoutes() {
    return AuthRoutes.getRoutes();
  }

  /// Generate route for the auth feature
  Route<dynamic>? generateRoute(RouteSettings settings) {
    return AuthRoutes.generateRoute(settings);
  }

  /// Provide the auth bloc for the app
  BlocProvider<AuthBloc> provideBloc() {
    return BlocProvider<AuthBloc>(
      create: (context) => _serviceLocator<AuthBloc>(),
    );
  }

  /// Check if a user is authenticated
  Future<bool> isAuthenticated() async {
    final authBloc = _serviceLocator<AuthBloc>();
    return authBloc.state.isAuthenticated;
  }

  /// Get the current user
  Future<void> checkAuthStatus() async {
    final authBloc = _serviceLocator<AuthBloc>();
    authBloc.add(AuthCheckStatusEvent());
  }

  /// Sign out the current user
  Future<void> signOut() async {
    final authBloc = _serviceLocator<AuthBloc>();
    authBloc.add(AuthSignOutEvent());
  }
}
